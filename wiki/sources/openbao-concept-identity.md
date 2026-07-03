---
title: "OpenBao — Identity (concept)"
tags: [openbao, identity, entities, groups, aliases]
sources: [openbao-concept-identity.md]
updated: 2026-07-03
---

# OpenBao — Identity (concept)

Source summary. Full synthesis: [Identity](../concepts/openbao-identity.md).

## Key Takeaways

- An **Entity** consolidates a client's accounts across [auth methods](../concepts/openbao-auth-methods.md); each account maps to an **Alias** (one per mount). Implicit entities are created on login; OpenBao caches identity, doesn't source it.
- **Entity policies** grant _additional_ capabilities evaluated at request time (affect already-issued tokens).
- **Groups** (and subgroups) propagate policies to members; **external groups** sync membership from LDAP/GitHub on login/renewal.
- Write access to identity endpoints is a privilege-escalation risk.

## Related

- [Identity](../concepts/openbao-identity.md)
- [Policies](../concepts/openbao-policies.md)
- [Auth methods](../concepts/openbao-auth-methods.md)
- [OpenBao](../entities/openbao.md)
