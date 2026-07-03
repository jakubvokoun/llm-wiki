---
title: "openQA Architecture"
tags: [openqa, testing, architecture, distributed-systems]
sources:
  [
    openqa-getting-started.md,
    openqa-installing.md,
    openqa-dev-getting-started.md,
    openqa-helm-readme.md,
  ]
updated: 2026-06-23
---

# openQA Architecture

[openQA](../entities/openqa.md) is split into a test engine and a distributed orchestration layer.

## Components

- **[os-autoinst](../entities/os-autoinst.md)** — the test engine. Creates a VM, runs the test scripts, emits video + screenshots + JSON results.
- **Web UI / web app** — Mojolicious application providing the browser UI and a **JSON REST-like API**. Entry point `WebAPI.pm`; configured via `Setup.pm`.
- **Scheduler** — distributes [jobs](openqa-jobs.md) among workers.
- **Websocket server** — channel over which workers talk to the web UI (`openqa-websockets`).
- **Workers** — fetch data and input files from the web UI and invoke os-autoinst to run the actual tests. A single host can run several worker instances (`--instance N`). Workers and web app may run on the same machine, across a network, or in the cloud.

The web app + workers can be co-located or distributed arbitrarily; remote workers connect back over the network.

## Configuration files

Under `/etc/openqa` (system-wide) or `/usr/etc/openqa` (package defaults); client config also at `~/.config/openqa/client.conf`:

- `openqa.ini` — web UI / scheduler config
- `database.ini` — DB connection for web-UI services
- `workers.ini` — worker (and cache service) config
- `client.conf` — API key/secret per web-UI host, used by workers, [`openqa-cli`](openqa-cli.md), `openqa-clone-job`

Each supports **drop-in** `*.d/*.ini` (or `.conf`) directories read in alphabetical order; later files override earlier ones and override the main file. Missing files fall back to defaults.

## Access management

Authentication via **OpenID** (default: the openSUSE provider; configurable). Each login auto-creates a user profile with two flags: **operator** (manage jobs) and **admin** (manage users, job templates). API clients (workers, schedulers, scripts) authenticate with an **API key + shared secret** tied to an operator user. See also [Authentication](authentication.md) and [Authorization](authorization.md).

## Deployment

- Native packages on openSUSE/Fedora (systemd units), container images, or a [Helm chart](../sources/openqa-helm-readme.md) for [Kubernetes](../entities/kubernetes.md) (parent `openqa` chart with `webui` + `worker` sub-charts; uses the Gateway API for ingress).
- Workers can use an **asset/test/needle cache** service, AMQP message emission (RabbitMQ) for events, and dynamic job-limit scaling based on system load.

## Related Pages

- [openQA](../entities/openqa.md)
- [os-autoinst](../entities/os-autoinst.md)
- [Jobs](openqa-jobs.md)
- [openqa-cli](openqa-cli.md)
- [Installing (source)](../sources/openqa-installing.md)
- [Helm chart (source)](../sources/openqa-helm-readme.md)
