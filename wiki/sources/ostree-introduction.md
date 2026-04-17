---
title: "OSTree Introduction"
tags: [ostree, atomic, immutable-os, linux, versioning, upgrades]
sources: [ostree-introduction.md]
updated: 2026-04-17
---

# OSTree Introduction

Official introduction to OSTree — an upgrade system for Linux-based operating systems that
performs **atomic upgrades of complete filesystem trees**.

## Key Takeaways

1. **"Git for OS binaries."** Content-addressed object store with branches (refs) tracking
   filesystem trees. Commit/checkout semantics, deduplication via hardlinks.
2. **Not a package manager.** OSTree manages complete bootable trees, not individual
   packages. Use rpm-ostree or similar for the package layer on top.
3. **Two mutable directories survive upgrades:** `/etc` and `/var`. All other paths under
   the deployed tree are read-only.
4. **3-way merge for `/etc`.** On upgrade, OSTree diffs the old default `/etc`, new default
   `/etc`, and your local `/etc`, and merges local changes into the new tree.
5. **Parallel deployments.** Multiple OS versions can coexist at
   `/ostree/deploy/$STATEROOT/$CHECKSUM`; disk cost is proportional only to new files
   (hardlink deduplication).
6. **Block-device agnostic.** Works on ext4, btrfs, XFS — any filesystem supporting
   hardlinks. Optionally exploits btrfs features if available.
7. **Can coexist with image-based deployments.** Complements rather than replaces
   virtualization images (AMI, qcow2); best suited for bare-metal stateful systems.

## Architecture

```
/ostree/
  repo/                    ← content-addressed object store
  deploy/
    $STATEROOT/
      $CHECKSUM/           ← deployment root (hardlinks into repo)
        usr/               ← read-only bind mount
        etc/               ← writable copy, 3-way merged per upgrade
      var -> /var           ← shared mutable state (symlink)
```

## CLI Quickstart

```bash
ostree --repo=repo init
ostree --repo=repo commit --branch=myos /path/to/tree/
ostree --repo=repo refs
ostree --repo=repo checkout myos /path/to/output/
```

## vs. Package Managers

| Aspect       | Package manager (rpm/dpkg)    | OSTree                           |
| ------------ | ----------------------------- | -------------------------------- |
| Unit         | Partial filesystem + metadata | Complete bootable tree           |
| Assembly     | Client-side, dynamic          | Server-side (or client overlay)  |
| Dependencies | Tracked explicitly            | Not tracked (baked in)           |
| Rollback     | Complex or impossible         | Always available (prev commit)   |
| Atomicity    | No — updates in place         | Yes — new tree staged, then swap |

## Related

- [OSTree entity](../entities/ostree.md)
- [Atomic Linux](../concepts/atomic-linux.md)
- [Immutable Infrastructure](../concepts/immutable-infrastructure.md)
