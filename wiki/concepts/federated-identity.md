---
title: "Federated Identity"
tags: [federated-identity, oauth2, oidc, saml, idp, sso, authentication]
sources: [owasp-security-terminology.md]
updated: 2026-04-16
---

# Federated Identity

## Definition

Federated identity allows users to authenticate with one system (Identity Provider) and access multiple services (Relying Parties) without separate credentials for each.

## Core Roles

| Role                        | Definition                                                        | Examples                               |
| --------------------------- | ----------------------------------------------------------------- | -------------------------------------- |
| **Identity Provider (IdP)** | Creates/maintains identity info; provides authentication services | Google, Okta, Azure AD, Auth0          |
| **Relying Party (RP)**      | Application/service that delegates authentication to an IdP       | Your web app using "Login with Google" |
| **Service Provider (SP)**   | SAML-specific term equivalent to Relying Party                    | Enterprise app using SAML SSO          |
| **Principal**               | The entity being authenticated (user, service, device)            | The actual user logging in             |

## Common Protocols

| Protocol                  | Use Case                                           | Token Format                 |
| ------------------------- | -------------------------------------------------- | ---------------------------- |
| **OAuth 2.0**             | Delegated authorization (access on behalf of user) | Access token (opaque or JWT) |
| **OpenID Connect (OIDC)** | Authentication layer on top of OAuth 2.0           | ID token (JWT)               |
| **SAML 2.0**              | Enterprise SSO, XML-based                          | SAML assertion (XML)         |

## Security Considerations

- Validate `iss` (issuer) and `aud` (audience) claims in JWTs
- Verify token signatures against IdP public keys
- Use state parameter in OAuth to prevent CSRF
- Rotate signing keys and cache public key discovery (`/.well-known/jwks.json`)
- Watch for algorithm confusion attacks in JWTs (e.g., RS256 → HS256 downgrade)

## Related Pages

- [Authentication](authentication.md)
- [Multi-Factor Authentication](mfa.md)
- [REST API Security](rest-api-security.md)
- [OWASP Security Terminology](../sources/owasp-security-terminology.md)
