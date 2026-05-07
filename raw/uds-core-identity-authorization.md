# Identity & Authorization

UDS Core centralizes authentication and authorization using [Keycloak](https://www.keycloak.org/) as the identity provider. When an application supports standard SSO flows (OIDC, OAuth2, or SAML), the UDS Operator automatically registers a Keycloak client for it and delivers credentials to the application namespace. The application handles its own token flow natively, which is the preferred approach.

[Authservice](https://github.com/istio-ecosystem/authservice) is also available for applications that have no native SSO support. It intercepts requests and handles the OIDC flow on the application's behalf. This is a useful escape hatch, but not the recommended default. If an application can speak OIDC natively, it should.

Prefer native SSO integration over Authservice where possible. Native integration is more observable, more maintainable, and keeps authentication logic inside the application where it belongs. Authservice is best reserved for legacy or off-the-shelf applications that cannot be modified to support OIDC.

## Why centralized identity?

Applications deployed on regulated platforms cannot each maintain their own user stores or authentication logic. Centralizing identity provides:

* **A single audit trail**: all authentication events flow through one system
* **Consistent access control**: group membership and role assignments apply uniformly across services
* **Reduced developer burden**: application teams declare SSO requirements in a `Package` CR; the platform handles client registration and token validation

## The SSO model

**Keycloak** is the identity provider. It manages users, groups, and OAuth2/OIDC clients, and federates to external identity providers (Azure AD, Google, LDAP) when teams need to connect an existing directory service.

**The UDS Operator** automates Keycloak client registration. When a `Package` CR declares an `sso` block, the operator:

* Creates a Keycloak OIDC client with the correct redirect URIs
* Stores the client credentials in a Kubernetes secret in the application namespace

For applications with native OIDC support, the application uses the credentials from the operator-managed secret to speak directly to Keycloak. The application handles login redirects, token validation, and session management itself. This is preferred because:

* The application has full visibility into user identity, roles, and claims
* Authentication behavior is observable and testable within the application
* No additional proxy layer to configure or troubleshoot

For applications with no native OIDC support, the operator can additionally configure Authservice to intercept requests before they reach the application and handle the OIDC flow transparently.

Authservice limitations:

* Handles authentication at the proxy layer; the token is passed through but the application is not managing the OIDC flow itself, making the integration less observable and harder to troubleshoot
* Adds an additional proxy layer to configure and troubleshoot

## Platform groups

UDS Core pre-configures two Keycloak groups that drive access to platform admin interfaces:

| Group | Purpose | What it protects |
| --- | --- | --- |
| `/UDS Core/Admin` | Platform administrators | Grafana admin, Keycloak admin console, Alertmanager |
| `/UDS Core/Auditor` | Read-only platform access | Grafana viewer, log browsing |

Application teams can define their own group-based restrictions in their `Package` CR using the `groups.anyOf` field. A service protected with `anyOf: ["/UDS Core/Admin"]` will reject tokens that do not carry membership in that group, even if the user is otherwise authenticated.

## Keycloak configuration layers

UDS Core supports three layers of Keycloak customization, each suited to different use cases:

| Approach | Use for | Requires image rebuild? |
| --- | --- | --- |
| **Helm chart values** | Session policies, account settings, auth flow toggles | No |
| **UDS Identity Config image** | Custom themes, plugins, CA truststore | Yes (themes and plugins apply when the Keycloak pod restarts; no realm re-import needed) |
| **OpenTofu / IaC** | Managing groups, clients, IdPs post-deploy | No |

Most operational configuration (session timeouts, lockout policies, authentication flows) is handled via Helm chart values without rebuilding anything. Custom themes, plugins, and truststore changes require building and deploying a custom UDS Identity Config image. Post-deploy management of Keycloak resources (groups, clients, IdPs) can be automated with OpenTofu.
