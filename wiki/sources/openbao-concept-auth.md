---
title: "OpenBao — Authentication (concept)"
tags: [openbao, authentication, auth-methods, login]
sources: [openbao-concept-auth.md]
updated: 2026-07-03
---

# OpenBao — Authentication (concept)

Source summary. Full synthesis: [Authentication Methods](../concepts/openbao-auth-methods.md).

## Key Takeaways

- Authentication verifies user/machine info against an internal/external system and issues a [token](../concepts/openbao-tokens.md) with mapped [policies](../concepts/openbao-policies.md).
- Many methods (GitHub, LDAP, AppRole, userpass, JWT/OIDC, Kubernetes, TLS); enable via `bao write sys/auth/<path> type=<method>`; the same type can mount at multiple paths.
- **CLI:** `bao login -method=<m>`. **API:** per-method login endpoints (e.g. `auth/github/login`); use `bao path-help`.
- Identities carry leases → reauthenticate or `bao token renew`. Includes a Go lifetime-watcher renewal example.

## Related

- [Auth methods](../concepts/openbao-auth-methods.md)
- [Tokens](../concepts/openbao-tokens.md)
- [Policies](../concepts/openbao-policies.md)
- [OpenBao](../entities/openbao.md)
