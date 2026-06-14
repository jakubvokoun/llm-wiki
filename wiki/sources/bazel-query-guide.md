---
title: "Bazel — Query Guide"
tags: [build-system, bazel, dependencies, build-graph]
sources: [bazel-query-guide.md]
updated: 2026-06-14
---

# Bazel — Query Guide

Practical guide to `bazel query` for tracing [dependencies](../concepts/build-graph.md) in a [Bazel](../entities/bazel.md) build.

## Key Takeaways

- `deps(//foo)` — all targets required to build `//foo`. Use `--keep_going` to ignore errors.
- **Paths between targets:** `somepath(a, b)` (one path) and `allpaths(a, b)` (all paths) answer "why does a depend on b?". Pipe `--output graph | dot -Tsvg` to visualize.
- **Reverse deps:** `rdeps(universe, x)` ("what depends on x / what will I break?"), `allrdeps` (Sky Query), `same_pkg_direct_rdeps(T)`.
- **Filters/selectors:** `kind(rule_type, ...)`, `attr(name, value, ...)`, `filter(regex, ...)`, `tests(suite)`, `buildfiles(...)`, plus set ops `intersect`/`except`/`union` and `let` bindings. Idiom: `X intersect allpaths(X, Y)` = "which X depend on Y?".
- **Implicit deps:** some rules add deps not in the BUILD file (e.g. `genproto` → protocol compiler); filter with `--noimplicit_deps` / `--notool_deps`.
- **Output modes:** flattened list (default), `--output graph`, `package`, `label_kind`, `location`, `maxrank` (longest sequential path).

## Related

- [Build Graph & Query](../concepts/build-graph.md) · [Dependencies](bazel-dependencies.md)
