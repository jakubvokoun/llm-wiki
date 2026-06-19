---
source_url: https://google.github.io/oss-fuzz/
fetched: 2026-06-19
---

# OSS-Fuzz

[Fuzz testing](https://en.wikipedia.org/wiki/Fuzz_testing) is a well-known technique for uncovering programming errors in software. Many of these detectable errors, like [buffer overflow](https://en.wikipedia.org/wiki/Buffer_overflow), can have serious security implications. Google has found thousands of security vulnerabilities and stability bugs by deploying [guided in-process fuzzing of Chrome components](https://security.googleblog.com/2016/08/guided-in-process-fuzzing-of-chrome.html), and we now want to share that service with the open source community.

In cooperation with the [Core Infrastructure Initiative](https://www.coreinfrastructure.org/) and the [OpenSSF](https://www.openssf.org/), OSS-Fuzz aims to make common open source software more secure and stable by combining modern fuzzing techniques with scalable, distributed execution. Projects that do not qualify for OSS-Fuzz (e.g. closed source) can run their own instances of [ClusterFuzz](https://github.com/google/clusterfuzz) or [ClusterFuzzLite](https://google.github.io/clusterfuzzlite/).

We support the [libFuzzer](https://llvm.org/docs/LibFuzzer.html), [AFL++](https://github.com/AFLplusplus/AFLplusplus), [Honggfuzz](https://github.com/google/honggfuzz), and [Centipede](https://github.com/google/centipede) fuzzing engines in combination with [Sanitizers](https://github.com/google/sanitizers), as well as ClusterFuzz, a distributed fuzzer execution environment and reporting tool.

Currently, OSS-Fuzz supports C/C++, Rust, Go, Python, Java/JVM code, JavaScript and Lua. Other languages supported by [LLVM](https://llvm.org) may work too. OSS-Fuzz supports fuzzing x86_64 and i386 builds.

## Project history

OSS-Fuzz was launched in 2016 in response to the [Heartbleed](https://heartbleed.com/) vulnerability, discovered in [OpenSSL](https://www.openssl.org/), one of the most popular open source projects for encrypting web traffic. The vulnerability had the potential to affect almost every internet user, yet was caused by a relatively simple memory buffer overflow bug that could have been detected by fuzzing—that is, by running the code on randomized inputs to intentionally cause unexpected behaviors or crashes. At the time, though, fuzzing was not widely used and was cumbersome for developers, requiring extensive manual effort.

Google created OSS-Fuzz to fill this gap: it's a free service that runs fuzzers for open source projects and privately alerts developers to the bugs detected. Since its launch, OSS-Fuzz has become a critical service for the open source community, growing beyond C/C++ to detect problems in memory-safe languages such as Go, Rust, and Python.

## Learn more about fuzzing

This documentation describes how to use OSS-Fuzz service for your open source project. To learn more about fuzzing in general, the project recommends reading the [libFuzzer tutorial](https://github.com/google/fuzzing/blob/master/tutorial/libFuzzerTutorial.md) and the other docs in the [google/fuzzing](https://github.com/google/fuzzing/tree/master/docs) repository.

## Trophies

As of August 2023, OSS-Fuzz has helped identify and fix over 10,000 vulnerabilities and 36,000 bugs across 1,000 projects.

## Documentation structure

- **Architecture** — how the OSS-Fuzz pipeline fits together
- **Getting started** — accepting new projects, setting up a new project (per-language integration guides for Go, Swift, Rust, Python, JavaScript, Java/JVM, Lua, Bazel), bug disclosure guidelines, continuous integration (CIFuzz)
- **Advanced topics** — ideal integration, code coverage, Fuzz Introspector, corpora, debugging, reproducing
- **Further reading** — ClusterFuzz, fuzzer environment
- **Reference** — glossary, useful links

---

Source: google.github.io/oss-fuzz (Just the Docs theme).
