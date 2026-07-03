---
title: "OpenBao — Policies (concept)"
tags: [openbao, policies, acl, authorization, hcl]
sources: [openbao-concept-policies.md]
updated: 2026-07-03
---

# OpenBao — Policies (concept)

Source summary. Full synthesis: [Policies (ACLs)](../concepts/openbao-policies.md).

## Key Takeaways

- Path-based, HCL/JSON, **deny by default**. Admins map auth-method data → named policies → attached to issued [tokens](../concepts/openbao-tokens.md).
- **Capabilities:** create/read/update/patch/delete/list/scan + `sudo` (root-protected paths) and `deny` (always wins). Capabilities map to the **HTTP verb**, not the action.
- Glob `*` only as last char; `+` = one segment; most-specific match wins, union on identical patterns.
- **Templated policies** inject `identity.*`; **parameter constraints** (allowed/denied/required, not on KV v2); path `expiration`; wrapping-TTL bounds. Built-ins: `default` and `root`.

## Related

- [Policies (ACLs)](../concepts/openbao-policies.md)
- [Tokens](../concepts/openbao-tokens.md)
- [Identity](../concepts/openbao-identity.md)
- [OpenBao](../entities/openbao.md)
