---
title: "OpenBao — Authentication Methods"
tags: [openbao, authentication, auth-methods, tokens, login]
sources: [openbao-concept-auth.md, openbao-concept-identity.md]
updated: 2026-07-03
---

# OpenBao — Authentication Methods

How clients prove identity to [OpenBao](../entities/openbao.md) and receive a [token](openbao-tokens.md). Verifies user/machine-supplied info against an internal or external system.

## Auth methods

OpenBao supports many methods — some user-oriented (GitHub, LDAP, userpass), some machine-oriented (AppRole, JWT/OIDC, Kubernetes, TLS cert). Enable before use, and the **same type can be mounted at multiple paths**:

```
$ bao write sys/auth/my-auth type=userpass
```

Only one successful authentication is needed to get access (some backends support MFA, but you can't chain multiple methods). On success a token is generated and the [policies](openbao-policies.md) mapped at auth time are attached.

## Logging in

- **CLI:** `bao login -method=github token=<token>` (or `-method=userpass username=...`). Outputs the raw token used for renewal/revocation.
- **API** (machines): each method has its own login endpoint, e.g. `auth/github/login`. Use `bao path-help <path>` to discover arguments.

## Auth leases & renewal

Like secrets, identities carry [leases](openbao-leases.md) — you must reauthenticate after the lease period, or renew with `bao token renew <token>` (leasing behavior is method-specific). Client SDKs typically run a lifetime watcher goroutine to renew tokens before expiry, falling back to re-login when renewal fails or max TTL is reached.

## Related

- [Tokens](openbao-tokens.md)
- [Identity](openbao-identity.md)
- [Policies](openbao-policies.md)
- [Leases](openbao-leases.md)
- [OpenBao](../entities/openbao.md)
- [source summary](../sources/openbao-concept-auth.md)
