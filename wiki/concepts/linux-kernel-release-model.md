---
title: "Linux Kernel Release Model"
tags: [linux-kernel, stable-kernel, longterm, versioning, backporting, cve]
sources:
  [kroah-linux-kernel-version-numbers.md, kroah-tracking-kernel-commits.md]
updated: 2026-06-05
---

# Linux Kernel Release Model

How Linux kernel releases are numbered and maintained — foundational for tracking security fixes, because the model defies naive version comparison.

## Two rules

1. **Every release is stable** and userspace-backwards-compatible (since 2.6.0, Dec 2003); regressions outrank features, so upgrading is low-risk.
2. **Higher `major.minor` = newer**, nothing more. Time-based cadence (~10 weeks).

## Major.Minor.Stable

- `major.minor` = the **branch**; **stable** increments per stable release (`5.2.1`, `5.2.2`…). Notation `5.4.y` = the 5.4 stable branch.
- Stable maintainers backport only fixes **already in Linus's tree** (the cardinal [stable-kernel rule](https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html)).
- One branch/year becomes **longterm** (≥2 years support).

## Why naive version comparison breaks

Each branch is an **independent tree**. It is **not** safe to assume a higher version contains all fixes of a lower one — you must walk each branch separately. This is why kernel [CVEs](cve.md) encode git/version **ranges**, and why GKH built commit-tracking tooling (filesystem-as-database scripts; the SQLite **verhaal** tool) to answer "where was this backported?" and "was this commit later fixed?" at CVE-tracking scale.

## Consequence for users

**Take all stable releases**; don't cherry-pick individual CVE fixes (they aren't tested in isolation and may depend on prior commits). You also get data-corruption and performance fixes alongside security fixes.

## Related

- [CVE](cve.md) · [CVE Numbering Authority](cve-numbering-authority.md)
- Sources: [Linux kernel version numbers](../sources/kroah-linux-kernel-version-numbers.md) · [Tracking kernel commits](../sources/kroah-tracking-kernel-commits.md)
