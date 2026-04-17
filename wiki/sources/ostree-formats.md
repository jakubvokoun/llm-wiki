---
title: "OSTree Data Formats"
tags: [ostree, atomic-linux, archive, static-deltas, bsdiff, repository]
sources: [ostree-formats.md]
updated: 2026-04-17
---

# OSTree Data Formats

OSTree is designed around **static webservers** (S3, CDN, nginx) — no "smart server" like
git's dynamic pack computation. This shapes all its wire formats.

## Repository formats

| Format                   | Description                                                           | Use case                                              |
| ------------------------ | --------------------------------------------------------------------- | ----------------------------------------------------- |
| `archive` (`archive-z2`) | Content objects gzip-compressed; metadata uncompressed; HTTP-servable | Remote repo served over HTTP                          |
| `bare`                   | Files stored directly; uid/gid/xattrs reflected to filesystem         | Local repo, requires root                             |
| `bare-user`              | uid/gid/xattrs ignored; works unprivileged                            | Shared content for host + unprivileged containers     |
| `bare-split-xattrs`      | xattrs stored as separate objects, not applied to filesystem          | SELinux labels through containerized/tar environments |

### archive trade-offs

- **Pros:** static HTTP servable, incremental downloads, content-addressed dedup
- **Cons:** one HTTP request per changed file (mitigated by HTTP/2); no total size known upfront; slow initial pull

## Static deltas

Pre-computed binary diffs between two specific commits. Trade server storage for client
bandwidth — useful for infrequent (monthly) OS update schedules.

```
server computes delta(old_commit, new_commit)
  → stored in: deltas/$fromprefix/$fromsuffix-$to
client fetches superblock → downloads delta parts → reconstructs new objects
```

### Structure

```
delta/
  superblock    ← metadata, timestamp, new commit, part index, fallback object list
  0             ← delta part 0 (raw blob + bytecode instructions)
  1             ← delta part 1
  ...
```

Delta parts contain a raw data blob plus a **restricted bytecode** ("updates as code") inspired
by ChromiumOS autoupdate. Bytecode instructions reference sections of the blob to reconstruct
objects, enabling shared-section deduplication.

### bsdiff per-file deltas

For changed executable files with matching basenames and similar sizes, OSTree applies
[bsdiff](https://github.com/mendsley/bsdiff) (works well on binary/executable content).
The bsdiff payload is embedded in the delta part, applied by a bytecode instruction.

### Fallback objects

Files with internal compression (e.g. initramfs, compressed archives) resist bsdiff. These are
listed in the superblock as "fallback objects" and fetched directly as `.filez` objects from
the underlying archive repo.

### from-NULL deltas

Deltas with no source commit enable efficient initial population — mainly useful for
container use cases rather than OS image deployment (which typically starts from an ISO/qcow2).

## Related pages

- [Anatomy of an OSTree Repository](ostree-repo.md) — object model and repo structure
- [OSTree Atomic Upgrades](ostree-atomic-upgrades.md) — how deltas fit into the upgrade pipeline
- [OSTree Static Deltas for Offline Updates](ostree-copying-deltas.md) — air-gap / USB delta transfer
- [OSTree](../entities/ostree.md) — OSTree entity page
