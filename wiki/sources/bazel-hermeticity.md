---
title: "Bazel — Hermeticity"
tags: [build-system, bazel, reproducibility, supply-chain-security]
sources: [bazel-hermeticity.md]
updated: 2026-06-14
---

# Bazel — Hermeticity

[Bazel](../entities/bazel.md) documentation on [hermetic builds](../concepts/hermetic-builds.md).

## Key Takeaways

- **Hermetic** = same source + config always yields the same output, by isolating the build from host-system changes.
- Achieved through **tool isolation** (declared toolchains, not host tools) and **source identity** (inputs verified by VC hash).
- **Advantages:** safe caching, parallel/concurrent builds, multiple simultaneous builds, and reproducibility.
- **Common non-hermetic issues:** non-deterministic generated files (timestamps, ordering), system-dependent binaries, and source-tree modification during the build.
- **Solutions:** sandboxing, remote execution, Docker-container test builds, and null/sequential rebuilds to surface non-determinism. (Cited real-world adopters: SpaceX, Uber, IBM, BMW.)

## Related

- [Hermetic Builds](../concepts/hermetic-builds.md)
- [Remote Build Caching](../concepts/remote-build-caching.md)
- [SLSA](../concepts/slsa.md)
