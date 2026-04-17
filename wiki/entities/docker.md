---
title: "Docker"
tags: [product, containers, runtime]
sources: [owasp-docker-security.md]
updated: 2026-04-15
---

# Docker

The most widely used containerization platform. Packages applications and dependencies into containers via a daemon (`dockerd`) and CLI.

## Security Posture

Docker has good defaults but many misconfigurations are common. See [OWASP Docker Security Cheat Sheet](../sources/owasp-docker-security.md) for the full 13-rule checklist.

**Key risk areas:**

- Docker socket exposure (`/var/run/docker.sock`) = root equivalent
- Running as root inside containers
- `--privileged` flag grants all Linux capabilities
- Published ports bypass host firewalls (UFW, iptables)
- Default Docker daemon runs as root (vs. rootless mode)

## Alternatives

- [Podman](podman.md) — rootless, daemonless, SELinux-native
