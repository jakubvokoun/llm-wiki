---
title: "openQA — Users Guide"
tags: [openqa, testing, yaml, rest-api, web-ui]
sources: [openqa-users-guide.md]
updated: 2026-06-23
---

# openQA — Users Guide

Official guide for using an existing [openQA](../entities/openqa.md) instance: automating job creation, the web UI, the REST API, and asset/cleanup management.

## Key Takeaways

- **[Job templates](../concepts/openqa-job-templates.md)** — automate job creation from **Machines**, **Medium Types (products)** and **Test Suites** tied together in **Job Groups**, with **variable expansion** and **precedence** rules.
- **YAML job groups** — define groups as YAML (defaults, aliases, merge keys); validate with `openqa-validate-yaml`; edit via web UI or the same API routes the UI uses, with a `reference` concurrency guard.
- **Web interface** — customizable `/tests/overview`, **review badges**, **bug references/labels/flags** (distinguishing product vs test issues), **build tagging**, filtering, dependency highlighting, carry-over of bugrefs, dark mode, **developer mode**, job-group editor, monitoring dashboards.
- **REST API** — finding tests (incl. by job settings), **triggering tests**, `latest` query route, job-template YAML over the API.
- **Asset handling** — specifying assets a job requires/creates; **cleanup** of assets/results by retention settings; automatic **archiving** of important jobs to `OPENQA_ARCHIVEDIR`.

## Related Pages

- [Job templates](../concepts/openqa-job-templates.md) · [Jobs](../concepts/openqa-jobs.md) · [openqa-cli](../concepts/openqa-cli.md) · [openQA](../entities/openqa.md)
