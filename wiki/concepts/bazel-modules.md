---
title: "Bazel Modules (Bzlmod)"
tags: [build-system, bazel, dependency-management, bzlmod]
sources: [bazel-modules-bzlmod.md]
updated: 2026-06-14
---

# Bazel Modules (Bzlmod)

Bazel's modern external-dependency system, replacing the older `WORKSPACE` mechanism. A **module** is a Bazel project that can have multiple versions, each publishing metadata about its own dependencies via a `MODULE.bazel` manifest.

## MODULE.bazel

Declares the module's name and version plus its **direct** dependencies — each module only declares its first-order deps. Like `BUILD` files, it has no control flow and additionally forbids `load`. Key directives:

- `module(...)` — metadata (name, version, …) for the current module.
- `bazel_dep(name, version)` — a direct dependency on another Bazel module.
- **Overrides** (root module only) — `single_version_override`, `multiple_version_override`, and non-registry overrides `archive_override` / `git_override` / `local_path_override` to point a dep at an archive, git commit, or local patch.
- **Module extensions** — run custom logic during resolution (e.g. fetch Maven artifacts, generate repos).

## Version selection

Uses **Minimal Version Selection (MVS)**: pick the _highest version required by any dependent_ (similar to Go), which keeps resolution reproducible and avoids surprise upgrades. Versions use a relaxed SemVer allowing flexible segment counts and letters.

## Registry

Modules are resolved from the **Bazel Central Registry (BCR)** by default (`registry.bazel.build`). Example consumer: `bazel_dep(name = "rules_distroless", version = "0.5.1")` — see [rules_distroless](../sources/rules-distroless.md) and [rules_oci](../sources/rules-oci.md).

## Repository naming

By default a module's repos appear to dependents under the module name, promoting strict dependency hygiene so transitive-dep changes don't silently break you.

## Sources

- [Bazel modules](../sources/bazel-modules-bzlmod.md)
