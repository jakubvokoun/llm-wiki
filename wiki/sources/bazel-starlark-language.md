---
title: "Bazel — Starlark Language"
tags: [build-system, bazel, starlark, language]
sources: [bazel-starlark-language.md]
updated: 2026-06-14
---

# Bazel — Starlark Language

Reference overview of [Starlark](../concepts/starlark.md), [Bazel](../entities/bazel.md)'s build/extension language (formerly Skylark).

## Key Takeaways

- Python-3-inspired syntax, used in **`BUILD`** files (declare targets) and **`.bzl`** files (define macros/rules). Each file gets its own execution context.
- Data types: `None`, `bool`, `int`, `string`, `list`, `dict`, `tuple`, `function`. Only `list`/`dict` are mutable, and only within their creating context.
- **Differences from Python:** global variables are immutable; no top-level control flow / function declarations in `BUILD`; no `*args`/`**kwargs` in `BUILD`; no classes, imports, or exception handling; historically 32-bit ints.
- Native rules/functions are global in `BUILD`; `.bzl` files access them via the `native` module and share symbols via `load()`.
- Type annotations are an experimental, in-progress feature.

These restrictions make build definitions deterministic and safely parallel — the basis for caching, [hermeticity](../concepts/hermetic-builds.md), and [build-graph](../concepts/build-graph.md) analysis.

## Related

- [Starlark](../concepts/starlark.md) · [Bazel](../entities/bazel.md) · [Bazel Modules (Bzlmod)](../concepts/bazel-modules.md)
