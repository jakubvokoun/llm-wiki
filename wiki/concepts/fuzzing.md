---
title: Fuzzing
tags:
  - fuzzing
  - testing
  - security
  - dynamic-analysis
  - memory-safety
sources:
  - appsec-guide-fuzzing.md
  - appsec-guide-oss-fuzz.md
  - oss-fuzz.md
updated: 2026-06-19
---

# Fuzzing

A dynamic testing technique that feeds **malformed, unexpected, or random data** to a system to surface crashes, memory corruption, and logic bugs. The technique is ~30 years old (originating with random-input testing of UNIX utilities) and has evolved from pure blackbox random input to **graybox, coverage-guided** fuzzing.

## The default algorithm: mutation-based + evolutionary

Pioneered by [AFL](https://lcamtuf.coredump.cx/afl/), now the de facto approach. Maintain a **corpus** of test cases; each has a "fitness" measured by code coverage. The loop:

1. `schedule` — pick a test case from the corpus
2. `mutate` — bit-flip / insert / truncate to create offspring
3. `execute` — run it, collect observations (coverage, crashes)
4. Keep offspring in the corpus if it's **interesting** (new coverage); record it in the bug set if it **crashed**

Anything that represents progress toward bugs is retained — survival of the fittest test case.

## Anatomy of a fuzzing setup

- **SUT (System Under Test):** the code being tested; you must control its compilation/linking.
- **Harness:** the entrypoint the fuzzer calls with each input. For C/C++ the de facto libFuzzer API is `LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)`. Harnesses have rules about what code may run in them.
- **Fuzzer runtime/engine:** implements the loop, parses options, collects feedback, manages state. Provided by libFuzzer, AFL++, etc.
- **Instrumentation runtime:** optional, e.g. [sanitizers](sanitizers.md) like AddressSanitizer to reliably catch memory corruption, or SanitizerCoverage to feed the fuzzer.
- **Corpus / seed corpus:** the evolving set of inputs, bootstrapped from an initial non-empty seed set.

## Pros and cons

| Advantages                                          | Disadvantages                                                    |
| --------------------------------------------------- | ---------------------------------------------------------------- |
| Finds bugs missed by manual review (broad coverage) | Complex inputs (TLS, source code) need heavy harness effort      |
| Automated, scalable — runs for hours to months      | Incomplete: misses non-crashing or very-specific-condition bugs  |
| Cost-effective after setup                          | Historically memory-corruption-centric (less direct for Rust/Go) |
| Proven for memory-unsafe languages                  | No silver bullet — pair with static analysis + unit tests        |

**Best targets:** parsers and input processors (easy to set up, bugs likely). Complex application logic without unit tests benefits more from static analysis and review _first_.

## What fuzzing can find

Crashes/panics (UAF, integer/buffer overflow, UB, leaks); invariant/business-logic violations (stateful fuzzing); **differentials** (cross-implementation, cross-platform, regressions); broken logical properties — round-trip `decode(encode(x))==x`, idempotence, monotonicity, commutativity, associativity; race conditions.

## Continuous fuzzing

Running once finds today's bugs; **continuous** fuzzing catches regressions. [OSS-Fuzz](../entities/oss-fuzz.md) fuzzes eligible open-source projects on Google infrastructure for free; **CIFuzz** / **ClusterFuzzLite** run short fuzzing per-commit in CI for projects not enrolled.

## Related

- [Sanitizers](sanitizers.md) — runtime bug detectors paired with fuzzers
- [OSS-Fuzz](../entities/oss-fuzz.md) · [Trail of Bits](../entities/trail-of-bits.md) (Testing Handbook)
- [Secure Code Review](secure-code-review.md) · [Vulnerability Handling](vulnerability-handling.md) · [Supply Chain Security](supply-chain-security.md)
- Sources: [Fuzzing (Testing Handbook)](../sources/appsec-guide-fuzzing.md) · [OSS-Fuzz (Testing Handbook)](../sources/appsec-guide-oss-fuzz.md) · [OSS-Fuzz docs](../sources/oss-fuzz.md)
