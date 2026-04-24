---
title: "Awesome Nix (nix-community)"
tags: [nix, nixos, nixpkgs, ecosystem, curated-list]
sources: [awesome-nix.md]
updated: 2026-04-23
---

# Awesome Nix

Community-curated list of the best resources in the Nix ecosystem. Maintained at `nix-community/awesome-nix`.

## Learning

| Resource                   | Notes                                                    |
| -------------------------- | -------------------------------------------------------- |
| [nix.dev](https://nix.dev) | Official opinionated guide; tutorials and best practices |
| Nix Pills                  | Classic deep-dive tutorial series on nixos.org           |
| Zero to Nix                | Flake-centric intro by Determinate Systems               |
| Tour of Nix                | Interactive browser-based Nix language tutorial          |
| Explainix                  | Visual Nix syntax explainer                              |
| NixOS & Flakes Book        | Unofficial beginner book; opinionated flakes workflow    |

## Discovery Tools

| Tool                       | Purpose                                            |
| -------------------------- | -------------------------------------------------- |
| Noogle                     | Nix API/function search by type signature          |
| nix-search-tv              | CLI fuzzy finder for packages and options          |
| Home Manager Option Search | Browse all 2000+ HM options                        |
| Searchix                   | Search packages across NixOS, Darwin, Home Manager |

## Deployment Tools

| Tool      | Notes                                                           |
| --------- | --------------------------------------------------------------- |
| Colmena   | Stateless NixOS deployment (like NixOps but simpler)            |
| deploy-rs | Multi-profile flake deploy tool by Serokell                     |
| NixOps    | Official Nix deployment tool; AWS, Hetzner support              |
| morph     | Manage existing NixOS hosts                                     |
| nixidy    | Kubernetes GitOps with Nix + Argo CD                            |
| Nixery    | Docker-compatible registry that builds images on demand via Nix |
| comin     | Continuously pull and apply from Git                            |

## Development

| Tool             | Purpose                                                     |
| ---------------- | ----------------------------------------------------------- |
| devenv           | Dev shell environments; cachix-hosted                       |
| flake.parts      | Modular flake framework; community modules ecosystem        |
| nix-direnv       | Fast direnv integration for Nix flakes                      |
| lorri            | Enhanced `nix-shell` for development; augments direnv       |
| Cachix           | Hosted binary cache; free for OSS                           |
| dream2nix        | Auto-convert packages from other build systems to Nix       |
| nix2container    | Efficient container building from Nix without Docker daemon |
| compose2nix      | Generate NixOS config from Docker Compose                   |
| pre-commit-hooks | Run linters/formatters at commit time via Nix               |
| niv/npins        | Dependency pinning for pre-flake Nix projects               |
| nil / nixd       | Nix language servers (LSP) for editors                      |
| MCP-NixOS        | MCP server for AI assistant NixOS/Nixpkgs queries           |

## CLI Tools

| Tool               | Purpose                                          |
| ------------------ | ------------------------------------------------ |
| statix             | Linter/fixer for Nix antipatterns                |
| deadnix            | Find dead code in Nix files                      |
| nixfmt / alejandra | Code formatters for Nix                          |
| comma (`,`)        | Run any binary without installing it (`nix run`) |
| nix-tree           | Browse derivation dependency graph interactively |
| nix-diff           | Explain why two derivations differ               |
| nvd                | Diff package versions between NixOS generations  |
| nix-index          | Locate packages by file content                  |
| nh                 | Better output for nixos-rebuild / home-manager   |

## Language-Specific Bridges

| Language | Tool(s)                                                         |
| -------- | --------------------------------------------------------------- |
| Python   | poetry2nix, uv2nix                                              |
| Rust     | crane (incremental caching), naersk, fenix (nightly toolchains) |
| Node.js  | node2nix, npmlock2nix, napalm                                   |
| Haskell  | haskell.nix, cabal2nix                                          |
| Ruby     | Bundix, ruby-nix                                                |
| PHP      | composer2nix, nix-phps                                          |

## NixOS Modules

| Module         | Purpose                                                 |
| -------------- | ------------------------------------------------------- |
| Home Manager   | User dotfile/package management via NixOS-style modules |
| nix-darwin     | macOS system configuration like NixOS                   |
| impermanence   | Declare persistent files; rest wiped on reboot          |
| nix-mineral    | Convenient, opinionated NixOS security hardening        |
| nix-bitcoin    | Bitcoin node modules with security focus                |
| NixOS hardware | Hardware-specific optimization profiles                 |
| NixOS-WSL      | Run NixOS in Windows Subsystem for Linux                |

## Security-Relevant Notes

- **nix-mineral** — NixOS security hardening module; conveniently applies CIS/security benchmarks
- **impermanence** — architectural enforced immutability; OS state wiped each boot except declared paths
- **Nixery** — build minimal containers on demand; no Dockerfiles; integrates with distroless approach
- **nix2container** — builds containers without Docker daemon; pairs well with OCI scanning pipelines

## Community

- Discourse: `discourse.nixos.org`
- Matrix: `#nix:nixos.org`
- Official wiki: `wiki.nixos.org`
- Annual conference: NixCon

## See Also

- [Nix](../entities/nix.md)
- [Nix Language](../concepts/nix-language.md)
- [Atomic Linux](../concepts/atomic-linux.md)
- [Awesome Atomic](awesome-atomic.md)
