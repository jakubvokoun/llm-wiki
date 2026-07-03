---
title: "os-autoinst"
tags: [product, testing, automation, opensuse, virtualization]
sources:
  [
    openqa-getting-started.md,
    openqa-writing-tests.md,
    openqa-dev-getting-started.md,
    openqa-python-tests.md,
  ]
updated: 2026-06-23
---

# os-autoinst

The standalone test engine at the heart of [openQA](openqa.md), hosted in its own [repository](https://github.com/os-autoinst/os-autoinst). For each execution it creates a virtual machine, runs a set of test scripts against it, and generates a video, screenshots and a JSON file of detailed results.

It can be run entirely on its own (no web UI). [openQA](openqa.md) wraps it to provide a web interface and to distribute os-autoinst runs across many [workers](../concepts/openqa-architecture.md).

## Components & key facts

- **isotovideo** — the main os-autoinst executable that boots the SUT and drives the test schedule. Building os-autoinst (`make`) compiles native binaries of isotovideo. It can also be invoked directly inside a CI runner without a full openQA instance.
- **Backends** — os-autoinst supports multiple virtualization/hardware backends (QEMU is the default; others include svirt, IPMI/bare-metal, etc.), selected via the `BACKEND` variable.
- **[testapi](../concepts/openqa-test-api.md)** — os-autoinst exposes the test API ([`testapi.pm`](https://github.com/os-autoinst/os-autoinst/blob/master/testapi.pm)) used by [test modules](../concepts/openqa-test-api.md): `assert_screen`, `send_key`, `assert_and_click`, `type_string`, `assert_script_run`, etc. Sometimes called the "openQA DSL".
- **[Needle](../concepts/needle-matching.md) matching** — os-autoinst performs the fuzzy image matching between the SUT screen and reference needles.

## Related Pages

- [openQA](openqa.md)
- [Test API](../concepts/openqa-test-api.md)
- [Needle matching](../concepts/needle-matching.md)
- [openQA Architecture](../concepts/openqa-architecture.md)
- Sources: [Getting Started](../sources/openqa-getting-started.md)
- [Writing Tests](../sources/openqa-writing-tests.md)
- [Dev setup](../sources/openqa-dev-getting-started.md)
