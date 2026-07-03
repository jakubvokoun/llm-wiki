---
title: "Bazel — Dependencies"
tags: [build-system, bazel, dependencies, build-graph]
sources: [bazel-dependencies.md]
updated: 2026-06-14
---

# Bazel — Dependencies

How [Bazel](../entities/bazel.md) models dependencies between targets.

## Key Takeaways

- A target A **depends on** target B if Bazel needs B to build/run A; this forms a directed **dependency graph**.
- **Declared vs actual:** you must **explicitly declare every actual direct dependency** of each rule. Relying on an undeclared (transitive) dependency creates hidden coupling that breaks on refactor — e.g. package `a` using something from `c` without declaring it works until `b` stops pulling in `c`.
- Three dependency attributes:
  - `srcs` — source files the rule processes.
  - `deps` — separately-compiled modules the rule links against / imports.
  - `data` — runtime files needed when the target executes.
- Bazel uses declared deps to build the action graph, do correct incremental rebuilds, and answer [queries](bazel-query-guide.md).

## Related

- [Build Graph & Query](../concepts/build-graph.md)
- [Repositories, Workspaces, Packages, Targets](bazel-build-ref.md)
- [Query guide](bazel-query-guide.md)
