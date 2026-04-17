---
title: "Flatpak"
tags: [flatpak, linux, packaging, sandboxing, desktop]
sources: [awesome-atomic.md]
updated: 2026-04-17
---

# Flatpak

**Flatpak** is a Linux application packaging and distribution system that runs apps in an
**OCI-like sandbox**, isolated from the host OS. It is the canonical application delivery
mechanism for [Atomic Linux](../concepts/atomic-linux.md) distributions.

- **Type:** Application packaging system
- **Primary registry:** Flathub (`flathub.org`)
- **Sandbox:** bubblewrap + portals for controlled host access

## Why Atomic OSes Use Flatpak

Atomic distros have read-only root filesystems — traditional package managers that install
into `/usr` cannot work directly. Flatpak installs into `~/.local/share/flatpak` or
`/var/lib/flatpak`, bypassing this constraint while providing sandboxing.

## Security Properties

- Apps are sandboxed with explicit **portals** for filesystem, camera, microphone access
- Each app ships its own runtime dependencies (no shared library conflicts)
- Flathub enforces metadata review; apps can be signed

## Related

- [Atomic Linux](../concepts/atomic-linux.md)
- [Distrobox](../entities/distrobox.md) — complementary tool for CLI environments
- [Container Security](../concepts/container-security.md)

## Sources

- [Awesome Atomic](../sources/awesome-atomic.md)
