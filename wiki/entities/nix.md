---
title: "Nix"
tags: [nix, package-manager, build-system, nixos, nixpkgs]
sources: [nix-language-tutorial.md, nix-best-practices.md]
updated: 2026-04-23
---

# Nix

Purely functional package manager and build system. Uses the [Nix language](../concepts/nix-language.md) to describe reproducible, hermetic builds stored in `/nix/store`. Foundation for NixOS (declarative OS) and Nixpkgs (world's largest software distribution with ~100k packages).

## Core Components

| Component  | Role                                                             |
| ---------- | ---------------------------------------------------------------- |
| Nix daemon | Build coordinator; manages the Nix store                         |
| Nix store  | Immutable content-addressed directory `/nix/store/<hash>-<name>` |
| Nixpkgs    | Monorepo of ~100k package expressions in Nix language            |
| NixOS      | Linux distro configured declaratively with Nix modules           |
| Nix flakes | Reproducible, pinned project inputs (experimental → stable)      |

## Key Properties

- **Reproducible** — same inputs always produce same outputs
- **Atomic** — installs/upgrades never leave system half-broken
- **Multi-user** — per-user package environments via profiles
- **Rollback** — switch to any previous generation instantly
- **Cross-platform** — Linux and macOS (nix-darwin)

## Ecosystem

- **home-manager** — Nix-managed user dotfiles and packages
- **devenv.sh** — Developer environment management
- **nixpkgs overlays** — Extend/override package set
- **Universal Blue** — Nix tooling on Fedora Atomic images

## Relationship to OSTree

Both solve distribution and immutability — at different layers. OSTree handles the OS image layer (kernel, system binaries); Nix handles user-land package management and developer environments. They are complementary. See [Atomic Linux](../concepts/atomic-linux.md).

## See Also

- [Nix Language](../concepts/nix-language.md)
- [Nix Language Basics Tutorial](../sources/nix-language-tutorial.md)
- [Atomic Linux](../concepts/atomic-linux.md)
- [OSTree](ostree.md)
