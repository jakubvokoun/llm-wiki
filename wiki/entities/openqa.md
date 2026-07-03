---
title: "openQA"
tags: [product, testing, automation, opensuse, qa]
sources:
  [
    openqa-getting-started.md,
    openqa-installing.md,
    openqa-writing-tests.md,
    openqa-users-guide.md,
    openqa-command-line.md,
    openqa-helm-readme.md,
    openqa-dev-getting-started.md,
    openqa-python-tests.md,
  ]
updated: 2026-06-23
---

# openQA

Free-software ([GPLv2](http://www.gnu.org/licenses/gpl-2.0.html)) automated testing tool for whole operating systems. It drives a virtual machine through an entire installation/usage flow, checking the screen and serial console at every step and sending the keystrokes/commands needed to proceed — testing software the way a human would, without requiring any hooks or cooperation from the system under test (SUT).

Originated at [SUSE](suse.md)/openSUSE; used as the release-quality gate for [openSUSE](suse.md), [Fedora](fedora.md), Debian and others. Home page [open.qa](https://open.qa/); source in the [os-autoinst GitHub org](https://github.com/os-autoinst).

## What it does

- Runs many **combinations** of hardware config, install options and product variant for every revision of an OS, reporting per-combination errors.
- Interacts purely via screen ([needle](../concepts/needle-matching.md) image matching), serial console, mouse and keyboard — black-box, toolkit-agnostic.
- Produces video, screenshots and a JSON results file per run.

## Architecture (two layers)

- **[os-autoinst](os-autoinst.md)** — the standalone test engine that creates the VM and runs the test scripts.
- **openQA** itself — web UI + REST-like API + scheduler + worker infrastructure that runs os-autoinst [jobs](../concepts/openqa-jobs.md) in a distributed way across one or many hosts. See [openQA Architecture](../concepts/openqa-architecture.md).

## Key surfaces

- [openQA architecture](../concepts/openqa-architecture.md) — web UI, scheduler, websocket server, workers, config files
- [Test API](../concepts/openqa-test-api.md) — the `testapi` DSL (Perl/Python/Lua) used to write [test modules](../concepts/openqa-test-api.md)
- [Needle matching](../concepts/needle-matching.md) — fuzzy screenshot assertions
- [Jobs](../concepts/openqa-jobs.md) — lifecycle, states, results, cloning, scenarios
- [Job templates](../concepts/openqa-job-templates.md) — YAML automation of job creation
- [openqa-cli](../concepts/openqa-cli.md) — command-line client over the REST API

## Related Pages

- [os-autoinst](os-autoinst.md)
- [SUSE](suse.md)
- [Fedora](fedora.md)
- [Kubernetes](kubernetes.md)
- Analyses: [Evaluating openQA: a POC plan and decision framework](../analyses/openqa-poc-evaluation.md)
- Sources: [Getting Started](../sources/openqa-getting-started.md)
- [Installing](../sources/openqa-installing.md)
- [Writing Tests](../sources/openqa-writing-tests.md)
- [Users Guide](../sources/openqa-users-guide.md)
- [Helm chart](../sources/openqa-helm-readme.md)
- [CLI](../sources/openqa-command-line.md)
- [Dev setup](../sources/openqa-dev-getting-started.md)
- [Python tests](../sources/openqa-python-tests.md)
