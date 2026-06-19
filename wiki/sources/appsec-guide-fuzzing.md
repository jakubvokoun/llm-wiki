---
title: "Fuzzing (Trail of Bits Testing Handbook)"
tags: [fuzzing, testing, security, dynamic-analysis]
sources: [appsec-guide-fuzzing.md]
updated: 2026-06-19
---

# Fuzzing (Trail of Bits Testing Handbook)

The introductory chapter of [Trail of Bits](../entities/trail-of-bits.md)' Testing Handbook on [fuzzing](../concepts/fuzzing.md) — a practical, follow-in-an-afternoon guide for developers and security engineers fuzzing code they have the source for.

## What it covers

- **Terminology:** SUT, harness (`LLVMFuzzerTestOneInput`), test case, corpus / seed corpus, fuzzing campaign, fuzzing engine/runtime, instrumentation, code coverage.
- **The default algorithm** — mutation-based + evolutionary (with annotated pseudocode): schedule → mutate → execute → keep if interesting (new coverage) or record if it crashes.
- **Anatomy of a setup:** instrumented SUT + harness + fuzzer runtime, optionally a [sanitizer](../concepts/sanitizers.md) runtime (ASan) and coverage instrumentation. Includes C/C++ and Rust SUT + harness examples.
- **Pros/cons table** and **what to fuzz** — crashes, invariant violations, differentials, broken logical properties (round-trip, idempotence, monotonicity…), race conditions.

## Key guidance

Fuzzing shines on **parsers and input processors**; complex application logic without unit tests benefits more from static analysis, unit testing, and review _first_. Fuzzing is no silver bullet. Memory-safe languages (Rust/Go) need sanitizers less and shift focus toward logic/differential bugs.

## See also

- [Fuzzing](../concepts/fuzzing.md) (concept) · [Sanitizers](../concepts/sanitizers.md)
- [OSS-Fuzz (Testing Handbook)](appsec-guide-oss-fuzz.md) · [OSS-Fuzz docs](oss-fuzz.md)
- [Trail of Bits](../entities/trail-of-bits.md)
