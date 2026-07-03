---
title: "Bazel — Build System Basics"
tags: [build-system, bazel]
sources: [bazel-build-system-basics.md]
updated: 2026-06-14
---

# Bazel — Build System Basics

Conceptual overview of why build systems exist and the design philosophy behind [Bazel](../entities/bazel.md). Draws on the _Software Engineering at Google_ book.

## Key Takeaways

- A build system is one of the most-used parts of an engineering org — developers interact with it dozens to hundreds of times a day, so its speed and correctness compound heavily.
- Core distinction: **task-based** build systems (Make, Maven, Gradle — scripts run arbitrary commands, hard to parallelize/cache correctly) vs **artifact-based** systems (Bazel — you declare _what_ to build, the tool decides _how_), which enable safe caching, parallelism, and [distributed builds](../concepts/remote-build-caching.md).
- Dependency management at scale is the central problem a build system must solve.

## Subsections

The page indexes deeper chapters: why build systems matter, task-based vs artifact-based builds, distributed builds, and dependencies & dependency management.

## Related

- [Bazel](../entities/bazel.md)
- [Intro to Bazel](bazel-intro.md)
- [Hermetic Builds](../concepts/hermetic-builds.md)
- [Build Graph & Query](../concepts/build-graph.md)
