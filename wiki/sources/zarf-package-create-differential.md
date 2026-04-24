---
title: "Zarf Tutorial 9 — Create Differential Packages"
tags: [zarf, airgap, packaging, delta, optimization]
sources: [zarf-package-create-differential.md]
updated: 2026-04-23
---

# Zarf Tutorial 9 — Create Differential Packages

Source: [docs.zarf.dev](https://docs.zarf.dev/tutorials/9-package-create-differential/)

## Summary

Differential packages bundle only what changed between two versions of a Zarf package — omitting
images, git repos, and OCI skeleton components already present in the reference package. Useful
for bandwidth-constrained or air-gapped update pipelines.

## Command

```bash
zarf package create . --differential <reference-package>.tar.zst
```

The resulting tarball is smaller because resources pinned to the same version/shasum in the
reference package are excluded.

## Requirements

- `metadata.version` in `zarf.yaml` **must be updated** before building a differential package
  (same-version differential builds fail with an error)
- No running cluster needed — differential creation is build-time only

## Workflow

1. Build initial package (v1.0.0): `zarf package create .`
2. Update `zarf.yaml`: bump image tags + `metadata.version`
3. Build differential: `zarf package create . --differential zarf-pkg-v1.0.0.tar.zst`
4. Deploy differential package as normal — Zarf merges it with the already-deployed base

## What gets omitted

Resources pinned to the same version/shasum in the reference package:

- Container images
- Git repositories
- OCI skeleton components

## Related

- [Zarf](../entities/zarf.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [Tutorial 0 — Creating a Package](zarf-creating-package.md)
