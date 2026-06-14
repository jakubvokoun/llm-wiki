---
title: "Starlark"
tags: [build-system, bazel, language, starlark]
sources: [bazel-starlark-language.md]
updated: 2026-06-14
---

# Starlark

The configuration/build language used by [Bazel](../entities/bazel.md) (formerly called Skylark). Its syntax is inspired by Python 3, but it is deliberately restricted to keep builds deterministic and analyzable.

## Where it is used

- **`BUILD` files** — declare the targets (libraries, binaries, tests) in a package.
- **`.bzl` extension files** — define macros and rules that extend Bazel with custom logic for new languages/tools.

Each `BUILD` and `.bzl` file gets its own execution context; each rule is analyzed in its own context.

## Key differences from Python

- **Global variables are immutable** — supports parallel, reproducible evaluation.
- **No top-level control flow** in `BUILD` files; declaring functions is illegal there, and `*args`/`**kwargs` are disallowed in `BUILD`.
- **No classes, no imports (`import`), no exceptions, no `while`** loops by default.
- Integers are limited (historically 32-bit).
- Data types: `None`, `bool`, `int`, `string`, `list`, `dict`, `tuple`, `function`. Only `list` and `dict` are mutable, and only within the context that created them.

## Loading vs native symbols

Native functions and native rules are global in `BUILD` files; `.bzl` files must pull them in via the `native` module. User-defined symbols are shared between files with `load()`.

## Why the restrictions

Immutability + no arbitrary control flow make build definitions **deterministic and safely parallelizable**, which underpins Bazel's caching, [hermeticity](hermetic-builds.md), and [build graph](build-graph.md) analysis.

## Sources

- [Starlark Language](../sources/bazel-starlark-language.md)
