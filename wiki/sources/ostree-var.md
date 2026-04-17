---
title: "OSTree /var Handling"
tags: [ostree, atomic-linux, var, state-management, systemd, tmpfiles]
sources: [ostree-var.md]
updated: 2026-04-17
---

# OSTree /var Handling

OSTree treats `/var` as shared mutable state across all deployments — equivalent to Docker's
`VOLUME /var`. Understanding the semantics prevents silent configuration drift.

## Initial population (OSTree ≥ 2024.3)

When a commit is first deployed and the stateroot `/var` is **empty**, OSTree copies the
commit's `/var` content into the stateroot. On subsequent upgrades this copy does **not**
repeat — existing files are never overwritten or deleted.

Recommended approach in order of preference:

1. **`StateDirectory=`** in systemd units — cleanest, per-unit ownership
2. **`tmpfiles.d` snippets** — resilient firstboot directory creation
3. Docker-like initial `/var` seed — convenient but drift-prone

## Pitfalls

| Situation                                 | Problem                                       |
| ----------------------------------------- | --------------------------------------------- |
| Updated file in image `/var`              | Change never reaches deployed system          |
| File deleted from image `/var`            | Old file remains on disk forever              |
| RPM/deb content in `/opt` (`/var/opt`)    | Package updates don't reflect on disk         |
| Container images in `/var/lib/containers` | Bad idea — same drift + large size            |
| Static content in `/var/www/html`         | Belongs in `/usr` or an application container |

## /opt drift and solutions

OSTree's "strict" layout maps `/opt → /var/opt`. Packages that write to `/opt` will drift as
the package updates. Fixes:

- **`composefs.enabled = true`** — `/opt` becomes immutable (content in commit, not var)
- **`root.transient = true`** — `/opt` writable but transient (wiped each boot)

Configure via `ostree-prepare-root.conf`.

## Historical: factory/var mechanism (2023.8 – 2024.3)

Versions 2023.8–2024.3 used `tmpfiles.d` with `C+! /var - - - - -` to copy new files from
`/usr/share/factory/var` on each upgrade boot. This was reverted in 2024.3 in favour of the
simpler one-time-copy semantic described above.

## Related pages

- [OSTree Deployments](ostree-deployment.md) — /etc 3-way merge, stateroot layout
- [OSTree](../entities/ostree.md) — OSTree entity page
- [Atomic Linux](../concepts/atomic-linux.md) — broader context
