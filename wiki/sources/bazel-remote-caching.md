---
title: "Bazel — Remote Caching"
tags: [build-system, bazel, caching, ci]
sources: [bazel-remote-caching.md]
updated: 2026-06-14
---

# Bazel — Remote Caching

[Bazel](../entities/bazel.md) guide to [remote build caching](../concepts/remote-build-caching.md): sharing action outputs across a team/CI.

## Key Takeaways

- A remote cache lets reproducible build outputs from one machine be reused on another — significant speedups. Requires Bazel ≥ 0.10.0.
- Stores two data types: the **action cache** (action hash → result metadata) and a **content-addressable store (CAS)** of output files. Also stores per-action stdout/stderr.
- **Build flow with cache:** build action graph → check local outputs → check remote cache (hit = retrieve) → execute misses locally → upload new outputs. Modes: read+write, read-only (`--remote_upload_local_results=false`), exclude (`no-remote-cache` tag), or off.
- **Backends:** any HTTP/1.1 PUT/GET server (data is opaque bytes) — nginx+WebDAV, bazel-remote (disk + GC, REST+gRPC), Google Cloud Storage, S3, Hazelcast, Apache httpd. Metadata under `/ac/`, files under `/cas/`. gRPC(s) supported.
- **Config** via `--remote_cache=...` flags, ideally in `.bazelrc` (local / workspace / CI). HTTP Basic Auth available but plaintext → use HTTPS. Unix-socket proxy supported (not Windows).
- **Disk cache** (`--disk_cache=path`) is the single-machine variant; GC via `--experimental_disk_cache_gc_max_size`/`_age` (Bazel 7.4+).

## Known issues (cache correctness)

- Input file modified mid-build → invalid uploads (`--experimental_guard_against_concurrent_changes`).
- Env vars (e.g. `$PATH`) leaking into actions reduce cross-machine hits; only `--action_env` vars are in the action definition.
- Bazel **doesn't track tools outside the workspace** → different host compilers wrongly share cache hits.
- In-memory incremental state is lost when each build runs in a fresh Docker container (CI).

## Related

- [Remote Build Caching](../concepts/remote-build-caching.md)
- [Hermetic Builds](../concepts/hermetic-builds.md)
