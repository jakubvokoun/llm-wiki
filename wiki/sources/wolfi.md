---
title: "Wolfi README"
tags: [linux, containers, distroless, container-security, chainguard]
sources: [wolfi.md]
updated: 2026-06-14
---

# Wolfi README

Package-repository README for [Wolfi](../entities/wolfi.md), the container-native (un)distribution behind [Chainguard](../entities/chainguard.md) images.

## Key Takeaways

- **Lightweight, minimalist GNU/Linux** distribution designed for containers (built with [apko](https://github.com/chainguard-dev/apko)) and embedded systems — not a general-purpose desktop OS.
- Built with **melange**; sponsored by Chainguard, which uses it for its [container images](../entities/chainguard.md).
- **apk** packages served from `packages.wolfi.dev/os`, signed with a published RSA key. Quick try: `docker run -it cgr.dev/chainguard/wolfi-base`.
- Uses **glibc** (unlike Alpine's musl). **Packages are NOT compatible with Alpine** despite both using apk — mixing distros is unsupported and a security risk.
- Keeps packages tightly patched; requires an actively maintained upstream and FSF/OSI-approved license for inclusion.

## Related

- [Wolfi](../entities/wolfi.md) · [Chainguard](../entities/chainguard.md) · [Distroless Images](../concepts/distroless-images.md)
