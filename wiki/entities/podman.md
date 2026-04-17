---
title: "Podman"
tags: [product, containers, runtime, security]
sources: [owasp-docker-security.md]
updated: 2026-04-15
---

# Podman

OCI-compliant container management tool developed by Red Hat. Docker-compatible CLI with stronger secure defaults.

## Security Advantages over Docker

| Feature          | Docker                          | Podman                                  |
| ---------------- | ------------------------------- | --------------------------------------- |
| Architecture     | Central daemon (`dockerd`)      | Daemonless (fork-exec)                  |
| Root requirement | Daemon runs as root by default  | Rootless by default                     |
| SELinux          | Optional                        | Built-in integration                    |
| Privilege scope  | Root daemon owns all containers | Containers run under user's permissions |

## When to Prefer Podman

- Environments where security is paramount
- Rootless deployments required
- SELinux enforcing environments (RHEL, Fedora)
- When Docker daemon's root requirement is unacceptable

## Related

- [Docker](docker.md)
- [Container Security](../concepts/container-security.md)
