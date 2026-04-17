---
title: "Immutable Infrastructure"
tags: [infrastructure, immutability, iac, operations, security]
sources: [owasp-iac-security.md]
updated: 2026-04-15
---

# Immutable Infrastructure

An operational model where infrastructure components are **never modified after deployment**. To change anything, you provision a new instance from updated specifications and retire the old one.

## Core Idea

> No deviation, no changes. If a change to a specification is required, then a whole new set of infrastructure is provisioned based on the updated requirements, and the previous infrastructure is taken out of service as obsolete.

## Security Benefits

- **No configuration drift**: The running state always matches the declared spec
- **Reduces attack persistence**: Attacker modifications don't survive the next deploy
- **Audit clarity**: Every state change is a new deployment with a traceable artifact
- **Forces declarative security**: Security controls must be in code, not applied ad-hoc

## Operational Pattern

```
spec change → build new image/artifact → test → deploy new → drain old → retire old
```

vs. mutable pattern:

```
spec change → SSH into running server → apply change → hope state is consistent
```

## Relation to Containers

Containers are a natural implementation of immutable infrastructure — images are built once, deployed, and replaced (not patched in-place). [Docker](../entities/docker.md) and [Podman](../entities/podman.md) support this model natively.

## Relation to Atomic Linux

[Atomic Linux](../concepts/atomic-linux.md) applies this same principle to the OS itself:
the root filesystem is read-only, updates deploy a new OS tree, and rollback is always
available. Technologies: [OSTree](../entities/ostree.md), NixOS, transactional-update.

## Sources

- [OWASP IaC Security Cheat Sheet](../sources/owasp-iac-security.md)
