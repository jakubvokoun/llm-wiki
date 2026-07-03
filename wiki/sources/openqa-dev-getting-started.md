---
title: "Get Started with openQA Development (liv.pink)"
tags: [openqa, development, opensuse, tutorial]
sources: [openqa-dev-getting-started.md]
updated: 2026-06-23
---

# Get Started with openQA Development

Blog tutorial by **Liv Dywan** (2021-02-16) on setting up a local [openQA](../entities/openqa.md)/[os-autoinst](../entities/os-autoinst.md) dev environment from git checkouts, manually wiring the pieces.

## Key Takeaways

- **Base system** — openSUSE Tumbleweed (bare metal, VM or toolbox container). Convenience packages: `openQA-devel os-autoinst-devel os-autoinst-distri-opensuse-deps`. For a non-manual path, use `openqa-bootstrap` / `openqa-bootstrap-container` instead.
- **Checkouts** — clone both `openQA` and `os-autoinst`. Set `OPENQA_BASEDIR`, `OPENQA_CONFIG`, `OPENQA_LIBPATH`, `PERL5LIB`, `CDPATH` to point at the local tree; drop `database.ini`/`client.conf`/`workers.ini` into the local config dir to avoid system-wide services.
- **Tests** — `make test-with-database TESTS=t/09-job_clone.t` for openQA; `make && make check` for os-autoinst (the first `make` builds **isotovideo** binaries).
- **Live web UI** — `t/test_postgresql $OPENQA_BASEDIR/db` then `morbo -l http://*:9526 ./script/openqa` runs a UI on **port 9526** on a throwaway DB; _Login_ grants admin + a default API key. No system postgres/systemd involved; reset by deleting the `db` folder.
- **Hacking** — internals under `openQA/lib/OpenQA` (`Schema`, `WebAPI.pm`, `Setup.pm`, `Worker/`); a refresh shows template changes, deeper changes need a `morbo` restart.
- **Running a job** — `openqa-clone-job` to import a job from o3, then start a worker: `script/openqa-websockets daemon &` + `script/worker` (the **scheduler** only queues; a **worker** does the work; `--instance N` for multiple).

## Related Pages

- [openQA](../entities/openqa.md)
- [os-autoinst](../entities/os-autoinst.md)
- [Architecture](../concepts/openqa-architecture.md)
- [Jobs](../concepts/openqa-jobs.md)
- [Installing](openqa-installing.md)
