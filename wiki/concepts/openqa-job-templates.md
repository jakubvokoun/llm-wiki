---
title: "openQA Job Templates"
tags: [openqa, testing, yaml, configuration]
sources: [openqa-users-guide.md, openqa-command-line.md]
updated: 2026-06-23
---

# openQA Job Templates

How [openQA](../entities/openqa.md) automates **job creation**: instead of posting every [job](openqa-jobs.md) by hand, you define templates so that scheduling a product (an ISO/build) fans out into all the right test runs across machines and flavors.

## Building blocks

Configured in the admin web UI (or via the [REST API](openqa-cli.md)):

- **Machines** — hardware/worker variants (e.g. `64bit`, `uefi`), each a bag of settings (`QEMUCPU`, `WORKER_CLASS`, …).
- **Medium Types (products)** — a `DISTRI`/`VERSION`/`FLAVOR`/`ARCH` tuple with default settings.
- **Test Suites** — named collections of [test modules](openqa-test-api.md) plus settings.
- **Job Groups** — tie products × machines × test suites together and own cleanup/priority properties.

## Variable resolution

Settings come from several layers — product, machine, test suite, and job-template overrides — combined with **variable expansion** and a defined **variable precedence** (more specific layers win). This lets one test suite behave differently per machine/product.

## YAML job templates

Job groups are defined as **YAML documents** (editable in the web UI or via API — the UI uses the same routes). Features:

- **Defaults** block to share settings across the group.
- **YAML aliases** (`&anchor` / `*ref`) and **merge keys** (`<<`) to avoid repetition.
- Validate locally with `openqa-validate-yaml file.yaml` (catches syntax errors only — not test suites/settings).
- Fetch/update via [`openqa-cli`](openqa-cli.md):
  ```bash
  openqa-cli api -a 'Accept: application/yaml' job_templates_scheduling/73 > group.yaml
  openqa-cli api -X POST job_templates_scheduling/73 \
    template="$(cat group.yaml)" reference="$(cat group.yaml.bak)"
  ```
  The optional `reference` is a concurrency guard: the update fails if the template changed meanwhile (the web UI uses it to detect simultaneous edits).

## Related Pages

- [Jobs](openqa-jobs.md)
- [openqa-cli](openqa-cli.md)
- [Test API](openqa-test-api.md)
- [openQA](../entities/openqa.md)
- [Users Guide (source)](../sources/openqa-users-guide.md)
