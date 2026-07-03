---
title: "OpenBao — Namespaces (concept)"
tags: [openbao, namespaces, multi-tenancy, delegation]
sources: [openbao-concept-namespaces.md]
updated: 2026-07-03
---

# OpenBao — Namespaces (concept)

Source summary. Full synthesis: [Namespaces](../concepts/openbao-namespaces.md).

## Key Takeaways

- Secure multi-tenancy in one instance: each namespace is a mini-OpenBao with its own secret engines, [auth methods](../concepts/openbao-auth-methods.md), [policies](../concepts/openbao-policies.md), entities, groups, and tokens.
- **Child namespaces** nest; children can reference parent entities/groups; parents can assert policies on children. Delegate admins self-manage and can nest further but can't escape their limits.
- Target via `X-Vault-Namespace` header (absolute/relative) or path prefix; manage via `/sys/namespaces`.
- Naming excludes trailing `/`, spaces, and reserved words (`root`, `sys`, `audit`, `auth`, `cubbyhole`, `identity`). Many sensitive `sys/` paths are **root-namespace only**.

## Related

- [Namespaces](../concepts/openbao-namespaces.md)
- [Policies](../concepts/openbao-policies.md)
- [Identity](../concepts/openbao-identity.md)
- [OpenBao](../entities/openbao.md)
