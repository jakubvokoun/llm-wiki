---
title: "Keycloak"
tags: [product, identity, sso, oidc, oauth2, saml, red-hat, kubernetes]
sources: [uds-core-identity-authorization.md, uds-core-concepts-overview.md]
updated: 2026-05-07
---

# Keycloak

Keycloak is an open-source Identity and Access Management (IAM) solution maintained
by Red Hat. It provides SSO, OAuth2/OIDC, SAML, and LDAP federation. It is the
identity provider in [UDS Core](uds-core.md).

## Key capabilities

- **SSO** — users authenticate once and access all integrated applications
- **OAuth2 / OIDC / SAML** — standards-based protocol support
- **Federation** — connects to external IdPs (Azure AD, Google, LDAP/Active Directory)
- **Group-based access control** — group membership drives application authorization
- **Client management** — OIDC clients registered per application with secrets
  delivered to Kubernetes secrets

## Role in UDS Core

When a `Package` CR declares an `sso` block, the [UDS Operator](../concepts/uds-operator.md)
automatically registers a Keycloak OIDC client and stores the credentials in the
application namespace as a Kubernetes secret.

**Platform groups** pre-configured in UDS Core:

- `/UDS Core/Admin` — platform administrator access to Grafana admin, Keycloak console, Alertmanager
- `/UDS Core/Auditor` — read-only access to Grafana and logs

## Authservice integration

For applications with no native OIDC support, Authservice (an Istio ecosystem project)
intercepts requests and handles the OIDC flow at the proxy layer. Native OIDC is
preferred; Authservice is an escape hatch for legacy apps.

## Configuration layers (in UDS Core)

| Layer               | Use for                             | Image rebuild needed? |
| ------------------- | ----------------------------------- | --------------------- |
| Helm chart values   | Session policies, auth flow toggles | No                    |
| UDS Identity Config | Themes, plugins, CA truststore      | Yes                   |
| OpenTofu / IaC      | Groups, clients, IdPs post-deploy   | No                    |

## Related pages

- [Authentication](../concepts/authentication.md)
- [Federated Identity](../concepts/federated-identity.md)
- [UDS Core — Identity & Authorization](../sources/uds-core-identity-authorization.md)
- [UDS Core](uds-core.md)
