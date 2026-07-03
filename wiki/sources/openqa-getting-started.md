---
title: "openQA — Getting Started"
tags: [openqa, testing, automation, opensuse]
sources: [openqa-getting-started.md]
updated: 2026-06-23
---

# openQA — Getting Started

Official overview doc for [openQA](../entities/openqa.md) — the canonical introduction and glossary.

## Key Takeaways

- **What openQA is** — automated tool that tests a whole OS by driving a VM through install/usage, checking screen + serial console and sending keystrokes. Runs many config/option combinations per OS revision. GPLv2; hosted in the [os-autoinst](../entities/os-autoinst.md) GitHub org.
- **Two-layer architecture** — [os-autoinst](../entities/os-autoinst.md) (standalone engine: VM + scripts → video/screenshots/JSON) wrapped by openQA's web UI, REST API, scheduler and distributed [workers](../concepts/openqa-architecture.md).
- **Glossary** — defines test module, test suite, [job](../concepts/openqa-jobs.md)/test run, distri, product, version, build, flavor, arch, machine, **scenario** (`<distri>-<version>-<flavor>-<arch>-<test_suite>@<machine>`). See [Jobs](../concepts/openqa-jobs.md).
- **[Jobs](../concepts/openqa-jobs.md)** — states (scheduled→running→done/cancelled) and results (passed/failed/softfailed/…); **cloning** re-runs with the same settings, superseding the original.
- **[Needles](../concepts/needle-matching.md)** — fuzzy image matching of the screen against PNG+JSON reference images with tags, areas (match/ocr/exclude) and click points.
- **[Configuration](../concepts/openqa-architecture.md)** — `openqa.ini`, `database.ini`, `workers.ini`, `client.conf` (+ drop-in `.d/` dirs) under `/etc/openqa`.
- **Access** — OpenID auth; operator/admin flags; API key+secret for clients.
- **Bootstrapping tests** — point `CASEDIR`/`NEEDLES_DIR` at git repos, or clone `os-autoinst-distri-opensuse`/`-fedora`; `fetchneedles`, `openqa-load-templates`. Trigger an ISO with `openqa-cli api -X POST isos …`.

## Related Pages

- [openQA](../entities/openqa.md)
- [os-autoinst](../entities/os-autoinst.md)
- [Architecture](../concepts/openqa-architecture.md)
- [Jobs](../concepts/openqa-jobs.md)
- [Needle matching](../concepts/needle-matching.md)
- [Test API](../concepts/openqa-test-api.md)
