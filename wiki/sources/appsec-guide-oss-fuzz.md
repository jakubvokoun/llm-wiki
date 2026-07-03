---
title: "OSS-Fuzz (Trail of Bits Testing Handbook)"
tags: [oss-fuzz, fuzzing, testing, security, ci]
sources: [appsec-guide-oss-fuzz.md]
updated: 2026-06-19
---

# OSS-Fuzz (Trail of Bits Testing Handbook)

[Trail of Bits](../entities/trail-of-bits.md)' practical chapter on using [OSS-Fuzz](../entities/oss-fuzz.md) — both running harnesses locally and integrating a project for continuous fuzzing.

## What it covers

- **Components:** the CLI framework (`infra/helper.py`), public bug tracker, build-status dashboard, and **Fuzz Introspector** for coverage.
- **Running a single harness locally:** `build_image --pull <project>` → `build_fuzzers --sanitizer=address <project>` → `run_fuzzer <project> <harness>`. Outputs land in `/build/out/<project>/`. Worked **irssi** example with annotated libFuzzer output.
- **Coverage analysis** via the `coverage` [sanitizer](../concepts/sanitizers.md) + gsutil.
- **Docker image hierarchy:** `base_image` → `base_clang` → `base_builder(_*)` → your project image; shared `base_runner` for execution.
- **Integrating your project:** `project.yaml` + `Dockerfile` + `build.sh`; acceptance gated on a **criticality score**; keep harness source in its own repo (cf. curl-fuzzer).

## Key guidance

If a project isn't eligible for Google's infra, use **CIFuzz** (with **ClusterFuzzLite**) for short per-commit fuzzing in CI — it pinpoints the introducing commit and feeds crashing inputs back into the corpus as regression tests. PRO TIP: model new harnesses on existing project Dockerfiles rather than copying source by hand.

## See also

- [OSS-Fuzz](../entities/oss-fuzz.md) (entity)
- [Fuzzing](../concepts/fuzzing.md)
- [Sanitizers](../concepts/sanitizers.md)
- [Fuzzing (Testing Handbook)](appsec-guide-fuzzing.md)
- [OSS-Fuzz docs](oss-fuzz.md)
- [Trail of Bits](../entities/trail-of-bits.md)
