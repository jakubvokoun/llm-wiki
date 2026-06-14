---
title: "Bazel — Bazel Modules (Bzlmod)"
tags: [build-system, bazel, dependency-management, bzlmod]
sources: [bazel-modules-bzlmod.md]
updated: 2026-06-14
---

# Bazel — Bazel Modules (Bzlmod)

Reference for [Bzlmod](../concepts/bazel-modules.md), [Bazel](../entities/bazel.md)'s external-dependency system.

## Key Takeaways

- A **module** is a Bazel project with multiple versions, each carrying a `MODULE.bazel` manifest of its name, version, and **direct** dependencies (declare first-order deps only).
- `MODULE.bazel` has no control flow and forbids `load`. Directives: `module(...)` (metadata), `bazel_dep(name, version)` (direct dep), overrides, and module extensions (custom resolution logic, e.g. Maven fetch).
- **Overrides** (root module only): `single_version_override`, `multiple_version_override`, and non-registry `archive_override` / `git_override` / `local_path_override`.
- **Version selection** uses **Minimal Version Selection** — highest version required by any dependent — keeping resolution reproducible. Relaxed SemVer (flexible segments, letters allowed).
- Default registry is the **Bazel Central Registry**. Repos appear to dependents under the module name (strict-deps hygiene).

## Related

- [Bazel Modules (Bzlmod)](../concepts/bazel-modules.md) · [rules_distroless](rules-distroless.md) · [rules_oci](rules-oci.md)
