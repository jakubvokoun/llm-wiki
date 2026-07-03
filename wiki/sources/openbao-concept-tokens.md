---
title: "OpenBao — Tokens (concept)"
tags: [openbao, tokens, root-token, batch-tokens, ttl]
sources: [openbao-concept-tokens.md]
updated: 2026-07-03
---

# OpenBao — Tokens (concept)

Source summary. Full synthesis: [Tokens](../concepts/openbao-tokens.md).

## Key Takeaways

- Tokens are opaque (`s.`/`b.`/`r.` prefix + Base62 body) and map to [policies](../concepts/openbao-policies.md) + metadata. The token store can't be disabled.
- **Service vs batch:** service tokens are full-featured/heavyweight; batch tokens are lightweight encrypted blobs with no storage, renewal, or accessors.
- **Root tokens** can do anything and may never expire — created only 3 ways; revoke ASAP.
- **Accessors** allow lookup/renew/revoke without the token ID. **Orphan** tokens escape parent revocation. TTLs capped by system/mount/method max; **periodic** tokens live indefinitely while renewed; **explicit max TTL** is a hard ceiling; tokens can be CIDR-bound.

## Related

- [Tokens](../concepts/openbao-tokens.md)
- [Auth methods](../concepts/openbao-auth-methods.md)
- [Leases](../concepts/openbao-leases.md)
- [OpenBao](../entities/openbao.md)
