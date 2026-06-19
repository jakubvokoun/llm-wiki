---
title: "OSS-Fuzz (official documentation)"
tags: [oss-fuzz, fuzzing, google, openssf, security]
sources: [oss-fuzz.md]
updated: 2026-06-19
---

# OSS-Fuzz (official documentation)

The landing page of Google's [OSS-Fuzz](../entities/oss-fuzz.md) documentation — the free continuous-fuzzing service for open-source software.

## Highlights

- **Origin:** launched **2016** after [Heartbleed](https://heartbleed.com/) (a simple OpenSSL buffer overflow fuzzing would have caught), run with the Core Infrastructure Initiative and [OpenSSF](../entities/openssf.md).
- **Engines:** libFuzzer, AFL++, Honggfuzz, Centipede + [Sanitizers](../concepts/sanitizers.md); ClusterFuzz for distributed execution/reporting.
- **Languages:** C/C++, Rust, Go, Python, Java/JVM, JavaScript, Lua. Fuzzes x86_64 and i386.
- **Trophies (Aug 2023):** 10,000+ vulnerabilities and 36,000+ bugs across ~1,000 projects.
- **Not eligible?** Closed-source projects self-host ClusterFuzz / ClusterFuzzLite.

## Doc map

Architecture; Getting started (accepting/setting up projects, per-language integration guides incl. Bazel, bug-disclosure guidelines, CI/CIFuzz); Advanced topics (ideal integration, code coverage, Fuzz Introspector, corpora, debugging, reproducing); Further reading (ClusterFuzz, fuzzer environment); Reference (glossary, useful links).

## See also

- [OSS-Fuzz](../entities/oss-fuzz.md) (entity) · [Fuzzing](../concepts/fuzzing.md) · [Sanitizers](../concepts/sanitizers.md)
- [OSS-Fuzz (Testing Handbook)](appsec-guide-oss-fuzz.md) — practical how-to
- [OpenSSF](../entities/openssf.md)
