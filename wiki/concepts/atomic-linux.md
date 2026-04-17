---
title: "Atomic Linux"
tags: [atomic, immutable-os, ostree, flatpak, linux, desktop, updates]
sources: [awesome-atomic.md]
updated: 2026-04-17
---

# Atomic Linux

A class of Linux distributions where the **root filesystem is read-only** and OS updates are
applied **atomically** — either fully committed or fully rolled back, with no partial states.

## Core Properties

| Property             | Description                                                           |
| -------------------- | --------------------------------------------------------------------- |
| **Immutable root**   | `/usr` and system dirs are read-only; no in-place mutation            |
| **Atomic updates**   | New OS tree deployed as a whole; active only after reboot             |
| **Instant rollback** | Previous deployment retained; reboot to previous on failure           |
| **Reproducibility**  | Same image produces identical systems; eliminates configuration drift |

## How It Works (OSTree model)

```
current OS tree (read-only)
     ↓
new image fetched/built (as OCI or OSTree commit)
     ↓
staged alongside current
     ↓
reboot → new tree becomes active; old tree retained for rollback
```

The root is a **read-only bind mount** of the current tree. `/var` (user data, databases) and
`/etc` (host config) remain mutable across reboots.

## Application Layer

Atomic OSes separate **OS image** from **applications**:

- **[Flatpak](../entities/flatpak.md)** — sandboxed apps distributed via Flathub; independent of OS updates
- **Distrobox / Toolbx** — mutable container environments for development workflows
- **Layered packages** (rpm-ostree) — small number of host-level packages compiled into the image

## Technology Variants

| Approach             | Used by                  | Mechanism                           |
| -------------------- | ------------------------ | ----------------------------------- |
| OSTree/rpm-ostree    | Fedora Atomic, EndlessOS | Content-addressed tree + RPM layer  |
| Nix store            | NixOS, Guix System       | Functional package derivations      |
| transactional-update | openSUSE MicroOS/Aeon    | btrfs snapshots + zypper            |
| ABRoot               | VanillaOS                | A/B root partitions via OCI updates |
| BootC                | emerging standard        | OCI container image = bootable OS   |

## Security Advantages

- **No in-place patching** → no window where system is partially updated
- **Rollback eliminates bricked systems** from bad updates
- **Signed OS images** → [Supply Chain Security](../concepts/supply-chain-security.md) extends to OS layer
- **Reduced attack persistence**: modifications to root don't survive reboot
- **Containers for mutability** → development work isolated from host

## Relation to Immutable Infrastructure

[Immutable Infrastructure](../concepts/immutable-infrastructure.md) applied to the OS layer.
The same "replace don't patch" principle from infrastructure-as-code extends to the operating
system itself.

## Key Projects

- **[OSTree](../entities/ostree.md)** — foundational versioning layer
- **[Fedora](../entities/fedora.md)** — largest atomic desktop ecosystem (Silverblue, Kinoite, CoreOS)
- **[Flatpak](../entities/flatpak.md)** — canonical app delivery for atomic desktops
- **[Distrobox](../entities/distrobox.md)** — mutable containers on immutable hosts

## Sources

- [Awesome Atomic](../sources/awesome-atomic.md)
- [OSTree Related Projects](../sources/ostree-related-projects.md)
