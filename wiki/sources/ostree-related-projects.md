---
title: "OSTree Related Projects"
tags: [ostree, atomic, comparison, nix, docker, btrfs, chromeos, updates]
sources: [ostree-related-projects.md]
updated: 2026-04-17
---

# OSTree Related Projects

Source: `raw/ostree-related-projects.md` — OSTree official comparison of approaches to
atomic/image-based OS updates.

## Key Takeaways

1. **Two camps** — client-side snapshot tools (dpkg/rpm + BTRFS/LVM) vs server-compose-and-replicate (ChromiumOS, Clear Linux); OSTree is flexible enough for both.
2. **OSTree vs BTRFS/rpm** — BTRFS requires careful subvolume layout and doesn't handle `/etc` merging well; OSTree solves `/etc` natively via 3-way merge; OSTree works without root (bare-user); OSTree writes updates offline (new root), preventing mid-update inconsistency.
3. **OSTree vs ChromiumOS A/B** — Chromium always doubles disk (two full partitions); OSTree uses hardlinks so only changed files cost space; OSTree supports >2 deployments simultaneously.
4. **OSTree vs casync** — casync lacks: GPG signatures, versioning metadata, `/etc` merge, SELinux awareness, server-side GC.
5. **OSTree vs NixOS** — Nix hashes build inputs (cascading rebuilds on any dep change, e.g. glibc security update forces full rebuild); OSTree hashes content and supports incremental per-component rebuilds; OSTree uses standard FHS layout vs content-addressed store paths.
6. **OSTree vs Docker** — OSTree checksums individual files (not compressed tarballs), enabling content-level dedup; OSTree has static deltas for wire efficiency; Docker has layering model (OSTree can emulate this at higher layers, e.g. Flatpak SDK/runtime split); Docker checksums compressed data making verification harder.
7. **rpm-ostree** — hybrid model: RPM package layer on top of OSTree; supports on-the-fly package composition via overlay filesystem; OSTree author's preferred direction.
8. **Flatpak** uses libostree for application data (not host system management).
9. **OSTree vs Git** — both content-addressed; OSTree uses SHA256 (not SHA1), hardlinks (not copy), max 1 parent per commit, HTTP-per-file or static deltas (not smart pack protocol).
10. **Torizon** — embedded Linux platform using OSTree + Aktualizr for OTA updates.

## Comparison Table

| Project              | Approach                    | OSTree advantage over it                                         |
| -------------------- | --------------------------- | ---------------------------------------------------------------- |
| BTRFS/LVM + rpm/dpkg | Client-side block snapshots | Native `/etc` merge; block-layer agnostic; no root required      |
| ChromiumOS A/B       | Dual-partition swap         | Hardlinks → proportional disk use; >2 deployments possible       |
| casync               | Content-addressed storage   | Signatures, sysroot management, `/etc` merge, GC, SELinux        |
| NixOS / Nix          | Input-hashed derivations    | Incremental builds; standard FHS; no cascading security rebuilds |
| Docker (for OS)      | Layer-based tarball format  | Per-file checksums; static deltas; offline update safety         |
| Ubuntu IBU           | ChromeOS-style A/B          | Same as ChromiumOS + package layering (rpm-ostree model)         |

## Inspirations

OSTree was influenced by:

- Systemd Stateless and Bootloader Spec
- Chromium Autoupdate (delta approach)
- Fedora/Red Hat Stateless Project
- Linux VServer vhashify (hardlink deduplication)
- GNOME Continuous (the original motivation — incremental CI for GNOME)

## Related

- [OSTree (entity)](../entities/ostree.md)
- [Atomic Linux](../concepts/atomic-linux.md)
- [Immutable Infrastructure](../concepts/immutable-infrastructure.md)
- [OSTree Data Formats](ostree-formats.md) — static delta and archive format details
