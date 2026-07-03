---
title: "openqa-cli (Command-Line Client)"
tags: [openqa, cli, rest-api, automation]
sources:
  [openqa-command-line.md, openqa-getting-started.md, openqa-users-guide.md]
updated: 2026-06-23
---

# openqa-cli

The command-line client for [openQA](../entities/openqa.md)'s JSON REST-like API — the scriptable counterpart to the web UI. Part of the openQA source (`lib/OpenQA/CLI`, built on Mojolicious).

## Basics

```bash
openqa-cli api --host openqa.opensuse.org jobs/overview   # GET
openqa-cli api --pretty jobs/1222737                      # pretty JSON
```

- Talks to **localhost by default**; override with `--host`, or shortcuts `--o3` (openqa.opensuse.org) and `--osd` (openqa.suse.de).
- `--pretty` formats JSON; `-a 'Accept: application/yaml'` requests YAML.
- HTTP verbs via `-X POST|PUT|DELETE`; data via positional `KEY=VALUE`, `--data '{...}'`, `--data-file f.json`, or `--form`. Full UTF-8 and pipes supported.

## Authentication

Operations that change state need an **API key + secret** (operator user). Stored per host in `client.conf` (`~/.config/openqa/client.conf`), or passed with `--apikey` / `--apisecret`. See [openQA architecture → access management](openqa-architecture.md).

## Common operations

```bash
# Schedule a product (fans out via job templates)
openqa-cli api -X POST isos ISO=…iso DISTRI=opensuse VERSION=Tumbleweed FLAVOR=DVD ARCH=x86_64 BUILD=0053

# Schedule a single job; -m waits for results
openqa-cli schedule DISTRI=sle VERSION=15 FLAVOR=Online ARCH=x86_64 TEST=qam-all

openqa-cli api -X POST jobs/2/comments text=hello   # post comment
openqa-cli api -X DELETE jobs/67                     # delete job
openqa-cli archive 408 /tmp/job_408 --with-thumbnails  # download all assets
```

`schedule` is sugar for `api -X POST isos`. Sibling tools: `openqa-clone-job` / `openqa-clone-custom-git-refspec` (see [Jobs → cloning](openqa-jobs.md)), `openqa-load-templates`, `openqa-validate-yaml`.

## Extensibility

Each subcommand is a Perl plug-in: drop a `lib/OpenQA/CLI/foo.pm` (`package OpenQA::CLI::foo`, `use Mojo::Base 'OpenQA::Command'`) and `openqa-cli foo` (and its `--help`) just work.

## Related Pages

- [Jobs](openqa-jobs.md)
- [Job templates](openqa-job-templates.md)
- [Architecture](openqa-architecture.md)
- [openQA](../entities/openqa.md)
- [Command line (source)](../sources/openqa-command-line.md)
