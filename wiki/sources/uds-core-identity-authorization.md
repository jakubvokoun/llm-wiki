---
title: "UDS Core — Identity & Authorization"
tags: [uds-core, keycloak, sso, oidc, authservice, identity, authorization]
sources: [uds-core-identity-authorization.md]
updated: 2026-05-07
---

# UDS Core — Identity & Authorization

UDS Core centralizes authentication and authorization using [Keycloak](../entities/keycloak.md) as the identity provider. The UDS Operator automates Keycloak client registration; application teams only declare an `sso` block in their `Package` CR.

## Why centralized identity?

Regulated platforms cannot have each application maintain its own user store or auth logic. Centralized identity provides:

- **Single audit trail** — all authentication events flow through one system
- **Consistent access control** — group membership applies uniformly across services
- **Reduced developer burden** — declare SSO needs in `Package` CR; platform handles registration

## SSO model

**Keycloak** manages users, groups, and OAuth2/OIDC clients. It federates to external IdPs (Azure AD, Google, LDAP) when teams need to connect an existing directory.

When a `Package` CR declares an `sso` block, the UDS Operator:

1. Creates a Keycloak OIDC client with correct redirect URIs
2. Stores client credentials in a Kubernetes secret in the application namespace

### Native OIDC (preferred)

Applications with native OIDC support use the operator-managed secret to speak directly to Keycloak. The application manages the login redirect, token validation, and session. This is preferred because it is observable, testable, and keeps auth logic in the application.

### Authservice (escape hatch)

For applications with no native OIDC support, the operator can configure [Authservice](https://github.com/istio-ecosystem/authservice) to intercept requests and handle the OIDC flow transparently at the proxy layer. Limitations:

- Less observable — the application is not managing the OIDC flow
- Harder to troubleshoot — adds an additional proxy layer
- Best reserved for legacy or off-the-shelf apps that cannot implement OIDC

## Platform groups

| Group | Purpose | What it protects |
| --- | --- | --- |
| `/UDS Core/Admin` | Platform admins | Grafana admin, Keycloak admin console, Alertmanager |
| `/UDS Core/Auditor` | Read-only access | Grafana viewer, log browsing |

Application teams can define their own group restrictions in `Package` CR using `groups.anyOf`.

## Keycloak configuration layers

| Approach | Use for | Requires image rebuild? |
| --- | --- | --- |
| Helm chart values | Session policies, auth flow toggles | No |
| UDS Identity Config image | Custom themes, plugins, CA truststore | Yes |
| OpenTofu / IaC | Groups, clients, IdPs post-deploy | No |

## Related pages

- [Authentication](../concepts/authentication.md)
- [Federated Identity](../concepts/federated-identity.md)
- [Keycloak](../entities/keycloak.md)
- [UDS Package CR](../concepts/uds-package-cr.md)
- [Zero Trust Architecture](../concepts/zero-trust.md)
