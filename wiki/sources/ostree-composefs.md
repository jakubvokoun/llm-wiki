---
title: "Using composefs with OSTree"
tags: [ostree, composefs, fsverity, integrity, immutable, signing]
sources: [ostree-composefs.md]
updated: 2026-04-17
---

# Using composefs with OSTree

Source: `raw/ostree-composefs.md` — OSTree documentation on integrating composefs for
filesystem integrity.

> **Status: Experimental.** Do not deploy to production systems yet. Tracked at
> [ostreedev/ostree#2867](https://github.com/ostreedev/ostree/issues/2867).

## Key Takeaways

1. **composefs** is a hybrid Linux stacking filesystem (EROFS + overlayfs loop device) providing
   per-file fs-verity integrity for entire filesystem trees.
2. Three **integrity modes** configurable via `ostree/prepare-root.conf`:
   - `enabled = yes` — unsigned; resilient to accidental mutation, no kernel fsverity required
   - `enabled = verity` — validates backing OSTree objects via digest in `.ostree.cfs`
   - `enabled = signed` — full chain: Ed25519 signature covers the composefs fsverity digest
3. **Transient key pattern** — generate a new keypair per build, embed public key in initrd,
   sign OSTree commit, discard private key; ties each initrd to its exact userspace (prevents
   booting a new initrd with an old vulnerable userspace).
4. **composefs vs IMA** — composefs validates the entire filesystem tree (not just individual
   files), makes files actually read-only, and uses on-demand fs-verity (vs IMA's full readahead
   by default).
5. **Compatibility caveat** — the `chattr -i / && mkdir /somedir` trick for adding top-level
   directories no longer works; use `root.transient` in `prepare-root.conf` instead.

## Configuration

```ini
# /usr/lib/ostree/prepare-root.conf  (or /etc/ostree/prepare-root.conf)

# Unsigned mode (accidental mutation protection only)
[composefs]
enabled = yes

# Signed mode (full integrity chain)
[composefs]
enabled = signed
keyfile = /path/to/ed25519-public.key
```

## Injecting Digest at Build Time

```bash
# When committing, inject composefs digest as metadata
ostree commit --generate-composefs-metadata \
  -b exampleos/x86_64/standard \
  --tree=dir=/path/to/rootfs

# Sign the commit (covers the composefs digest)
ostree sign --sign-type=ed25519 \
  --keys-file=private.key \
  exampleos/x86_64/standard
```

## Kernel Requirements

```
CONFIG_OVERLAY_FS=y
CONFIG_BLK_DEV_LOOP=y
CONFIG_EROFS_FS=y
```

No additional userspace runtime requirements at this time.

## Transient Key Pattern

```
1. Generate new Ed25519 keypair before each build
2. Embed public key in initrd (part of the OSTree commit)
3. Set [composefs] enabled=signed in prepare-root.conf
4. After ostree commit, run ostree sign with private key
5. Discard private key
```

Result: each initrd authenticates only the exact userspace it was built with. Compromise of
one build's private key does not affect past or future builds.

## Comparison: composefs vs IMA

| Property                  | composefs              | IMA                                      |
| ------------------------- | ---------------------- | ---------------------------------------- |
| Scope                     | Entire filesystem tree | Individual files                         |
| Files read-only?          | Yes                    | No (by default)                          |
| Verification mode         | On-demand (fs-verity)  | Full readahead by default                |
| fs-verity backend?        | Always                 | Optional                                 |
| OSTree integration status | Experimental           | Stable (see [IMA source](ostree-ima.md)) |

## Related

- [OSTree /var Handling](ostree-var.md) — `root.transient` for mutable top-level dirs
- [OSTree Authenticated Remote Repositories](ostree-authenticated-repos.md) — remote signing
- [OSTree (entity)](../entities/ostree.md)
- [Immutable Infrastructure](../concepts/immutable-infrastructure.md)
