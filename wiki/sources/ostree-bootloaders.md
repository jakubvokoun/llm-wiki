---
title: "OSTree Bootloader Integration"
tags: [ostree, atomic, linux, bootloader, grub, android, bootupd]
sources: [ostree-bootloaders.md]
updated: 2026-04-17
---

# OSTree Bootloader Integration

How OSTree integrates with GRUB, Android aboot, bootupd, and Anaconda.

## Key Takeaways

1. **Happy path — BLS only.** OSTree writes Boot Loader Specification (BLS) entries to
   `/boot/loader/entries`. On start, GRUB reads those files via the `blscfg` verb. No extra
   scripting needed.
2. **Legacy GRUB fallback.** If GRUB doesn't support `blscfg`, the `ostree-grub2` script (shipped
   on Fedora) runs `grub2-mkconfig`. OSTree detects GRUB files and falls back automatically.
3. **Android aboot.** For Android bootloaders, OSTree still writes BLS metadata but the
   bootloader does not read it. Instead:
   - `aboot-update` generates Android Boot Images (signed binary blobs with kernel+initramfs+cmdline+dtb)
   - `aboot-deploy` reads the current slot (`androidboot.slot_suffix=` karg), writes to the
     alternate `boot_a` / `boot_b` partition, and sets `/ostree/root.a` or `/ostree/root.b`
     symlinks
   - Caution: firmware must not inject `ro` or `root=` kargs — these are incompatible with OSTree
4. **os-prober hazard.** GRUB's `os-prober` component scans all block devices; can impede
   reliable OS updates. Disable it if dual-booting is not needed.
5. **bootupd.** Ships static GRUB configs. When using bootupd, set `sysroot.bootloader = none`
   in OSTree config (except on s390x). Relies on `blscfg` support in GRUB (available on Fedora
   derivatives).
6. **Anaconda.** Now supports bootupd (via PR #5298); previously required `grub2-mkconfig`
   directly.

## Android A/B Slot Diagram

```
+-----------------------------+    +------------------+    +---------------------------------+
|  bootloader_a appends karg: |    |                  |    |                                 |
|  androidboot.slot_suffix=_a +--->+ boot_a partition +--->+  /ostree/root.a -> ...          |
+-----------------------------+    +------------------+    |                                 |
                                                           | system partition                |
+-----------------------------+    +------------------+    |                                 |
|  bootloader_b appends karg: |    |                  |    |  /ostree/root.b -> ...          |
|  androidboot.slot_suffix=_b +--->+ boot_b partition +--->+                                 |
+-----------------------------+    +------------------+    +---------------------------------+
```

## Bootloader Configuration Summary

| Bootloader       | OSTree config (`sysroot.bootloader`) | Mechanism                                        |
| ---------------- | ------------------------------------ | ------------------------------------------------ |
| GRUB with blscfg | `auto` (default)                     | Writes BLS entries; GRUB reads directly          |
| Legacy GRUB      | auto-detected → runs grub2-mkconfig  | `ostree-grub2` script fallback                   |
| bootupd + GRUB   | `none` (except s390x)                | Static GRUB config reads BLS via blscfg          |
| Android aboot    | `auto`                               | BLS as metadata only; aboot-deploy manages slots |

## Related

- [OSTree Deployments](../sources/ostree-deployment.md) — BLS entry creation during staged deployments
- [OSTree Atomic Upgrades](../sources/ostree-atomic-upgrades.md) — power-cut safe update flow
- [OSTree Atomic Rollbacks](../sources/ostree-atomic-rollbacks.md) — dual-entry rollback mechanism
- [OSTree](../entities/ostree.md)
