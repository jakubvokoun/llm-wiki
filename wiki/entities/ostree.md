---
title: "OSTree (libostree)"
tags: [ostree, atomic, immutable-os, linux, versioning, upgrades]
sources:
  [
    awesome-atomic.md,
    ostree-introduction.md,
    ostree-atomic-rollbacks.md,
    ostree-repository-management.md,
    ostree-bootloaders.md,
  ]
updated: 2026-04-17
---

# OSTree (libostree)

**OSTree** (also called libostree) is a content-addressed, Git-like versioning system for
**bootable OS filesystem trees**. It is the foundational technology behind Fedora Atomic
(Silverblue, Kinoite, CoreOS), EndlessOS, and other atomic Linux distributions.

- **Type:** Open source library + CLI tool
- **Maintainer:** GNOME / ostreedev community
- **Repository:** `github.com/ostreedev/ostree`

## Core Architecture

```
/ostree/
  repo/                    ← content-addressed object store (like .git/)
  deploy/
    $STATEROOT/
      $CHECKSUM/           ← deployment root (hardlinks into repo)
        usr/               ← read-only bind mount
        etc/               ← writable copy (3-way merged per upgrade)
      var -> /var           ← shared mutable state across deployments
```

## Key Properties

| Property                | Detail                                                       |
| ----------------------- | ------------------------------------------------------------ |
| **Atomic updates**      | New tree staged alongside current; activated on reboot       |
| **Instant rollback**    | Previous deployment retained; boot into it at any time       |
| **Deduplication**       | Hardlinks between deployments; only new files cost disk      |
| **Mutable state**       | Only `/etc` (per-deployment) and `/var` (shared) are mutable |
| **`/etc` 3-way merge**  | Local changes merged into new default on upgrade             |
| **Filesystem agnostic** | Works on ext4, btrfs, XFS; optionally leverages btrfs        |

## What It Is Not

- **Not a package manager.** OSTree manages complete bootable trees. Use rpm-ostree, apt, or
  similar on top for per-package semantics.
- **Not a VM/image replacement.** Complements qcow2/AMI; best for bare-metal stateful systems.

## Layered Tools

- **rpm-ostree** — RPM package layer on top of OSTree (Fedora Atomic)
- **BootC** — OCI container image → bootable OSTree deployment (emerging standard)
- **apt2ostree** — Debian/Ubuntu tree building into OSTree

## Relation to OCI Containers

OCI containers and OSTree are converging: **BootC** and rpm-ostree's native-container mode
allow standard OCI images to serve as OS images, making the OS a first-class container artifact.

## Repository Management

OSTree supports a layered **dev/prod pipeline** model:

- `repo-build` (bare-user) → `repo-dev` (archive, many branches for CI stages) →
  `repo-prod` (archive, public branches only)
- Promote content via `pull-local` using checksums (not branch names) to hide internal stage
  branches from prod
- Generate static deltas and update summary file after each prod release
- Prune dev repo with `prune --refs-only --keep-younger-than=...`

See [Repository Management source page](../sources/ostree-repository-management.md).

## Bootloader Integration

OSTree writes [Boot Loader Specification](https://uapi-group.org/specifications/specs/boot_loader_specification/)
(BLS) entries to `/boot/loader/entries`. On Fedora derivatives GRUB reads them via `blscfg`
with no extra scripting. Three supported configurations:

- **GRUB + blscfg** (modern, default) — BLS entries read directly
- **Legacy GRUB** — `ostree-grub2` script invokes `grub2-mkconfig` automatically
- **bootupd** — static GRUB config; set `sysroot.bootloader = none` (except s390x)
- **Android aboot** — A/B slot flipping via `aboot-update` + `aboot-deploy`; BLS used only
  as metadata

See [OSTree Bootloader Integration](../sources/ostree-bootloaders.md).

## Related

- [Atomic Linux](../concepts/atomic-linux.md)
- [Fedora](../entities/fedora.md)
- [Immutable Infrastructure](../concepts/immutable-infrastructure.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)

## Sources

- [Awesome Atomic](../sources/awesome-atomic.md)
- [OSTree Introduction](../sources/ostree-introduction.md)
- [OSTree Atomic Rollbacks](../sources/ostree-atomic-rollbacks.md)
- [OSTree Repository Management](../sources/ostree-repository-management.md)
- [OSTree Bootloader Integration](../sources/ostree-bootloaders.md)
