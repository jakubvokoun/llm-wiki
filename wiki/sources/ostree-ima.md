---
title: "Using Linux IMA with OSTree"
tags: [ostree, ima, evm, integrity, signing, linux-security]
sources: [ostree-ima.md]
updated: 2026-04-17
---

# Using Linux IMA with OSTree

Source: `raw/ostree-ima.md` — OSTree documentation on integrating Linux IMA (Integrity
Measurement Architecture) for per-file cryptographic signing.

## Key Takeaways

1. **IMA signs per-file digests** stored in the `security.ima` xattr; policies can require
   root-executed code to have a valid signed digest.
2. **New object per signed file** — because xattrs are part of the OSTree checksum, adding
   `security.ima` creates new objects in the repo. This enables transactional add/removal of
   IMA signatures but **duplicates disk space** when signing previously unsigned files.
3. **Signing tool** — `ostree-ext-cli ima-sign` from
   [ostree-rs-ext](https://github.com/ostreedev/ostree-rs-ext/); requires repo, ref, digest
   algorithm, and an RSA private key.
4. **IMA does not prevent mutation** — it only blocks reading/executing of changed or unsigned
   files (depending on policy). Files are not made physically read-only.
5. **EVM caveat** — EVM builds on IMA and covers metadata (uid/gid/mode + security xattrs) but
   default EVM signatures include machine-specific inode numbers, which would corrupt OSTree
   objects on a different machine. Portable EVM signatures are a future possibility.
6. **vs composefs** — composefs provides stronger integrity: validates entire filesystem trees,
   makes files actually read-only, uses on-demand fs-verity rather than full readahead.

## Signing Workflow

```bash
# Sign all regular files in a commit
ostree-ext-cli ima-sign \
  --repo=repo \
  exampleos/x86_64/stable \
  sha256 \
  /path/to/key.pem
```

Signing by itself has no effect until an IMA policy is loaded that enforces signature
requirements. Include the IMA policy in the OS build.

## IMA vs OSTree Checksum Internals

| Property                | IMA `security.ima`          | OSTree checksum                 |
| ----------------------- | --------------------------- | ------------------------------- |
| Covers                  | File content only           | Content + uid/gid/mode + xattrs |
| Storage location        | `security.ima` xattr        | SHA256 in object store          |
| Effect on OSTree digest | Changes digest (new object) | Is the digest                   |

## EVM Compatibility

- **Machine-specific EVM** (default) — includes inode number → breaks OSTree portability
- **Portable EVM** — strips inode; in-progress; may be supported by future ostree
- Using machine-specific EVM keys today will make OSTree treat objects as corrupt

## Related

- [Using composefs with OSTree](ostree-composefs.md) — stronger tree-level integrity (experimental)
- [OSTree Authenticated Remote Repositories](ostree-authenticated-repos.md) — commit-level signing
- [OSTree (entity)](../entities/ostree.md)
