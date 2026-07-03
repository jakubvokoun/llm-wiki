---
title: "Distroless Images"
tags: [container-security, supply-chain-security, distroless, containers]
sources: [distroless.md, chainguard-images.md, wolfi.md]
updated: 2026-06-14
---

# Distroless Images

A container-image design pattern: ship **only the application and its runtime dependencies** — no shell, no package manager, no coreutils, no general-purpose userland. The goal is a minimal attack surface and minimal CVE/provenance burden, not runtime isolation.

## Why minimal images

- **Fewer dependencies → fewer CVEs.** Scanners report far less noise; less software means fewer things to patch.
- **Smaller size** — faster pulls, less data transferred. Google [distroless](../entities/distroless.md) `static` is ~2 MiB vs `debian` 124 MiB.
- **Reduced post-exploitation tooling** — no shell or package manager for an attacker to pivot through. (But see the security caveat below.)

## The debug-variant tradeoff

Because there is no shell, these images are harder to debug. Both ecosystems ship a debug/dev variant that re-adds a shell and tools:

- Google distroless: `:debug` / `:debug-nonroot` (busybox shell).
- [Chainguard](../entities/chainguard.md): `-dev` variants (e.g. `:latest-dev`).

Using a `:debug`/`-dev` variant in production reintroduces the attack surface you removed.

## Two implementation approaches

|                      | Google [distroless](../entities/distroless.md)                                     | [Chainguard](../entities/chainguard.md) / [Wolfi](../entities/wolfi.md) |
| -------------------- | ---------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Base                 | Stripped-down Debian                                                               | Wolfi — a container-native distro built _for_ this use case             |
| Updates              | Track upstream Debian via automated PRs                                            | Continuous nightly rebuilds                                             |
| Build tooling        | [Bazel](../entities/bazel.md) + [rules_distroless](../sources/rules-distroless.md) | apko + melange                                                          |
| Signing / provenance | [cosign](software-attestation.md) keyless                                          | cosign + per-image SBOM + [SLSA](slsa.md)                               |

## Security caveat

Distroless is an **image-design strategy, not a runtime isolation primitive**. A distroless container can still run `--privileged` with host namespace sharing and be catastrophically insecure. The kernel trust boundary is unchanged — only the userland attack surface shrinks. See [HackTricks — Distroless Containers](../sources/hacktricks-distroless.md). It complements, but does not replace, [container-security](container-security.md) controls (seccomp, capabilities, MAC, non-root, read-only rootfs).

## Related

- [Container Security](container-security.md)
- [Supply Chain Security](supply-chain-security.md)
- [Immutable Infrastructure](immutable-infrastructure.md)
- [OCI Images](oci-images.md)

## Sources

- [Distroless README](../sources/distroless.md)
- [Chainguard Containers overview](../sources/chainguard-images.md)
- [Wolfi README](../sources/wolfi.md)
