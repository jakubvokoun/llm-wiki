---
title: "Working with openQA via the Command Line (liv.pink)"
tags: [openqa, cli, rest-api, tutorial]
sources: [openqa-command-line.md]
updated: 2026-06-23
---

# Working with openQA via the Command Line

Blog tutorial by **Liv Dywan** (2021-04-27) on driving [openQA](../entities/openqa.md) through [`openqa-cli`](../concepts/openqa-cli.md) and the REST API.

## Key Takeaways

- **Inspect jobs** — `openqa-cli api --host openqa.opensuse.org jobs/overview`; `--pretty` for readable JSON; pass a job ID (`jobs/1222737`). Default host is **localhost**.
- **Trigger** — `openqa-cli schedule DISTRI=… VERSION=… …` (sugar for `api -X POST isos`; `-m` waits for results), or `api -X POST jobs …`.
- **Auth** — `client.conf` (`[host]` key/secret) or `--apikey`/`--apisecret`.
- **Mutations** — `-X POST jobs/2/comments text=hello`, `-X DELETE jobs/67`, `-X DELETE jobs/2/comments/1`.
- **[Job-template](../concepts/openqa-job-templates.md) YAML** — fetch with `-a 'Accept: application/yaml' job_templates_scheduling/73`, validate with `openqa-validate-yaml`, POST back with a `reference` to guard against concurrent edits. Update job-group properties via `-X PUT /job_groups/N` (must include `name`).
- **Archive** — `openqa-cli archive 408 /tmp/job_408 [--with-thumbnails]` grabs all assets.
- **Conveniences** — `--o3` (openqa.opensuse.org) / `--osd` (openqa.suse.de) shortcuts, `--data`/`--data-file`/`--form`, pipes, UTF-8.
- **Extensible** — new subcommands are Perl plug-ins in `lib/OpenQA/CLI`. Companion tool: `openqa-mon` for live job monitoring.

## Related Pages

- [openqa-cli](../concepts/openqa-cli.md)
- [Jobs](../concepts/openqa-jobs.md)
- [Job templates](../concepts/openqa-job-templates.md)
- [openQA](../entities/openqa.md)
