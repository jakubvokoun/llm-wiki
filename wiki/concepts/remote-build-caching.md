---
title: "Remote Build Caching"
tags: [build-system, bazel, caching, ci]
sources: [bazel-remote-caching.md]
updated: 2026-06-14
---

# Remote Build Caching

A shared cache of build-action outputs, used by a team and/or CI system so that outputs built on one machine can be reused on another. Requires [reproducible / hermetic builds](hermetic-builds.md) to be safe. A [Bazel](../entities/bazel.md) feature, but the model is general.

## How it works

Bazel breaks a build into **actions**, each with explicitly declared inputs, output names, a command line, and environment variables. The remote cache stores two things:

- **Action cache** — maps an action hash → action result metadata.
- **Content-addressable store (CAS)** — output files keyed by content hash.

On a build: Bazel builds the action graph → checks local outputs → checks the remote cache (a hit retrieves the output) → executes any missing actions locally → uploads new outputs.

## Backends & protocol

Any HTTP/1.1 server supporting PUT/GET works (it treats data as opaque bytes): nginx+WebDAV, [bazel-remote](https://github.com/buchgr/bazel-remote), Google Cloud Storage, S3, Apache httpd, Hazelcast. Metadata lives under `/ac/`, output files under `/cas/`. gRPC(s) is also supported.

```
build --remote_cache=http://your.host:port      # read+write
build --remote_upload_local_results=false        # read-only
```

Tag a target `no-remote-cache` to exclude it. A local **disk cache** (`--disk_cache=path`) is the single-machine analogue, handy across branches/worktrees.

## Security & correctness notes

- Restrict **write** access (often: only CI writes) — the cache holds your binaries.
- HTTP Basic Auth sends credentials in plaintext → always pair with HTTPS.
- **Cache-poisoning hazards:** input files modified mid-build (`--experimental_guard_against_concurrent_changes`), un-whitelisted env vars like `$PATH` leaking in (cuts hit rate), and untracked host tools causing wrong shared hits — all [hermeticity](hermetic-builds.md) failures.

## Sources

- [Remote Caching](../sources/bazel-remote-caching.md)
