---
title: "openQA — Writing Tests"
tags: [openqa, testing, perl, python, lua, ci]
sources: [openqa-writing-tests.md]
updated: 2026-06-23
---

# openQA — Writing Tests

Official reference for authoring [openQA](../entities/openqa.md) tests against the [os-autoinst](../entities/os-autoinst.md) [test API](../concepts/openqa-test-api.md).

## Key Takeaways

- **Languages** — tests in **Perl** (default), **Python** (`Inline::Python`) or **Lua** (`Inline::Lua`); the API maps across all three. See [Test API](../concepts/openqa-test-api.md).
- **[Test module](../concepts/openqa-test-api.md) interface** — implement `run`; optional `test_flags` (`fatal`, `always_run`, `ignore_failure`, `milestone`, `no_rollback`), `post_fail_hook`, `pre_run_hook`, `post_run_hook`. Loaded via `loadtest` in `main.pm`.
- **Variables** — test behaviour driven by job settings; backend variables (e.g. for QEMU/UEFI), changeable timeouts.
- **Advanced features** — capturing kernel/serial exceptions, traceability & reproducibility, **assigning jobs to workers** via `WORKER_CLASS`, custom worker engines, automatic **retries**, **[job dependencies](../concepts/openqa-jobs.md)**.
- **Multi-machine tests** — parallel jobs coordinated through the **synchronization/locking (mutex) API**; **support-server**-based tests; text consoles and the **virtio serial terminal**.
- **MCP support** — test-side Model Context Protocol integration.
- **Dev tricks** — trigger tests by tweaking settings of existing runs, backend vars for speed, **snapshots** to speed up test development, custom schedules/modules, triggering from a remote **git refspec / GitHub PR**.
- **openQA jobs as CI checks** — create/monitor jobs from a CI runner, GitHub webhooks + status APIs, or run **isotovideo** directly in the runner; integrate results from external systems.

## Related Pages

- [Test API & Test Modules](../concepts/openqa-test-api.md)
- [Python tests](openqa-python-tests.md)
- [Needle matching](../concepts/needle-matching.md)
- [Jobs](../concepts/openqa-jobs.md)
- [os-autoinst](../entities/os-autoinst.md)
