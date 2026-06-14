---
title: "Chainguard"
tags: [org, product, container-security, supply-chain-security, distroless]
sources: [chainguard-images.md, wolfi.md]
updated: 2026-06-14
---

# Chainguard

Company producing hardened, minimal container images (**Chainguard Containers**) and the open-source tooling behind them. Their images follow a [distroless philosophy](../concepts/distroless-images.md) and are built on [Wolfi](wolfi.md) (Chainguard OS) using [apko](https://github.com/chainguard-dev/apko) and [melange](https://github.com/chainguard-dev/melange).

## Built-in guarantees

- **Minimal design** — no shells/package managers in production images (`-dev` variants add them for debugging).
- **Automated nightly builds** — images stay current with all available security patches; vulnerabilities are sometimes fixed before they are detected. Near-**zero CVEs** come from continuous rebuilds, not a one-time hardening pass.
- **Reproducible builds**, signed with [Cosign](../concepts/software-attestation.md).
- Standard [OCI](../concepts/oci-images.md) annotations + custom `dev.chainguard.*` annotations on every image.

## Image model

- Registry `cgr.dev`; a selection of **Free images** (latest + latest-dev) is public, **Production images** add patch SLAs, FIPS readiness, and unique time-stamped tags for specific upstream versions.
- **Multi-layer images** (since May 2025) use a per-origin layering strategy: packages from the same upstream source share a layer so a single package update re-downloads only its layer (~70% less unique layer data; 70–85% fewer bytes on sequential updated pulls).
- Default architectures: x86-64-v2 and AArch64 (Armv8-A).

## Relation to distroless

Positioned as an alternative to Google [distroless](distroless.md): same "only app + runtime deps" goal, but built from a purpose-built container-native distro ([Wolfi](wolfi.md), glibc-based) with continuous rebuilds and per-image SBOM/[SLSA](../concepts/slsa.md) attestations, rather than stripped-down Debian.

## Sources

- [Chainguard Containers overview](../sources/chainguard-images.md)
- [Wolfi README](../sources/wolfi.md)
