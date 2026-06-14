---
title: "Bazel"
tags: [product, build-system, google, bazel]
sources: [bazel-intro.md, bazel-build-system-basics.md, distroless.md]
updated: 2026-06-14
---

# Bazel

Open-source build and test tool from Google, similar in role to Make, Maven, and Gradle but built for large multi-language, multi-platform codebases. Uses a high-level, human-readable build language ([Starlark](../concepts/starlark.md)) and is designed to scale to 100k+ source files and tens of thousands of users across one or many repositories.

## Why Bazel

- **High-level build language** — describes builds in terms of libraries, binaries, scripts, and data sets, hiding direct compiler/linker invocations.
- **Fast and reliable** — caches all prior work and tracks changes to both file content and build commands, rebuilding only what changed. Parallel and incremental by design.
- **Multi-platform** — runs on Linux, macOS, Windows; builds for desktop, server, and mobile from one project.
- **Scales** — handles huge monorepos and multi-repo setups.
- **Extensible** — language [rules](../concepts/starlark.md) are written in Starlark and shared by the community.

## How it works

A build is described in `BUILD` files that declare [targets](../concepts/build-graph.md). Bazel **loads** the relevant `BUILD` files, **analyzes** inputs and [dependencies](../concepts/build-graph.md) to produce an action graph, then **executes** actions until outputs are produced. Because prior work is cached, only changed work is redone. See [build system basics](../sources/bazel-build-system-basics.md) for the task-based vs artifact-based framing.

## Key concepts (each has its own page)

- [Repositories, workspaces, packages, targets](../sources/bazel-build-ref.md) — the organizational units
- [Starlark](../concepts/starlark.md) — the build/extension language
- [Bazel modules (Bzlmod)](../concepts/bazel-modules.md) — dependency management via `MODULE.bazel`
- [Hermetic builds](../concepts/hermetic-builds.md) — isolation for reproducibility
- [Remote build caching](../concepts/remote-build-caching.md) — sharing action outputs
- [Build graph & query](../concepts/build-graph.md) — the action/dependency graph and `bazel query`

## Notable uses

- Builds Google's [distroless](distroless.md) container images.
- Container image rules: [rules_oci](../sources/rules-oci.md), [rules_distroless](../sources/rules-distroless.md).
- Used at Google, Stripe, Dropbox, and many others.

## Sources

- [Intro to Bazel](../sources/bazel-intro.md)
- [Build system basics](../sources/bazel-build-system-basics.md)
