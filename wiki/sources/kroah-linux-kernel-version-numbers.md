---
title: "Linux kernel version numbers (kroah.com)"
tags: [linux-kernel, stable-kernel, longterm, versioning, releases]
sources: [kroah-linux-kernel-version-numbers.md]
updated: 2026-06-05
---

# Linux kernel version numbers

Greg Kroah-Hartman explains the kernel's release/versioning model — essential background for tracking security fixes, because groups that misunderstand it make false CVE/version claims. Part of the [CVE release process series](kroah-linux-cves-overview.md).

## Two rules to remember

1. **Every release is stable** and backwards-compatible for userspace. Since 2.6.0 (Dec 2003), regressions are always prioritized over new features — so no user has a reason to stay on an old kernel, and upgrading carries no risk.
2. **Higher major.minor = newer**, and nothing else. Releases are time-based (~every 10 weeks after a 2-week merge window); the version number just increments.

## Major.Minor.Stable

- **Minor** bumps every release Linus makes; **major** bumps every few years when minor gets large. The `major.minor` pair is the **branch**; **stable** increments per stable release on that branch (e.g. `5.2.1`, `5.2.2`, …).
- A branch is forked at `x.y.0`; stable maintainers backport fixes that are **already in Linus's tree** (the cardinal [stable-kernel rule](https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html)), so upgrading `5.2 → 5.3` never regresses a fix that was only in `5.2.stable`.
- `5.4.y` notation refers to the stable branch for the 5.4 release.

## Branches end — and one becomes longterm

Stable branches stop a few weeks after the next minor release. **One branch per year** (usually the year's last) is chosen as **longterm**, supported ≥2 years (see kernel.org [releases](https://www.kernel.org/category/releases.html)).

## Why this matters for CVEs

You **cannot** treat version numbers as linearly comparable. It is NOT safe to assume "if this version > previous, all its fixes are in the next release." Each kernel branch is a **unique tree**; you must walk each branch independently to track fixes over time — the core reason kernel CVEs encode git/version **ranges** rather than scalar versions.

## Related

- [Greg Kroah-Hartman](../entities/greg-kroah-hartman.md)
- [Tracking kernel commits across branches](kroah-tracking-kernel-commits.md)
- [Linux CVE assignment process](kroah-linux-cve-assignment-process.md)
