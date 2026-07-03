---
title: "OSS-Fuzz"
tags: [oss-fuzz, fuzzing, google, openssf, security, product]
sources: [oss-fuzz.md, appsec-guide-oss-fuzz.md]
updated: 2026-06-19
---

# OSS-Fuzz

Google's free, distributed **continuous-fuzzing service for open-source software**. Launched **2016** in response to [Heartbleed](https://heartbleed.com/) (CVE-2014-0160) — a simple OpenSSL buffer overflow that fuzzing would have caught — run in cooperation with the Core Infrastructure Initiative and the [OpenSSF](openssf.md).

## Capabilities

- **Engines:** libFuzzer, AFL++, Honggfuzz, Centipede — plus [Sanitizers](../concepts/sanitizers.md), and ClusterFuzz as the distributed execution/reporting backend.
- **Languages:** C/C++, Rust, Go, Python, Java/JVM, JavaScript, Lua (other LLVM-supported languages may work). Fuzzes x86_64 and i386 builds.
- **Impact (as of Aug 2023):** 10,000+ vulnerabilities and 36,000+ bugs fixed across ~1,000 projects.

## How projects integrate

Three files per project: `project.yaml` (metadata), `Dockerfile` (build deps, based on an OSS-Fuzz base image), and `build.sh` (builds harnesses). Acceptance is at the OSS-Fuzz team's discretion, gated on a **criticality score**. The image hierarchy is `base_image` → `base_clang` → `base_builder(_*)` → your project image; harnesses run in a shared `base_runner`.

The `infra/helper.py` CLI builds and runs harnesses locally (`build_image`, `build_fuzzers --sanitizer=…`, `run_fuzzer`, `coverage`) — no need to host the full platform. Tooling includes a public **bug tracker**, **build-status** dashboard, and **Fuzz Introspector** for coverage.

## For projects that don't qualify

Closed-source or unaccepted projects can self-host **ClusterFuzz** / **ClusterFuzzLite**, and use **CIFuzz** for short per-commit fuzzing in CI.

## Related

- [Fuzzing](../concepts/fuzzing.md)
- [Sanitizers](../concepts/sanitizers.md)
- [OpenSSF](openssf.md)
- [Trail of Bits](trail-of-bits.md) (Testing Handbook guide)
- Sources: [OSS-Fuzz docs](../sources/oss-fuzz.md)
- [OSS-Fuzz (Testing Handbook)](../sources/appsec-guide-oss-fuzz.md)
