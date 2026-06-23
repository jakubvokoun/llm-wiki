---
title: "Evaluating openQA: a POC plan and decision framework"
tags: [openqa, testing, poc, evaluation, os-testing]
sources:
  [
    openqa-getting-started.md,
    openqa-installing.md,
    openqa-writing-tests.md,
    openqa-users-guide.md,
    openqa-helm-readme.md,
    openqa-python-tests.md,
    openqa-command-line.md,
  ]
updated: 2026-06-23
---

# Evaluating openQA: a POC plan and decision framework

A reusable plan for running a proof-of-concept that decides whether [openQA](../entities/openqa.md) is the right tool to test a whole operating system or appliance — and a framework for turning that POC into an adopt / adopt-for-subset / reject decision. The deliverable of such a POC is a decision backed by evidence, not a production rollout.

## When openQA is the right question to ask

openQA earns its keep when you need to test things that happen **before** a normal in-system test harness can attach — i.e. before SSH, an agent, or an API is available:

- the **installer** (partitioning, bootloader, install options, product variants),
- **first boot** and provisioning,
- **interactive upgrades** and the reboot behaviour around them,
- **console / TTY** behaviour and early-boot failures,
- the combinatorial matrix of hardware configs, install options and variants per build.

It interacts purely via screen ([needle](../concepts/needle-matching.md) image matching), serial console, keyboard and mouse — black-box, with no hooks into the system under test. See [openQA](../entities/openqa.md) and [os-autoinst](../entities/os-autoinst.md).

If your testing only ever runs against an **already-provisioned, reachable host** (containers up, SSH open, API live), a conventional in-system harness (testinfra, pytest-over-SSH, Serverspec, Molecule) is simpler and faster, and openQA is likely overkill. openQA's strength is precisely the pre-reachable phase; reach for it when that phase is where your risk lives.

## How openQA fits together (POC-relevant minimum)

| Layer                                     | Role                                                                         | POC implication                          |
| ----------------------------------------- | ---------------------------------------------------------------------------- | ---------------------------------------- |
| [os-autoinst](../entities/os-autoinst.md) | Test engine: boots a QEMU VM, runs modules, emits video + screenshots + JSON | Worker host needs KVM / `/dev/kvm`       |
| Web UI + REST API                         | Mojolicious app; browser UI and JSON API                                     | Entry for triggering and inspecting runs |
| Scheduler + websocket server              | Distribute [jobs](../concepts/openqa-jobs.md) to workers                     | Single host is fine for a POC            |
| Workers                                   | Pull assets, invoke os-autoinst                                              | One worker, co-located, is enough        |

Tests are **[test modules](../concepts/openqa-test-api.md)** (Perl, or Python via `Inline::Python`) using the `testapi` DSL — `assert_screen`, `assert_and_click`, `send_key`, `type_string`, `assert_script_run`. A **[job](../concepts/openqa-jobs.md)** is one test-suite run in a VM; jobs are grouped and templated via [YAML job templates](../concepts/openqa-job-templates.md). Runs are triggered and inspected via [openqa-cli](../concepts/openqa-cli.md). See [Architecture](../concepts/openqa-architecture.md).

## POC scope that answers the question with least effort

In scope:

- Single-host instance (web UI + one worker, co-located).
- Register the target OS/appliance image as a medium (ISO to test the installer, or a pre-built disk image to skip install and test runtime — often both, as separate flavors).
- 3-4 representative test modules spanning the install -> boot -> health arc.
- A minimal needle set for the screens those modules assert.
- Trigger via `openqa-cli`, inspect in the web UI.

Out of scope (note as follow-ups if the POC is promising):

- CI integration (pipeline triggers openQA, gates a merge on the result via the REST API).
- Multi-machine scenarios (jobs coordinating via the synchronization/mutex API).
- Distributed/remote workers, asset cache service, AMQP event emission.
- Production [Helm](../sources/openqa-helm-readme.md)/[Kubernetes](../entities/kubernetes.md) deployment.

## Representative test cases

Pick 3-4 that each prove something a conventional in-system harness cannot:

| Module             | What it proves                                                 | Why a normal harness can't do it                            |
| ------------------ | -------------------------------------------------------------- | ----------------------------------------------------------- |
| `install`          | Installer runs to completion and reboots into the system       | Pre-SSH; installer is console/interactive                   |
| `first_boot`       | First-boot provisioning completes; login prompt / UI reachable | Pre-SSH boot sequence and console state                     |
| `core_services_up` | Key services come up after boot                                | Smoke gate from outside; cross-check vs the in-system suite |
| `upgrade`          | An upgrade applies cleanly and the system still boots          | Interactive upgrade flow + reboot behaviour                 |

## Deployment choices for the POC

Fastest-first; default to native packages unless an existing host makes another path cheaper.

| Method                                                   | Pros                                            | Cons                             | Use when                               |
| -------------------------------------------------------- | ----------------------------------------------- | -------------------------------- | -------------------------------------- |
| Native packages (openSUSE/Fedora)                        | Best-supported, systemd units, matches the docs | A distro to babysit              | Default for a throwaway POC VM         |
| Container images                                         | Isolated, disposable                            | Worker needs nested virt / KVM   | Comfortable with privileged containers |
| [Helm](../sources/openqa-helm-readme.md) on k3s/minikube | Closest to a k8s target                         | Gateway API + CRD setup overhead | Pre-validating a future k8s deploy     |

Hard prerequisite: the worker host **must** expose KVM/nested virtualization (`/dev/kvm`) — confirm before choosing a host. Without it, os-autoinst falls back to slow TCG software emulation (`qemu_no_kvm=1` on the worker) — fine for a smoke test, too slow for real install runs.

### Containerized scenarios (what the upstream repo actually ships)

The openQA repo's `container/` tree provides build contexts — `webui`, `worker`, `openqa_data`, and an all-in-one `single-instance` — plus the `helm/` chart. There is **no top-level `docker-compose.yaml`**; a compose file is something you author around these images. Two practical local scenarios:

**Docker / Compose.** The `single-instance` image (base `opensuse/tumbleweed`, entrypoint `openqa-bootstrap`) brings up a _complete_ instance in one container — web UI, scheduler, websockets, gru, an embedded worker, and PostgreSQL — exposing ports 80 / 443 / 9526. It is the fastest route to a working UI and the least representative of a distributed deploy. The standalone `worker` image (base `opensuse/leap`, entrypoint `run_openqa_worker.sh`) reads `OPENQA_WORKER_INSTANCE`, `qemu_no_kvm`, and `TEST_DISTRI_DEPS`; it does **not** self-register, so it needs a mounted `client.conf` (API key+secret) and `workers.ini` (`HOST`), plus `--device=/dev/kvm`. Persist `/var/lib/openqa` (assets, tests, needles, results, pool) and `/etc/openqa` (config).

**minikube / Helm.** Parent `openqa` chart with `webui` + `worker` sub-charts (see [Helm chart](../sources/openqa-helm-readme.md)). Install the Gateway API CRDs and an Envoy Gateway controller once, then `helm dependency update openqa/` and `helm install openqa openqa/`. Access via `minikube tunnel` + an `/etc/hosts` entry for the `baseUrl` host, or skip all gateway setup with `kubectl port-forward svc/openqa 8080:80`. The crux is worker-pod KVM access: minikube's `docker`/`kvm2` drivers don't pass nested virt through cleanly, so plan on a host with nested virt, the `--driver=none` driver, or the `qemu_no_kvm` software-emulation fallback.

|                        | Docker Compose (single-instance)  | minikube / Helm                    |
| ---------------------- | --------------------------------- | ---------------------------------- |
| Time to first green UI | Fastest (one container)           | Slower (CRDs + Envoy + chart deps) |
| Representativeness     | All-in-one, least like prod       | webui/worker split, closest to k8s |
| KVM handling           | `--device /dev/kvm` (simple)      | Pod device access (the hard part)  |
| Best for               | Authoring tests + needles quickly | Validating a future k8s deployment |

A sensible order: start on Docker single-instance to get tests and needles working with minimum yak-shaving, then port to Helm/minikube to surface the k8s-specific friction (chiefly worker KVM access) before committing.

## Execution outline

1. Confirm `/dev/kvm` on the chosen host; pick a deployment method.
2. Install openQA (see [Installing](../sources/openqa-installing.md), [Getting Started](../sources/openqa-getting-started.md)): web UI up, one worker registered, API key/secret in `~/.config/openqa/client.conf`.
3. Sanity-check the engine end to end by cloning a known public job before introducing your own image: `openqa-clone-job --from <public-instance> --host <local> <JOB_ID>`.
4. Place the target image in the asset dir (`factory/iso/` or `factory/hdd/`); define product/distri/version/flavor/arch. Scenario string: `<distri>-<version>-<flavor>-<arch>-<test_suite>@<machine>`.
5. Create a minimal test distribution: `main.pm` loading modules via `loadtest`, `tests/<module>.{pm,py}`, `needles/`. Python maps 1:1 to Perl `testapi` (`from testapi import *`; needs `Inline::Python` on the worker).
6. Build needles via the web UI needle editor; keep match areas tight, mark volatile regions (clocks, hostnames, IPs) as `exclude`.
7. Trigger runs (`openqa-cli api -X POST isos ISO=... DISTRI=... ...`), iterate a single module against a git ref with `openqa-clone-custom-git-refspec`, and review per-module results, video, and serial log in the web UI.

## Decision framework

Score the POC against each criterion with concrete evidence from the runs; the filled table is the deliverable.

| Criterion           | What to measure                                                                                                 |
| ------------------- | --------------------------------------------------------------------------------------------------------------- |
| Coverage gap closed | Does it test what a normal harness genuinely cannot (installer, boot, upgrade, console)? Concrete cases.        |
| Effort to author    | Time to write one module + its needles; how much is reusable across variants.                                   |
| Maintenance cost    | Needle brittleness across builds/UI changes; rate of non-bug run breakage. Usually the dominant long-term cost. |
| Speed               | Wall-clock per scenario vs the existing harness; parallelism across workers.                                    |
| Infra fit           | KVM requirement and openQA's openSUSE-leaning stack vs your platform direction.                                 |
| CI fit              | Can a pipeline trigger a run and gate on the result via the REST API? (scope it, don't build it)                |
| Team fit            | Perl vs Python authoring; learning curve.                                                                       |

Decision shape:

- **Adopt** — coverage gap is real, authoring/maintenance are acceptable, infra and CI fit.
- **Adopt for a subset** — use openQA only for the highest-value pre-SSH cases (often `install` and `upgrade`), keep the in-system harness for everything reachable.
- **Reject** — the risk lives in the reachable phase, or needle maintenance outweighs the coverage gained.

The common outcome for teams that already have a solid in-system suite is **adopt-for-subset**: openQA owns the installer/boot/upgrade arc, the existing harness owns post-boot health. The two are complementary, not competing.

## Related Pages

- [openQA](../entities/openqa.md) · [os-autoinst](../entities/os-autoinst.md) · [Architecture](../concepts/openqa-architecture.md)
- [Jobs](../concepts/openqa-jobs.md) · [Test API](../concepts/openqa-test-api.md) · [Needle matching](../concepts/needle-matching.md) · [Job templates](../concepts/openqa-job-templates.md) · [openqa-cli](../concepts/openqa-cli.md)
- [Continuous integration](../concepts/continuous-integration.md) · [SRE testing](../concepts/sre-testing.md)
- Sources: [Getting Started](../sources/openqa-getting-started.md) · [Installing](../sources/openqa-installing.md) · [Writing Tests](../sources/openqa-writing-tests.md) · [Helm chart](../sources/openqa-helm-readme.md) · [Python tests](../sources/openqa-python-tests.md) · [CLI](../sources/openqa-command-line.md)
