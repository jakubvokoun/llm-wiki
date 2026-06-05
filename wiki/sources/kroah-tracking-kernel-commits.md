---
title: "Tracking kernel commits across branches (kroah.com)"
tags: [linux-kernel, stable-kernel, tooling, cve, git, backporting]
sources: [kroah-tracking-kernel-commits.md]
updated: 2026-06-05
---

# Tracking kernel commits across branches

Greg Kroah-Hartman describes the tooling he built to track which commits have been backported to which [stable/longterm branches](kroah-linux-kernel-version-numbers.md) — work that became essential for managing [CVEs](../concepts/cve.md) at scale. Part of the [CVE release process series](kroah-linux-cves-overview.md).

## The backport breadcrumb

Stable commits record their upstream origin in the first changelog line, in one of two historical formats:

```
commit <SHA1> upstream.
[ Upstream commit <SHA1> ]
```

Because the original git ID is embedded, the logs can be grepped to find where a fix landed.

## Tool 1 — "filesystem as a database"

A [set of scripts](https://git.sr.ht/~gregkh/linux-stable_commit_tree) mirror all changelog texts into a separate git repo of plain text files (`ids/`, `releases/`, `changes/`), searchable with `git grep`/`ripgrep` without checking out branches. Lets you answer "where was this backported?" (~0.3s) and "was this commit later fixed?" via the `Fixes:` tag. Needs only git + bash (good for restricted environments) — but kernel logs sometimes lie about backport IDs, so it isn't comprehensive.

## Tool 2 — verhaal (SQLite)

[verhaal](https://git.sr.ht/~gregkh/verhaal) parses all commit logs across branches into a normalized SQLite database (`releases`, `ranges`, `fixes` tables) with fields like `mainline_id`, `reverts`, `fixes`. Backport lookups drop to **0.01s**, and "was this commit fixed elsewhere?" becomes a single SQL query — critical at CVE-tracking volume. A manual `fixes.txt` overrides changelogs that contain wrong git IDs. Written in C (GKH says he'd use Rust today).

## Takeaway

The 6.18 kernel git repo has 1,863,462 commits across 4,631 releases. Manual cross-branch tracking doesn't scale; automated commit-graph tooling is the foundation that makes accurate, high-volume CVE range data possible.

## Related

- [Greg Kroah-Hartman](../entities/greg-kroah-hartman.md)
- [Linux kernel version numbers](kroah-linux-kernel-version-numbers.md)
- [Linux CVE assignment process](kroah-linux-cve-assignment-process.md)
