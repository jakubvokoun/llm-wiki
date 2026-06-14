---
title: "rules_oci README"
tags: [bazel, oci, containers, build-system, container-security]
sources: [rules-oci.md]
updated: 2026-06-14
---

# rules_oci README

[Bazel](../entities/bazel.md) rules for building [OCI](../concepts/oci-images.md) container images (bazel-contrib). Status: unfunded, stable in maintenance mode.

## Key Takeaways

- **Design principles:** keep a tight complexity budget (only off-the-shelf layer/container tools); **stay true to the OCI spec and only the spec** — no language-specific rules, not Docker-specific (works with [Podman](../entities/podman.md) etc.), and use the toolchain **hermetically** (don't assume host Docker).
- **vs rules_img:** rules_oci favors maintainability over optimization; rules_img is recommended for heavy remote-cache/remote-execution use (rules_oci passes many bytes over the network).
- **vs rules_docker:** not a complete replacement (no `container_run_and*` equivalents) but covers most cases; migration guides exist.
- Installed via [Bzlmod](../concepts/bazel-modules.md) (`archive_override`/`git_override`) or `WORKSPACE` `http_archive`.

## Core rules

- `oci_image` (build image), `oci_image_index` (multi-arch), `oci_load` (load into daemon / produce tarball).
- `oci_pull` (uses Bazel downloader, falls back to curl), `oci_push` (publish to registry).
- **System packages** come from companions: `rules_apko` for Alpine/Wolfi `apk`, [rules_distroless](rules-distroless.md) for Debian `.deb` (no RHEL/yum support yet).
- Testing via container-structure-test; signing via `cosign_sign`/`cosign_attest` (developer preview).

## Related

- [OCI Images](../concepts/oci-images.md) · [Distroless](../entities/distroless.md) · [rules_distroless](rules-distroless.md) · [Bazel](../entities/bazel.md)
