---
title: "Hermetic Builds"
tags: [build-system, bazel, reproducibility, supply-chain-security]
sources: [bazel-hermeticity.md]
updated: 2026-06-14
---

# Hermetic Builds

A build is **hermetic** when, given the same source code and configuration, it always produces the same output — by **isolating the build from the host system**. A core property [Bazel](../entities/bazel.md) aims for.

## What it requires

- **Tool isolation** — the build uses its own declared toolchains, not whatever happens to be installed on the host.
- **Source identity** — inputs are pinned/verified (e.g. by version-control hash).
- Every action declares its inputs and outputs explicitly.

## Advantages

- **Caching** — deterministic outputs can be safely reused (see [remote build caching](remote-build-caching.md)).
- **Parallel & concurrent execution** — multiple builds don't interfere.
- **Reproducibility** — same inputs ⇒ same artifact, on any machine, anytime.

## Common non-hermetic pitfalls

- Non-deterministic generated files (timestamps, map ordering, random IDs).
- System-dependent binaries / tools pulled from `/usr/bin` (Bazel does **not** track tools outside the workspace — two machines with different compilers wrongly share cache hits).
- Environment variables (e.g. `$PATH`) leaking into actions and reducing cross-machine cache hits.
- Modifying source files during the build.

## Solutions

Sandboxing, remote execution, Docker-container test builds, and "null"/repeated sequential builds to detect non-determinism.

## Relation

Hermeticity is the foundation for [reproducible builds](supply-chain-security.md) and underpins build provenance in [SLSA](slsa.md) — a hermetic, isolated build platform is what makes build attestations trustworthy. Enabled in Bazel by [Starlark](starlark.md)'s deterministic evaluation and the explicit [build graph](build-graph.md).

## Sources

- [Hermeticity](../sources/bazel-hermeticity.md)
