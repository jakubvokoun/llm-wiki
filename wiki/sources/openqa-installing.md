---
title: "openQA — Installing"
tags: [openqa, testing, installation, opensuse, kubernetes]
sources: [openqa-installing.md]
updated: 2026-06-23
---

# openQA — Installing

Official installation/operations guide for an [openQA](../entities/openqa.md) instance.

## Key Takeaways

- **Container setup** — single-instance container, or separate web-UI + worker containers, with custom config mounted in; also a [Kubernetes](../entities/kubernetes.md) path (see the [Helm chart](openqa-helm-readme.md)).
- **Quick bootstrapping (openSUSE)** — `openqa-bootstrap` (directly on host, in a browser, in a container, or in a VM) for a fast working instance.
- **Custom installation** — official + development-version package repos for Tumbleweed/Leap/SLE/Fedora; system requirements; basic config.
- **Web UI serving** — behind an **Apache** or **NGINX** reverse proxy, with optional **TLS/SSL**; PostgreSQL **database** setup; **OpenID** user authentication config; job-priority throttling. Notes on **zero-downtime upgrades**.
- **Workers** — run via systemd units; configurable **WORKER_CLASS**, remote workers, **AMQP** event emission (RabbitMQ), asset/test/needle **caching**, and an optional **local LLM server**.
- **Advanced config** — cleanup policies, **git support** for tests/needles, referer-based auto-marking of important jobs, scheduler tuning incl. **dynamic job-limit scaling** by system load.

## Related Pages

- [openQA](../entities/openqa.md) · [Architecture](../concepts/openqa-architecture.md) · [Helm chart](openqa-helm-readme.md) · [Kubernetes](../entities/kubernetes.md) · [Dev setup](openqa-dev-getting-started.md)
