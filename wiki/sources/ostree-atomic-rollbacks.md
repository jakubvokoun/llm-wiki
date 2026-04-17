---
title: "OSTree Atomic Rollbacks"
tags: [ostree, atomic-linux, rollback, bootloader, systemd]
sources: [ostree-atomic-rollbacks.md]
updated: 2026-04-17
---

# OSTree Atomic Rollbacks

OSTree maintains two bootloader entries at all times — `ostree:0` (latest) and
`ostree:1` (latest − 1) — enabling rollback without data loss.

## Rollback mechanisms

### Manual rollback

Bootloaders with interactive UIs (GRUB, syslinux) expose multiple boot entries.
Selecting the previous entry at boot time rolls back to the prior deployment.
For Android-style AB bootloaders, an AB-switching tool triggers a slot swap.

### Automatic rollback via greenboot

[greenboot](https://github.com/fedora-iot/greenboot) integrates with the
bootloader to detect failed boots and automatically select the rollback
deployment on the next attempt.

## Boot entry diagram

```
+------------------+    +------------------------------------------------+
|                  |    |                                                |
|                  |    |      (ostree:0) latest     (multi-user.target) |
| Bootloader       |--->+ root                                           |
|                  |    |      (ostree:1) latest - 1 (multi-user.target) |
|                  |    |                                                |
+------------------+    +------------------------------------------------+
```

## Alternate technique: rescue target

Instead of booting an older OS version, a rollback can boot into an alternate
systemd target (e.g., `rescue.target`) while keeping the same deployment.

Detection uses `ostree admin status -D`:

- `default` → booted into the latest deployment (happy path)
- `not-default` → a rollback occurred; trigger `rescue.target`

A minimal early-boot service (`ostree-rollback-to-rescue.service`) runs before
`cryptsetup.target` and calls a script that issues
`systemctl --no-block isolate rescue.target` when the status is `not-default`.

This approach is useful when you want the latest OS binaries but need a
controlled recovery environment rather than a full system rollback.

## Key commands

```bash
ostree admin status       # list deployments
ostree admin status -D    # output "default" or "not-default"
```

## Related pages

- [OSTree Deployments](ostree-deployment.md) — deployment model and BLS integration
- [OSTree Atomic Upgrades](ostree-atomic-upgrades.md) — upgrade pipeline
- [Atomic Linux](../concepts/atomic-linux.md) — broader immutable Linux context
- [OSTree](../entities/ostree.md) — OSTree entity page
