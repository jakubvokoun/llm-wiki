---
title: "Linux CVEs, more than you ever wanted to know (kroah.com)"
tags: [linux-kernel, cve, cna, series-index]
sources: [kroah-linux-cves-overview.md]
updated: 2026-06-05
---

# Linux CVEs, more than you ever wanted to know

The December 2025 series-opener in which Greg Kroah-Hartman sets out to document how the Linux kernel CVE process now works, ~2 years after [becoming a CNA](kroah-linux-is-a-cna.md). The kernel went from issuing no CVEs to **#3 in 2024 to #1 in 2025** by quantity.

## Why the series exists

- The CVE-assignment work lives outside the kernel source tree, so it's invisible to normal development except the [linux-cve-announce](https://lore.kernel.org/linux-cve-announce/) feed.
- Most non-open-source groups don't grasp the kernel's [versioning scheme](kroah-linux-kernel-version-numbers.md), leading to false CVE/version statements.
- GKH spent 2025 working heavily on the EU [CRA](../concepts/cyber-resilience-act.md); the lessons on handling reports "at scale" may help other projects.

## The series (this wiki ingests four of five)

1. [Linux kernel version numbers](kroah-linux-kernel-version-numbers.md)
2. [Tracking kernel commits across branches](kroah-tracking-kernel-commits.md)
3. [Linux kernel security work](kroah-linux-kernel-security-work.md)
4. [Linux CVE assignment process](kroah-linux-cve-assignment-process.md)
5. Linux CVE tools — _future post, not yet published_

## Related

- [Greg Kroah-Hartman](../entities/greg-kroah-hartman.md)
- [CVE](../concepts/cve.md)
- [CVE Numbering Authority](../concepts/cve-numbering-authority.md)
