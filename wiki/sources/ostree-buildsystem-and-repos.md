---
title: "OSTree Buildsystem and Repository Management"
tags: [ostree, atomic-linux, buildsystem, repository, rpm-ostree, static-deltas]
sources: [ostree-buildsystem-and-repos.md]
updated: 2026-04-17
---

# OSTree Buildsystem and Repository Management

OSTree is a **content transport layer**, not a package manager. Build tools commit completed
directory trees (or tarballs) into OSTree; OSTree handles signing, dedup, delta generation, and
bootloader updates.

## Build vs buy

Existing tools that commit into OSTree:

- **rpm-ostree** — takes RPMs, commits them as an OS tree (Fedora Atomic)
- **OpenEmbedded** — outputs tarballs, committed via `ostree commit --tree=tar=`

Or roll your own: install packages into a temp root, then commit:

```bash
$pkginstallroot /path/to/tmpdir
ostree --repo=repo commit -s 'build' -b exampleos/x86_64/standard --tree=dir=/path/to/tmpdir
```

## Two-repository build pattern

For speed, use two repos:

| Repo            | Mode        | Purpose                                      |
| --------------- | ----------- | -------------------------------------------- |
| `build-repo`    | `bare-user` | Fast checkouts via hardlinks; no compression |
| `repo` (export) | `archive`   | gzip-compressed; served over static HTTP     |

### Workflow

```bash
# 1. Commit individual packages into build-repo
ostree --repo=build-repo commit -b exampleos/x86_64/bash --tree=tar=bash-4.2-bin.tar.gz
ostree --repo=build-repo commit -b exampleos/x86_64/systemd --tree=tar=systemd-224-bin.tar.gz

# 2. Union-checkout packages into a merged tree
for pkg in bash systemd; do
  ostree --repo=build-repo checkout -U --union exampleos/x86_64/$pkg exampleos-build
done

# 3. Mount rofiles-fuse to protect hardlinks during post-processing
rofiles-fuse exampleos-build mnt
ldconfig -r mnt          # run global triggers (cache regeneration etc.)
fusermount -u mnt

# 4. Commit final tree (--link-checkout-speedup: inode→checksum reverse map)
ostree --repo=build-repo commit -b exampleos/x86_64/standard --link-checkout-speedup exampleos-build

# 5. Export to archive repo and generate static deltas
ostree --repo=repo pull-local build-repo exampleos/x86_64/standard
ostree --repo=repo static-delta generate exampleos/x86_64/standard
```

### Why rofiles-fuse?

`--link-checkout-speedup` tells OSTree the checkout is hardlinked so it can skip re-checksumming.
`rofiles-fuse` ensures any modified files during post-processing (e.g. ldconfig) get new inodes
(new checksums), keeping the hardlink→checksum mapping accurate.

## Repository initialization

```bash
ostree --repo=repo init --mode=archive       # export repo
ostree --repo=build-repo init --mode=bare-user  # build repo
```

## Related pages

- [OSTree Data Formats](ostree-formats.md) — archive/bare/static delta format details
- [Anatomy of an OSTree Repository](ostree-repo.md) — object store structure
- [OSTree Atomic Upgrades](ostree-atomic-upgrades.md) — client upgrade pipeline
- [OSTree](../entities/ostree.md) — OSTree entity page
