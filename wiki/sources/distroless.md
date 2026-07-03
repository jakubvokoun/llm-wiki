---
title: "Distroless README (GoogleContainerTools)"
tags: [container-security, distroless, supply-chain-security, bazel]
sources: [distroless.md]
updated: 2026-06-14
---

# Distroless README (GoogleContainerTools)

Project README for [Distroless](../entities/distroless.md), Google's minimal container base images.

## Key Takeaways

- **Distroless = app + runtime deps only** — no package managers, shells, or other standard-distro programs.
- **Why:** improves CVE-scanner signal-to-noise and reduces provenance burden. Smallest image `gcr.io/distroless/static-debian13` ≈ 2 MiB (vs alpine ~5 MiB, debian 124 MiB).
- Built with [Bazel](../entities/bazel.md), but usable via any Docker build tooling.

## Images

Based on Debian 13 (trixie); tagged with explicit version suffix (`-debian13`) — pin it to avoid breakage when the default rolls to a newer Debian. Tiers: `static`, `base`, `base-nossl`, `cc`, plus language runtimes `java17/21/25`, `nodejs22/24/26`, `python3`. Tags `latest`, `nonroot`, `debug`, `debug-nonroot`; multi-arch indexes (amd64, arm64, arm, s390x, ppc64le, riscv64). Debian 12 images also still published.

## Usage notes

- **No shell** ⇒ `ENTRYPOINT`/`CMD` must use vector (exec) form `["myapp"]`; string form fails. `static`/`base`/`cc` default to empty-vector entrypoint; language images have a runtime-specific default.
- Recommended pattern is a **multi-stage Docker build** — build the artifact in a full image, `COPY --from=build` into the distroless runtime. Example given for Go (`CGO_ENABLED=0`, copy binary into `static-debian13`).
- **`:debug` images** add a busybox shell (`docker run --entrypoint=sh ...`). For an already-tagged image use `debug-<tag>` (e.g. `debug-nonroot`). `ldd` is absent (it's a shell script).

## Verification & updates

- All images **cosign keyless-signed**: `cosign verify $IMAGE --certificate-oidc-issuer https://accounts.google.com --certificate-identity keyless@distroless.iam.gserviceaccount.com`.
- Security/CVE updates track upstream Debian via automated GitHub Actions PRs.
- Still served from `gcr.io` (now backed by Artifact Registry).

## Ecosystem

Bazel image generation via [rules_oci](rules-oci.md); custom distroless images via [rules_distroless](rules-distroless.md). Adopters: Kubernetes (v1.15+), Knative, Tekton, Teleport, BloodHound, K8gb.

## Related

- [Distroless](../entities/distroless.md)
- [Distroless Images](../concepts/distroless-images.md)
- [HackTricks — Distroless Containers](hacktricks-distroless.md) (post-exploitation view)
