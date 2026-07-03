---
title: "OpenBao — Namespaces"
tags: [openbao, namespaces, multi-tenancy, isolation, delegation]
sources: [openbao-concept-namespaces.md]
updated: 2026-07-03
---

# OpenBao — Namespaces

Secure multi-tenancy (SMT) within a single [OpenBao](../entities/openbao.md) instance — isolated **tenants** with delegated administration.

## What a namespace is

Creating a namespace establishes an isolated environment with its own login paths — effectively a mini-OpenBao — containing its own secret engines, [auth methods](openbao-auth-methods.md), [policies](openbao-policies.md) (ACL/EGP/RGP), password policies, entities, identity groups, and tokens. Solves tenant isolation (org/compliance requirements like GDPR) and long-term management as tenant count grows.

## Hierarchy & delegation

- **Child namespaces** nest inside parents (path `A/B/C`: `A` under root, `B` child of `A`, etc.). Children can inherit/reference parent entities and groups; parents can assert policies on child identities.
- System admins grant **delegate admins** rights to self-manage a namespace and create nested child namespaces — but a child admin can't escape the namespace's limits.
- **Naming:** can't end in `/`, contain spaces, or be a reserved word (`root`, `sys`, `audit`, `auth`, `cubbyhole`, `identity`, `.`, `..`).

## API routing

Target a namespace with the `X-Vault-Namespace` header (absolute or relative path) or by prefixing the path. E.g. all of these hit `ns1/ns2/secret/foo`: path `ns1/ns2/secret/foo`; path `secret/foo` + header `ns1/ns2/`; path `ns2/secret/foo` + header `ns1/`. Manage via `/sys/namespaces` or the `namespace` CLI.

## Restricted `sys/` paths

Sensitive system endpoints (`sys/audit`, `sys/seal`, `sys/init`, `sys/rekey`, `sys/raw`, `sys/generate-root`, `sys/step-down`, `sys/quotas/*`, and many more) are callable **only from the root namespace** — never from child namespaces.

## Related

- [Policies](openbao-policies.md)
- [Identity](openbao-identity.md)
- [Auth methods](openbao-auth-methods.md)
- [OpenBao](../entities/openbao.md)
- [source summary](../sources/openbao-concept-namespaces.md)
