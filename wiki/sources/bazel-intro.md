---
title: "Intro to Bazel"
tags: [build-system, bazel]
sources: [bazel-intro.md]
updated: 2026-06-14
---

# Intro to Bazel

Overview page for [Bazel](../entities/bazel.md), Google's open-source build/test tool.

## Key Takeaways

- Like Make/Maven/Gradle but with a **high-level, human-readable build language** that operates on _concepts_ (libraries, binaries, scripts, datasets) instead of raw compiler/linker calls.
- **Fast & reliable** via caching of all prior work + tracking changes to file content _and_ build commands — rebuilds only what changed; parallel and incremental.
- **Multi-platform** (Linux/macOS/Windows; builds desktop/server/mobile from one project) and **scales** to 100k+ files and tens of thousands of users.
- **Extensible** with [Starlark](../concepts/starlark.md) rules shared by the community.

## Workflow

Install Bazel → set up a [workspace](bazel-build-ref.md) → write a `BUILD` file declaring targets (build rule + inputs + deps + options) → run `bazel` from the CLI. Also runs tests and `bazel query` to trace [dependencies](../concepts/build-graph.md).

## Build process

1. **Load** the `BUILD` files relevant to the target.
2. **Analyze** inputs and [dependencies](../concepts/build-graph.md), apply rules, produce an **action graph**.
3. **Execute** actions until outputs are produced.

Cached work is reused; only changed work is redone. Correctness can be tightened by running [hermetically](../concepts/hermetic-builds.md) via sandboxing. The **action graph** tracks artifacts, their relationships, and the actions — enabling change tracking and dependency tracing.

## Related

- [Bazel](../entities/bazel.md) · [Build system basics](bazel-build-system-basics.md) · [Build Graph & Query](../concepts/build-graph.md)
