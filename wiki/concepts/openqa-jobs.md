---
title: "openQA Jobs (Lifecycle, States, Scenarios)"
tags: [openqa, testing, scheduling, ci]
sources:
  [openqa-getting-started.md, openqa-users-guide.md, openqa-command-line.md]
updated: 2026-06-23
---

# openQA Jobs

A **job** (a.k.a. **test run**) is one execution of a [test suite](openqa-test-api.md) in a VM, identified by a numeric ID. Each job carries **settings** that drive its behaviour and produces an overall **result** plus per-[test-module](openqa-test-api.md) results.

## Terminology

A job's scenario is composed from several dimensions (the openQA [glossary](../sources/openqa-getting-started.md)):

- **product** / **job group (webUI)** — the system under test, e.g. `openSUSE` ("Medium Types")
- **version** — e.g. `Tumbleweed`; **build** — a sub-version, e.g. `Build1234`
- **flavor** — variant, e.g. `DVD`; **arch** — e.g. `x86_64`; **machine** — e.g. `64bit`, `uefi`
- **distri** — the test distribution, e.g. `opensuse` (`os-autoinst-distri-opensuse`)
- **scenario** — `<distri>-<version>-<flavor>-<arch>-<test_suite>@<machine>`, e.g. `openSUSE-Tumbleweed-DVD-x86_64-gnome@64bit`

## States

`scheduled` → `setup`/`running`/`uploading` → `done` (or `cancelled`). Final states are `done` and `cancelled`.

## Overall results

- `passed` — no critical check failed (not necessarily every assertion)
- `failed` — a critical assertion failed
- `softfailed` — a known non-critical issue (workaround needle, `record_soft_failure`, or an ignore label)
- `timeout_exceeded` — exceeded `MAX_JOB_TIME` / `MAX_SETUP_TIME`
- `skipped` — dependencies failed; `obsoleted` — superseded by a newer product
- `parallel_failed` / `parallel_restarted`, `user_cancelled` / `user_restarted`, `incomplete` (unexpected error, e.g. worker lost)

## Cloning

When a failure is due to an outdated test or external problem rather than a real bug, a job is **cloned**: scheduled afresh with the same settings. The clone supersedes the original (cancelling it if still running); the original is kept for reference but marked outdated. Tools: `openqa-clone-job`, `openqa-clone-custom-git-refspec` (clone with a git branch/PR applied).

## Job dependencies & multi-machine

Jobs can declare dependencies (chained/parallel) and run **multi-machine** scenarios where jobs run in parallel and coordinate via a **synchronization/locking (mutex) API** — e.g. a server job and client jobs, or exclusive access to a shared resource.

## Job groups

Jobs may belong to a **job group** (shown on the index page and the `Job Groups` menu) with a description and comments. Groups have mostly cleanup-related properties and can be nested under **categories** that share builds. Configured via the operators menu or [YAML job templates](openqa-job-templates.md).

## Triggering & inspecting

Via the [REST API / openqa-cli](openqa-cli.md), e.g. `openqa-cli api -X POST isos ISO=… DISTRI=… VERSION=… FLAVOR=… ARCH=… BUILD=…` to schedule a product, or `openqa-cli schedule …` for a single job.

## Related Pages

- [Test API](openqa-test-api.md) · [Job templates](openqa-job-templates.md) · [openqa-cli](openqa-cli.md) · [Architecture](openqa-architecture.md) · [Needle matching](needle-matching.md)
- [Getting Started (source)](../sources/openqa-getting-started.md) · [Users Guide (source)](../sources/openqa-users-guide.md)
