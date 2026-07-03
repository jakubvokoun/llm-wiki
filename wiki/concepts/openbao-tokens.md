---
title: "OpenBao — Tokens"
tags: [openbao, tokens, authentication, ttl, root-token, security]
sources: [openbao-concept-tokens.md, openbao-concept-auth.md]
updated: 2026-07-03
---

# OpenBao — Tokens

The core authentication primitive in [OpenBao](../entities/openbao.md). Every [auth method](openbao-auth-methods.md) ultimately issues a token, which maps to a set of [policies](openbao-policies.md) plus metadata. Tokens are **opaque** — never parse their internal structure.

## Formats & types

Prefix + Base62 body (regex `[sbr]\.[a-zA-Z0-9]{24,}`): `s.` service, `b.` batch, `r.` recovery. The **token store** (`token` auth backend) creates/stores tokens and cannot be disabled.

| Feature                                                      | Service token             | Batch token                              |
| ------------------------------------------------------------ | ------------------------- | ---------------------------------------- |
| Storage cost                                                 | Heavyweight (disk writes) | Lightweight (encrypted blob, no storage) |
| Renewable / revocable / child tokens / accessors / cubbyhole | Yes                       | No                                       |
| Can be root / periodic / explicit-max-TTL                    | Yes                       | No (fixed TTL)                           |
| Revoked with parent                                          | Yes                       | Stops working                            |

## Root tokens

Have the `root` policy — can do _anything_ and are the only tokens that can have no expiration. Deliberately hard to create: (1) the initial `bao operator init` token, (2) from another root token, (3) `bao operator generate-root` with a quorum of unseal/recovery keys. Use only for bootstrap or emergencies, then **revoke immediately**.

## Hierarchies & orphans

Child tokens are revoked when the parent is (prevents escape via endless child trees). **Orphan** tokens have no parent — created via `auth/token/create-orphan`, `no_parent=true` (with sudo/root), token roles, or by logging in with any non-`token` auth method.

## Accessors

Each token gets an **accessor** — a reference usable only to look up properties/capabilities, renew, or revoke (not to read the token ID). Useful for a scheduler to revoke job tokens by accessor; `auth/token/accessors` is the only way to "list" tokens.

## TTL, periodic & CIDR

Non-root tokens have a **TTL** (from creation or last renewal) capped by the min of system max TTL (32 days, configurable), mount max TTL, and the auth method's suggestion — recomputed each renewal. An **explicit max TTL** is a hard ceiling. **Periodic tokens** reset to their period on each renewal → unlimited lifetime while actively renewed (for long-running services). Tokens may be **CIDR-bound** to restrict client IPs.

## Related

- [Auth methods](openbao-auth-methods.md)
- [Policies](openbao-policies.md)
- [Leases](openbao-leases.md)
- [Identity](openbao-identity.md)
- [OpenBao](../entities/openbao.md)
- [source summary](../sources/openbao-concept-tokens.md)
