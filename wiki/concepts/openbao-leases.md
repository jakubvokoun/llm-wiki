---
title: "OpenBao — Leases, Renewal & Revocation"
tags: [openbao, lease, renewal, revocation, dynamic-secrets, ttl]
sources: [openbao-concept-lease.md]
updated: 2026-07-03
---

# OpenBao — Leases, Renewal & Revocation

Every dynamic secret and `service`-type auth [token](openbao-tokens.md) in [OpenBao](../entities/openbao.md) carries a **lease**: metadata (a TTL, renewability, etc.) that forces consumers to check back in — making audit logs more useful and key rolling easier.

## Lease lifecycle

- All **dynamic secrets** must have a lease; reading one returns a **`lease_id`**. (The KV backend stores static secrets and does **not** issue leases.)
- **Renewal:** `bao lease renew -increment=3600 <lease_id>` requests a new TTL measured **from now** (not added to the current end). The increment is _advisory_ — the backend may cap or ignore it, so always inspect the returned lease.
- **Revocation** invalidates a secret immediately and blocks renewal — via API, `bao lease revoke`, or the UI. Happens automatically on expiry. Revoking a **token** revokes all leases it created.

## Prefix-based revocation

Lease IDs are prefixed by the path the secret came from, so you can revoke **trees** of secrets: `bao lease revoke -prefix auth/userpass/`. Invaluable for quickly containing an intrusion in a specific backend.

## Related

- [Tokens](openbao-tokens.md)
- [Auth methods](openbao-auth-methods.md)
- [OpenBao](../entities/openbao.md)
- [source summary](../sources/openbao-concept-lease.md)
