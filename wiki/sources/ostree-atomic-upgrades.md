---
title: "OSTree Atomic Upgrades"
tags: [ostree, atomic, linux, upgrades, bootloader, safety]
sources: [ostree-atomic-upgrades.md]
updated: 2026-04-17
---

# OSTree Atomic Upgrades

How OSTree guarantees fully atomic OS upgrades — no partial states, power-cut safe.

## Key Takeaways

1. **Power-cut safe.** If power is cut mid-upgrade, the system boots either the old or new
   deployment — never a partial state. OSTree never touches the running system until reboot.
2. **Delta HTTP pull.** `ostree admin upgrade` fetches only missing objects (zlib-compressed)
   from the remote; each object has its SHA256 checksum validated before storing.
3. **Boot config atomicity via symlink swap.** `/boot` is a symlink to `/ostree/boot.0` or
   `/ostree/boot.1`. Atomically swapping the symlink = zero-downtime bootloader update.
4. **Kernel deduplication.** Kernels stored in `/boot/ostree/<stateroot>-<sha256>`; hardlinked
   (not copied) when `/boot` is on the same partition as `/`.
5. **`/etc` 3-way merge semantics:**
   - Files you modified from defaults → **retained as-is**
   - Files you left at defaults → **upgraded to new defaults**
6. **Atomic deployment set transitions.** OSTree can atomically switch to an arbitrary set of
   deployments (e.g. 100 deployments for automated kernel bisection) in one operation, with
   the constraint that the currently booted deployment is always in the new set.

## Upgrade Flow

```
ostree admin upgrade
  ↓ fetch ref checksum from remote
  ↓ pull missing objects (SHA256-validated, zlib-compressed)
  ↓ assemble new deployment dir (hardlink farm)
  ↓ 3-way /etc merge
  ↓ write new BLS entry
  ↓ populate /ostree/boot.N (new version)
  ↓ atomically swap /boot symlink to /ostree/boot.N
  ↓ reboot → initramfs reads ostree= kernel arg → chroot into new deployment
```

## Boot Config Atomicity

```
/boot  →  /ostree/boot.0/   (current; read-only by default)
               kernel, initramfs, BLS entries

upgrade:
  populate /ostree/boot.1/ with new content
  rename /boot symlink: 0 → 1      ← single atomic operation
  gc /ostree/boot.0/ later
```

`/boot` can be a separate flash partition. OSTree remounts it read-write only during the
short window needed to update bootloader config, then back to read-only.

## Diagnosing `/etc` Drift

```bash
ostree admin config-diff    # files modified vs OSTree defaults
diff /usr/etc /etc          # line-level differences
```

## Related

- [OSTree entity](../entities/ostree.md)
- [OSTree Deployments](../sources/ostree-deployment.md)
- [Atomic Linux](../concepts/atomic-linux.md)
