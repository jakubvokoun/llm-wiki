---
title: "Distroless"
tags: [product, containers, container-security, google, distroless]
sources: [distroless.md]
updated: 2026-06-14
---

# Distroless

Google ([GoogleContainerTools](https://github.com/GoogleContainerTools/distroless)) project publishing minimal base container images that contain **only your application and its runtime dependencies** — no package managers, no shells, no general-purpose userland. Built with [Bazel](bazel.md).

## Why

Restricting the runtime image to exactly what the app needs improves scanner signal-to-noise (fewer [CVEs](../concepts/cve.md) to triage) and reduces the provenance burden. Images are tiny: the smallest, `gcr.io/distroless/static-debian13`, is ~2 MiB — about half the size of `alpine` (~5 MiB) and under 2% of `debian` (124 MiB).

## Image families

Based on Debian (currently Debian 13 "trixie", tagged `-debian13`). Tiers from smallest up: `static` → `base` → `cc` → language runtimes (`java`, `nodejs`, `python3`). Tags: `latest`, `nonroot`, `debug`, `debug-nonroot`. Multi-arch indexes (amd64, arm64, arm, s390x, ppc64le, riscv64).

- `:debug` variants add a busybox shell for entry/troubleshooting (the base images have none).
- `:nonroot` variants run as a non-root user.

## Operational notes

- **No shell** → Dockerfile `ENTRYPOINT`/`CMD` must use **vector (exec) form** `["myapp"]`; string form fails because there is no shell to interpret it.
- Typical usage is a **multi-stage Docker build**: build the artifact in a full image, then `COPY --from=build` it into the distroless runtime image.
- All images are **[cosign](../concepts/software-attestation.md) keyless-signed**; verify with the `keyless@distroless.iam.gserviceaccount.com` identity and `https://accounts.google.com` issuer.
- CVE/security updates track upstream Debian via automated GitHub Actions PRs.

## Security framing

Distroless is an **image-design strategy, not a runtime isolation primitive** — it shrinks the userland attack surface but does not replace namespaces, seccomp, capabilities, or MAC. See [HackTricks — Distroless Containers](../sources/hacktricks-distroless.md) for the post-exploitation perspective.

## Ecosystem & alternatives

- [rules_distroless](../sources/rules-distroless.md) — build custom distroless images with Bazel.
- [rules_oci](../sources/rules-oci.md) — generic Bazel OCI image rules.
- [Chainguard](chainguard.md) / [Wolfi](wolfi.md) — a distroless-philosophy alternative built on a container-native distro with continuous rebuilds. See [distroless images](../concepts/distroless-images.md) for the comparison.

Adopters: Kubernetes (since v1.15), Knative, Tekton, Teleport, BloodHound, K8gb.

## Sources

- [Distroless README](../sources/distroless.md)
