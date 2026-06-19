---
title: "Sanitizers (Code Sanitizers)"
tags: [sanitizers, fuzzing, memory-safety, testing, compiler]
sources: [appsec-guide-fuzzing.md, appsec-guide-oss-fuzz.md]
updated: 2026-06-19
---

# Sanitizers (Code Sanitizers)

Compiler-inserted **instrumentation runtimes** that detect classes of bugs at runtime that would otherwise be silent or only intermittently crash. They are the standard companion to [fuzzing](fuzzing.md): the fuzzer generates inputs, the sanitizer turns latent corruption into a reliable, diagnosable crash.

## Common sanitizers

- **AddressSanitizer (ASan)** — heap/stack/global buffer overflows, use-after-free, double-free. Often combined with **LeakSanitizer (LSan)** for memory leaks. In OSS-Fuzz: `--sanitizer=address`.
- **UndefinedBehaviorSanitizer (UBSan)** — undefined behavior (integer overflow, misaligned access, invalid casts).
- **MemorySanitizer (MSan)** — reads of uninitialized memory.
- **ThreadSanitizer (TSan)** — data races.
- **SanitizerCoverage** — not a bug detector; emits **coverage feedback** that drives coverage-guided fuzzers. In OSS-Fuzz this is the `coverage` sanitizer used for report generation.

## Notes

- A fuzzer must be **compatible** with the sanitizer for bugs to be detected reliably and for feedback to be wired in efficiently.
- Memory-safe languages (Go, Rust) are less likely to need ASan/MSan, since the language already prevents most memory-corruption bugs — fuzzing there shifts toward logic/differential bugs.
- Sanitizer support varies by language: e.g. in OSS-Fuzz, Rust supports only AddressSanitizer with libFuzzer as the engine.

## Related

- [Fuzzing](fuzzing.md) · [OSS-Fuzz](../entities/oss-fuzz.md)
- Sources: [Fuzzing (Testing Handbook)](../sources/appsec-guide-fuzzing.md) · [OSS-Fuzz (Testing Handbook)](../sources/appsec-guide-oss-fuzz.md)
