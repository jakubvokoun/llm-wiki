---
title: "Fedora / Fedora Atomic"
tags: [fedora, linux, atomic, ostree, rpm-ostree, redhat]
sources: [awesome-atomic.md]
updated: 2026-04-17
---

# Fedora / Fedora Atomic

**Fedora** is a community Linux distribution sponsored by Red Hat. The **Fedora Atomic**
family refers to its immutable, OSTree-based editions.

- **Type:** Linux distribution family
- **Sponsor:** Red Hat / IBM
- **Atomic technology:** rpm-ostree on top of [OSTree](../entities/ostree.md)

## Atomic Editions

| Edition              | Desktop / Use case         |
| -------------------- | -------------------------- |
| Fedora Silverblue    | GNOME desktop              |
| Fedora Kinoite       | KDE Plasma desktop         |
| Fedora COSMIC Atomic | System76 COSMIC desktop    |
| Fedora Sway Atomic   | Sway tiling WM             |
| Fedora Budgie Atomic | Budgie desktop             |
| Fedora CoreOS        | Server / container hosting |

## Universal Blue (Community Layer)

**Universal Blue** is an independent community organization that builds and distributes
customized OCI images on top of Fedora Atomic:

- **Bazzite** — gaming-focused (based on Kinoite)
- **Bluefin** — developer-focused (based on Silverblue)
- **Aurora** — general-purpose (based on Kinoite)
- **uCore** — server-focused (based on CoreOS)

## Related Concepts

- [Atomic Linux](../concepts/atomic-linux.md)
- [Immutable Infrastructure](../concepts/immutable-infrastructure.md)

## Sources

- [Awesome Atomic](../sources/awesome-atomic.md)
