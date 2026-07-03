---
title: "Chainguard Containers Overview"
tags: [container-security, supply-chain-security, distroless, chainguard]
sources: [chainguard-images.md]
updated: 2026-06-14
---

# Chainguard Containers Overview

Chainguard Academy overview of [Chainguard](../entities/chainguard.md) Containers — minimal, hardened [distroless-style](../concepts/distroless-images.md) images.

## Key Takeaways

- Follow a **distroless philosophy** (only app + essential runtime deps; no shells/package managers), built on **Chainguard OS** ([Wolfi](../entities/wolfi.md)). `-dev` variants add a shell/package manager for debugging.
- **Security guarantees by default:** minimal design, **automated nightly rebuilds** (all available patches; sometimes fix vulns before detection → near/zero CVEs), reproducible builds signed with [Cosign](../concepts/software-attestation.md) + apko.
- Fewer dependencies ⇒ lower CVE likelihood; scanner comparisons (e.g. Grype on nginx) show far fewer CVEs than official images.

## Distribution model

- Registry `cgr.dev` (+ some images on Docker Hub). **Free images** = latest + latest-dev, public. **Production images** add patch SLAs, FIPS readiness, unique time-stamped tags, and specific upstream major/minor versions.
- **Multi-layer images** (since May 2025): per-origin layering groups same-upstream packages so a package update re-downloads only its layer — ~70% less unique layer data; 70–85% fewer bytes on sequential updated pulls.
- Default arches: x86-64-v2 and AArch64 (Armv8-A); verify with `crane manifest ... | jq '.manifests[].platform'`.

## Annotations

Sets standard [OCI](../concepts/oci-images.md) `org.opencontainers.image.*` annotations (authors, base.digest, created, source, title, url, vendor) plus custom `dev.chainguard.*`. Inspect via `crane manifest|config`, `docker inspect`, or `docker history`.

## Related

- [Chainguard](../entities/chainguard.md)
- [Wolfi](../entities/wolfi.md)
- [Distroless Images](../concepts/distroless-images.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [SLSA](../concepts/slsa.md)
