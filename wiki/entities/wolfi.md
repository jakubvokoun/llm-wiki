---
title: "Wolfi"
tags: [product, linux, containers, container-security, distroless]
sources: [wolfi.md]
updated: 2026-06-14
---

# Wolfi

A lightweight, container-native GNU/Linux **(un)distribution** designed around minimalism for containerized and embedded workflows. Named after the smallest octopus. Sponsored by [Chainguard](chainguard.md), which uses it to build its [container images](chainguard.md).

## Characteristics

- **Container-first**, not a general-purpose desktop OS — ships only packages that enable container/embedded use.
- Uses **glibc** (unlike Alpine's musl), which avoids source-build pain for native dependencies (e.g. many Python wheels ship glibc-only).
- Built with [melange](https://github.com/chainguard-dev/melange); images assembled with [apko](https://github.com/chainguard-dev/apko).
- Distributed as **apk** packages from `packages.wolfi.dev/os`, signed with a published RSA key.
- Aims to keep packages tightly up-to-date with security patches; every package must have an actively maintained upstream and an FSF/OSI-approved license.

## Caveat

Although Wolfi and Alpine both use the `apk` package manager, **their packages are not compatible** — mixing packages across distributions is unsupported and can create security problems.

## Try it

```
docker run -it cgr.dev/chainguard/wolfi-base
```

## Relation to distroless

Wolfi is the base layer for [Chainguard](chainguard.md)'s [distroless-style images](../concepts/distroless-images.md) — a container-native distro built _for_ the distroless use case, contrasted with Google [distroless](distroless.md)'s approach of stripping down Debian.

## Sources

- [Wolfi README](../sources/wolfi.md)
