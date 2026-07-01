---
title: "Tilt Product FAQ"
tags: [tilt, kubernetes, microservices, docker]
sources: [tilt-product-faq]
updated: 2026-07-01
---

# Tilt Product FAQ

Official FAQ from [docs.tilt.dev/product_faq.html](https://docs.tilt.dev/product_faq.html). Covers what [[tilt]] is, who it is for, and project governance.

## What Is Tilt?

[[tilt]] is a **microservice development environment** for teams that deploy to [[kubernetes]]. It is free and open-source.

Traditional dev tools focused on files (source → binary → output). Modern apps are composed services — managed databases, frontend servers, web apps — all communicating over HTTP. Tilt understands how files and servers fit together and surfaces that as a unified development environment.

**One-command startup:** after setup, any contributor runs `tilt up` to get a complete dev environment.

## Target Teams

Tilt targets teams building multi-service apps where pain points include:

- Managing multiple terminal windows to tail logs from several servers
- Distinguishing meaningful error logs from noise
- Fragile shell scripts (`start.sh`) that set up dev servers

## Why Kubernetes?

Kubernetes defines well-adopted building blocks — containers, pods, services — that are becoming industry standards. Tilt advocates using those same primitives in local dev, not only on managed clouds (AWS/AKS/GKE).

Tilt also supports:

| Alternative          | How                                                   |
| -------------------- | ----------------------------------------------------- |
| [[docker]]-Compose   | Run containers via `docker_compose()` in [[tiltfile]] |
| Local shell commands | `local_resource()` in [[tiltfile]]                    |

Other-system support is primarily a migration aid to ease teams moving from Docker Compose to Kubernetes.

## Governance

| Topic              | Detail                                             |
| ------------------ | -------------------------------------------------- |
| Original team      | Tilt.dev start-up                                  |
| Acquired           | May 2022 by Docker                                 |
| Open-source status | Maintained as open-source post-acquisition         |
| Mission            | Cloud-native development tools for every developer |

The Tilt team now works across Docker Compose and Docker Desktop, bringing Tilt ideas to the broader container ecosystem.

## Community & Support

- **Slack:** `#tilt` channel in [Kubernetes Slack](https://kubernetes.slack.com/messages/CESBL84MV/) — invite at slack.k8s.io. A Tilt developer is active weekdays 10am–5pm NYC time.
- **GitHub Issues:** [github.com/tilt-dev/tilt/issues](https://github.com/tilt-dev/tilt/issues/new) — acknowledgement expected within one business day.
- **Roadmap:** Driven by GitHub issues; filing one has influence even if not immediately visible.

## Gotchas / Notes

- No CLI commands, `Tiltfile` functions, or config options are documented here — this FAQ is purely conceptual/governance content.
- For API reference see [[tiltfile]], [[tilt-live-update]], [[tilt-extensions]], and [[tilt-control-loop]].
- Demo app referenced in docs is called **Servantes** (a Don Quixote reference — "Tilt" = tilting at windmills).
