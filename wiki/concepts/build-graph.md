---
title: "Build Graph & Query (Bazel)"
tags: [build-system, bazel, dependencies, build-graph]
sources: [bazel-build-ref.md, bazel-dependencies.md, bazel-query-guide.md]
updated: 2026-06-14
---

# Build Graph & Query (Bazel)

How [Bazel](../entities/bazel.md) models a build as a graph of targets and actions, and how `bazel query` inspects it.

## Organizational units

- **Repository** — a directory tree of source, marked by `MODULE.bazel` or `WORKSPACE`.
- **Workspace** — the main repo plus its external dependencies (see [Bzlmod](bazel-modules.md)).
- **Package** — a directory containing a `BUILD`/`BUILD.bazel` file and the files below it (subdirectories with their own `BUILD` are separate packages).
- **Target** — a buildable unit (a file, or a rule instance) addressed by a **label** like `//foo:foo`.

## Dependencies

Every rule must **explicitly declare all of its actual direct dependencies**; undeclared deps create hidden breakage that surfaces on refactor. Three kinds:

- `srcs` — source files
- `deps` — compiled modules it links against
- `data` — runtime files needed for execution

Bazel **analyzes** these into an **action graph** (artifacts + the actions that produce them), enabling change-tracking (rebuild only what changed), caching, and dependency tracing. Some rules carry **implicit** dependencies (e.g. a `genproto` rule implicitly needs the protocol compiler) — filter them with `--noimplicit_deps`.

## bazel query

Traces relationships over the graph. Common functions:

- `deps(//foo)` — everything required to build `//foo`.
- `rdeps(universe, x)` / `allrdeps` / `same_pkg_direct_rdeps(T)` — **reverse** deps ("what will I break?").
- `somepath(a, b)` / `allpaths(a, b)` — _a_ / all dependency paths between two targets ("why does a depend on b?").
- `kind(...)`, `attr(...)`, `filter(...)`, `tests(...)`, `buildfiles(...)` — filter by rule type, attribute, regex, test expansion, or BUILD files.
- `let`/`intersect`/`except` — compose queries; `X intersect allpaths(X, Y)` is the idiom for "which X depend on Y?".

Output as a flattened list or `--output graph | dot -Tsvg` to visualize; `--output package`/`location`/`maxrank` for other views.

## Sources

- [Repositories, workspaces, packages, targets](../sources/bazel-build-ref.md)
- [Dependencies](../sources/bazel-dependencies.md)
- [Query guide](../sources/bazel-query-guide.md)
