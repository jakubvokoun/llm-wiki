---
title: "OSTree Deployments"
tags: [ostree, atomic, linux, deployment, bootloader]
sources: [ostree-deployment.md]
updated: 2026-04-17
---

# OSTree Deployments

How OSTree manages bootable OS deployments via `ostree admin`.

## Key Takeaways

1. **Deployment path:** `/ostree/deploy/$stateroot/deploy/$checksum` — each deployment is a
   hardlink farm into the OSTree repo, intended as a `chroot()` target.
2. **Stateroot** groups deployments that share a single `/var`. Multiple OSes can be
   parallel-installed in different stateroots (e.g. `debian`, `rhel`).
3. **Only `/etc` and `/var` are mutable.** Everything else is read-only hardlinks. Content
   should live in `/usr`; OSTree does not prescribe `/var` contents.
4. **3-way `/etc` merge on deployment creation:** old default `/usr/etc` + current live
   `/etc` + new default `/usr/etc` → new deployment's `/etc`.
5. **Staged deployments** (`ostree admin upgrade --stage`) delay the `/etc` merge and
   bootloader update until reboot (via `ostree-finalize-staged.service`). Prevents losing
   `/etc` edits made after staging but before rebooting.
6. **Bootloader via BLS.** Config files written to
   `/boot/loader/entries/ostree-$stateroot-$checksum.$serial.conf`. Special `ostree=` kernel
   arg lets the initramfs `chroot()` into the right deployment. Fallback to native configs
   (syslinux, etc.) where BLS is not supported.
7. **Kernel location:** `/usr/lib/modules/$kver/vmlinuz` (current standard); boot checksum
   pre-computed and embedded in filename for sharing across deployments.

## Deployment Lifecycle

```
ostree admin upgrade          ← fetch new commit, create deployment
  ↓ (3-way /etc merge)
new deployment staged
  ↓
reboot → BLS entry → initramfs → chroot into deployment
  ↓
old deployment retained for rollback
```

With staging (`--stage`):

```
ostree admin upgrade --stage  ← create deployment, delay /etc merge
  ↓
reboot → ostree-finalize-staged.service → /etc merge → BLS update → chroot
```

## Stateroot / osname

```
/ostree/deploy/
  fedora/                ← stateroot
    var/                 ← shared /var for all fedora deployments
    deploy/
      abc123.../         ← deployment A (previous)
      def456.../         ← deployment B (current)
```

## Related

- [OSTree entity](../entities/ostree.md)
- [OSTree Repository Anatomy](../sources/ostree-repo.md)
- [OSTree Introduction](../sources/ostree-introduction.md)
- [Atomic Linux](../concepts/atomic-linux.md)
