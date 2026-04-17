---
title: "Awesome Atomic"
tags: [atomic, immutable-os, ostree, flatpak, linux, desktop]
sources: [awesome-atomic.md]
updated: 2026-04-17
---

# Awesome Atomic

Curated knowledge-base for **atomic/immutable Linux systems** — OS distributions where the
root filesystem is read-only and updates are applied atomically (all-or-nothing, with rollback).

## Key Takeaways

1. **Atomic OS = immutable root + atomic updates.** Root is read-only; updates deploy a new
   image and swap on next boot. Rollback to the previous deployment is always possible.
2. **OSTree is the foundational layer** for most RPM/deb-based atomic distros
   (Fedora Atomic, EndlessOS). NixOS and Guix use a different functional model.
3. **Flatpak is the canonical app delivery mechanism** on atomic desktops — apps ship as
   sandboxed OCI-like bundles independent of the OS image.
4. **Toolboxes (Toolbx, Distrobox)** bridge the mutability gap: transparent container
   environments where users can install arbitrary packages without touching the host.
5. **OCI images as OS units.** BootC and rpm-ostree's native-container mode let you build
   and ship OS images as standard OCI container images — blurring OS and container layers.
6. **Universal Blue** is a community org building derivative images on top of Fedora Atomic
   (Bazzite for gaming, Bluefin for developers, Aurora for general use).

## Distribution Landscape

| Distro              | Base       | Technology        | Focus              |
| ------------------- | ---------- | ----------------- | ------------------ |
| Fedora Silverblue   | Fedora     | rpm-ostree/OSTree | GNOME desktop      |
| Fedora Kinoite      | Fedora     | rpm-ostree/OSTree | KDE Plasma desktop |
| Fedora CoreOS       | Fedora     | rpm-ostree/OSTree | Server/containers  |
| openSUSE MicroOS    | openSUSE   | transactional-upd | Server             |
| openSUSE Aeon/Kalpa | openSUSE   | transactional-upd | GNOME/KDE desktop  |
| NixOS               | Nix        | Nix store         | Declarative Linux  |
| Guix System         | Guix       | Guix store        | GNU/free software  |
| SteamOS             | Arch       | custom            | Gaming console OS  |
| VanillaOS           | Debian Sid | ABRoot/OSTree     | Beginner-friendly  |
| Kairos              | various    | Elemental Toolkit | Edge Kubernetes    |
| Bazzite             | Fedora     | rpm-ostree (UB)   | Desktop gaming     |
| Bluefin             | Fedora     | rpm-ostree (UB)   | Developer desktop  |

## Core Tooling

- **[OSTree](../entities/ostree.md)** — content-addressed OS tree versioning; bootable checkouts
- **rpm-ostree** — RPM layer on top of OSTree; layered packages
- **BootC** — OCI image → bootable OS (experimental/emerging)
- **[Flatpak](../entities/flatpak.md)** — sandboxed application delivery
- **[Distrobox](../entities/distrobox.md)** / **Toolbx** — mutable container overlays on immutable hosts
- **ABRoot** — A/B root partition transactional updates (VanillaOS)
- **frzr** — btrfs subvolume deployment (ChimeraOS)

## Related Concepts

- [Immutable Infrastructure](../concepts/immutable-infrastructure.md)
- [Atomic Linux](../concepts/atomic-linux.md)
- [Supply Chain Security](../concepts/supply-chain-security.md) — OCI signing applies to OS images too

## Sources

- [Awesome Atomic](../sources/awesome-atomic.md) — this page
