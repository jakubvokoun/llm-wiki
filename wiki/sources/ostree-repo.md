---
title: "Anatomy of an OSTree Repository"
tags: [ostree, atomic, linux, internals, repository]
sources: [ostree-repo.md]
updated: 2026-04-17
---

# Anatomy of an OSTree Repository

Deep-dive into OSTree's object model and repository internals.

## Key Takeaways

1. **SHA256 content-addressed object store**, like git but with key differences: splits git's
   "tree" into separate `dirtree` (filenames + checksums) and `dirmeta` (permissions +
   xattrs) objects. Content objects include uid/gid/xattrs but **no timestamps**.
2. **No timestamps by design.** Files downloaded at different times would hash differently if
   timestamps were included. OSTree sets all timestamps to `0` so identical content always
   deduplicates.
3. **Five repository modes** for different use cases (see below).
4. **Refs** are text files naming commits. Convention:
   `exampleos/buildmain/x86_64-runtime`. Parent syntax: `ref^` (one back), `ref^^` (two).
5. **Summary file** (`ostree summary -u`) maps refs→checksums and lists static deltas.
   Can be GPG-signed. Required for Metalink compatibility and client branch enumeration.

## Object Types

| Object    | Description                                                         |
| --------- | ------------------------------------------------------------------- |
| `commit`  | Timestamp, log message, reference to root dirtree/dirmeta pair      |
| `dirtree` | Sorted arrays: (filename→content checksum) + (dirname→dirtree+meta) |
| `dirmeta` | Permissions/xattrs for a directory node (deduped separately)        |
| `content` | uid, gid, mode, symlink target, xattrs, then file payload           |
| `xattrs`  | (bare-split-xattrs mode) xattrs stored as separate GVariant objects |

## Repository Modes

| Mode                | Who runs it | Notes                                              |
| ------------------- | ----------- | -------------------------------------------------- |
| `bare`              | root        | Files stored as-is; source of hardlink farm        |
| `bare-split-xattrs` | root        | Like bare but xattrs in separate objects (SELinux) |
| `bare-user`         | non-root    | Owner metadata in `user.ostreemeta` xattr          |
| `bare-user-only`    | non-root    | No owner/xattr storage; works on tmpfs             |
| `archive`           | any         | gzip-compressed; served via plain HTTP             |

System repository: `/ostree/repo` (readable by all; writable only by root).

## Related

- [OSTree entity](../entities/ostree.md)
- [OSTree Introduction](../sources/ostree-introduction.md)
- [Atomic Linux](../concepts/atomic-linux.md)
