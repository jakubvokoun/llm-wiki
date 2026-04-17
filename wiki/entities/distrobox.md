---
title: "Distrobox"
tags: [distrobox, toolbox, containers, atomic, linux, development]
sources: [awesome-atomic.md]
updated: 2026-04-17
---

# Distrobox

**Distrobox** is a CLI tool that creates transparent, mutable container environments on top
of any Linux host (including immutable atomic systems). Users can install packages freely
inside a Distrobox container while keeping the host OS immutable.

- **Type:** Container frontend (wraps Podman or Docker)
- **Repository:** `github.com/89luca89/distrobox`
- **GUI:** BoxBuddy (GTK4/Libadwaita)

## Problem It Solves

[Atomic Linux](../concepts/atomic-linux.md) distributions have read-only root filesystems.
Developers often need to install arbitrary tools (`gcc`, `python`, `jq`, etc.) without
rebuilding the OS image. Distrobox provides a **mutable container** that integrates
transparently with the host (shared home directory, X11/Wayland, sound, USB).

## Relation to Toolbx

**Toolbx** (by Red Hat/GNOME) is the Fedora-native equivalent. Distrobox is
distribution-agnostic, supports more container images (Debian, Ubuntu, Arch, etc.), and works
with both Podman and Docker. Both serve the same conceptual role.

## Related

- [Atomic Linux](../concepts/atomic-linux.md)
- [Flatpak](../entities/flatpak.md) — app-layer complement for GUI apps
- [Podman](../entities/podman.md)

## Sources

- [Awesome Atomic](../sources/awesome-atomic.md)
