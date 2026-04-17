---
title: "AppArmor Core Policy Reference (Draft)"
tags: [apparmor, policy, language, reference, linux]
sources: [apparmor-core-policy-reference.md]
updated: 2026-04-16
---

# AppArmor Core Policy Reference (Draft)

Official (draft) reference for the AppArmor policy language — profile structure,
rule types, globbing syntax, and language versions.

> **Status:** Marked DRAFT by AppArmor project. Content is substantive but may
> be incomplete.

## Policy structure

AppArmor policy is declarative — rule ordering within a block does not matter.
Policy is split into:

1. **Preamble** — global declarations, variables, includes; must appear before
   any profile definitions
2. **Profile definitions** — one or more named profiles containing rule sets

Policy is compiled to an architecture-independent binary format loaded into the
kernel.

## Profile (base unit)

The **profile** is the base confinement unit. It defines a whitelist of allowed
permissions for a confined program. Everything not explicitly allowed is denied.

```
profile <name> [<attachment>] [flags=(<flag_list>)] {
    [rules]
}
```

## Language versions

| Version  | Notes                                                                                                 |
| -------- | ----------------------------------------------------------------------------------------------------- |
| **v2.x** | Implicit permissions: e.g., `capability sys_admin` alone mediates `mount`                             |
| **v3.x** | Explicit permissions required: `capability sys_admin` + `mount` rules both needed for mount mediation |

v2 can be compiled to v3-compatible binary (implicit generic rules added). v3
can target v2-compatible binary (newer mediation types excluded).

## AppArmor globbing syntax

AppArmor uses a bash-like but distinct globbing syntax for path matching:

| Pattern | Meaning                                                   |
| ------- | --------------------------------------------------------- |
| `*`     | Match zero or more chars at one directory level (not `/`) |
| `**`    | Match zero or more chars across multiple directory levels |
| `?`     | Match exactly one char (not `/`)                          |
| `{a,b}` | Alternation — match `a` or `b`                            |
| `[]`    | Character class (same as pcre)                            |
| `[^]`   | Inverted character class                                  |

Examples:

```
/dir/file       - exact file
/dir/*          - any file in /dir/ (incl. dot files)
/dir/**         - any file or directory under /dir/ recursively
/dir/*.png      - any .png in /dir/
/dir/[^.]*      - any non-dot file in /dir/
/dir/*/         - any immediate subdirectory of /dir/
```

Special characters can be escaped with `\`.

## Access modes (file rules)

| Mode | Permission                                        |
| ---- | ------------------------------------------------- |
| `r`  | Read                                              |
| `w`  | Write (create, delete, modify, extend)            |
| `m`  | Memory-map executable                             |
| `x`  | Execute (requires qualifier: `ix`, `px`, `ux`, …) |
| `l`  | Link                                              |
| `k`  | File locking                                      |

## deny rules

- Take precedence over `allow`
- Enforced even in **complain mode**
- Used in abstractions to lock sensitive paths regardless of profile rules
- Silence noisy `aa-logprof` prompts for expected denials

## Variables and abstractions

`@{VAR}` syntax — variables defined in `/etc/apparmor.d/tunables/` (e.g.,
`@{HOME}`, `@{PROC}`).

`#include <abstractions/base>` — pulls in shared rule sets from
`/etc/apparmor.d/abstractions/`.

## See also

- [AppArmor Profiles](../concepts/apparmor-profiles.md)
- [AppArmor](../entities/apparmor.md)
- [AppArmor — Arch Wiki](apparmor-archwiki.md)
- [Docker AppArmor](docker-apparmor.md)
