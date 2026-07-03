---
title: "OCI Images"
tags: [containers, oci, container-security, standards]
sources: [rules-oci.md, chainguard-images.md]
updated: 2026-06-14
---

# OCI Images

The [Open Container Initiative](https://opencontainers.org/) Image Specification — the vendor-neutral standard format for container images that decouples them from Docker specifically. Any compliant runtime (Docker, [Podman](../entities/podman.md), containerd) can run an OCI image.

## Why it matters

Building to the spec rather than to Docker means images and tooling work across runtimes and avoid Docker's commercial-license constraints. [rules_oci](../sources/rules-oci.md) is explicitly "stay true to the specification, and only the specification" — no Docker assumptions, hermetic toolchain, no language-specific rules.

## Building OCI images with Bazel

[rules_oci](../sources/rules-oci.md) provides the core rules:

- `oci_image` — build an image; `oci_image_index` — multi-arch index.
- `oci_pull` / `oci_push` — fetch and publish layers/images to registries.
- `oci_load` — load into a container daemon or produce a loadable tarball.
- System packages come from companion rulesets: [rules_distroless](../sources/rules-distroless.md) for Debian `.deb`, `rules_apko` for Alpine/Wolfi `apk`.

Pairs naturally with [distroless images](distroless-images.md) (Google distroless is built this way) and signing/testing via [cosign](software-attestation.md) and container-structure-test.

## Annotations

The spec defines standard `org.opencontainers.image.*` annotations (authors, base.digest, created, source, title, url, vendor). [Chainguard](../entities/chainguard.md) sets these plus custom `dev.chainguard.*` annotations; inspect with `crane manifest ... | jq .annotations`.

## Related

- [Distroless Images](distroless-images.md)
- [Container Security](container-security.md)
- [Supply Chain Security](supply-chain-security.md)

## Sources

- [rules_oci README](../sources/rules-oci.md)
- [Chainguard Containers overview](../sources/chainguard-images.md)
