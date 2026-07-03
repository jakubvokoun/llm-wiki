---
title: "OpenBao — Identity"
tags: [openbao, identity, entities, groups, aliases, authorization]
sources: [openbao-concept-identity.md]
updated: 2026-07-03
---

# OpenBao — Identity

[OpenBao](../entities/openbao.md)'s Identity secrets engine consolidates a client's multiple auth-provider accounts into a single logical identity.

## Entities & aliases

An **Entity** is a consolidated identity made up of zero or more **Aliases**, each alias mapping to one account on an [auth method](openbao-auth-methods.md). A user with GitHub + LDAP accounts → one entity with two aliases. An entity can't have two aliases on the _same_ mount, but can have same-type aliases across _different_ mounts. On login via any non-`token` method, OpenBao implicitly creates an entity + alias if none exists, tying the entity ID to the token (and audit log). Entities are a **cache** of identity, not a source — operators manage them explicitly.

## Entity & group policies

[Policies](openbao-policies.md) assigned to an entity grant **additional** capabilities on top of the token's own policies, **evaluated at request time** — so already-issued tokens gain/lose access as entity policies change. **Groups** contain entities (and subgroups); group policies are inherited by all members, including indirect members of parent groups. **External groups** map (via one alias) to an outside group (LDAP group, GitHub team) and sync membership on login/renewal; **internal groups** are managed manually.

> **Caution:** granting write access to identity endpoints is a privilege-escalation risk — modifying an entity, an alias, or group membership can bind a login to higher privileges.

## Related

- [Auth methods](openbao-auth-methods.md)
- [Policies](openbao-policies.md)
- [Tokens](openbao-tokens.md)
- [OpenBao](../entities/openbao.md)
- [source summary](../sources/openbao-concept-identity.md)
