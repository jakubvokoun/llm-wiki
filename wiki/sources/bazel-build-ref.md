---
title: "Bazel — Repositories, Workspaces, Packages, Targets"
tags: [build-system, bazel, build-graph]
sources: [bazel-build-ref.md]
updated: 2026-06-14
---

# Bazel — Repositories, Workspaces, Packages, Targets

The core organizational units of a [Bazel](../entities/bazel.md) build.

## Key Takeaways

- **Repository** — a directory tree of source code, its root marked by a `MODULE.bazel` (or legacy `WORKSPACE`) file.
- **Workspace** — the shared environment: the main repo plus all external dependencies (managed via [Bzlmod](../concepts/bazel-modules.md)).
- **Package** — a directory containing a `BUILD` or `BUILD.bazel` file, together with the files in it and subdirectories below — _except_ subdirectories that have their own `BUILD` file, which form separate packages. Packages form a hierarchy.
- **Target** — an individual buildable unit defined in a package: either a **file** or a **rule** instance. Addressed by a **label** (e.g. `//path/to/pkg:name`).

## Related

- [Build Graph & Query](../concepts/build-graph.md)
- [Bazel Modules (Bzlmod)](../concepts/bazel-modules.md)
- [Dependencies](bazel-dependencies.md)
