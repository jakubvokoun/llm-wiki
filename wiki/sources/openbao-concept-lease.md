---
title: "OpenBao — Lease, Renew, Revoke (concept)"
tags: [openbao, lease, renewal, revocation]
sources: [openbao-concept-lease.md]
updated: 2026-07-03
---

# OpenBao — Lease, Renew, Revoke (concept)

Source summary. Full synthesis: [Leases, Renewal & Revocation](../concepts/openbao-leases.md).

## Key Takeaways

- Every dynamic secret and `service` token has a **lease** (TTL + renewability); reads return a `lease_id`. Static KV secrets have no lease.
- **Renew** with `bao lease renew -increment=<s>` — the increment is measured from now and is advisory (backend may cap it).
- **Revoke** invalidates immediately; expiry auto-revokes; revoking a token revokes all leases it created.
- **Prefix revocation** (`-prefix auth/userpass/`) revokes trees of secrets — key for intrusion containment.

## Related

- [Leases](../concepts/openbao-leases.md)
- [Tokens](../concepts/openbao-tokens.md)
- [OpenBao](../entities/openbao.md)
