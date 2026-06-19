---
title: "Zarf Tutorial 6 — Publish & Deploy Packages with OCI"
tags: [zarf, oci, registry, airgap, kubernetes]
sources: [zarf-publish-and-deploy.md]
updated: 2026-04-23
---

# Zarf Tutorial 6 — Publish & Deploy Packages with OCI

Source: [docs.zarf.dev](https://docs.zarf.dev/tutorials/6-publish-and-deploy/)

## Summary

Extends the local package workflow to OCI-compliant registries: publish once, pull and deploy anywhere without manual file transfers.

## Core commands

| Command                                       | Purpose                            |
| --------------------------------------------- | ---------------------------------- |
| `zarf package publish <pkg> oci://<registry>` | Upload built package to registry   |
| `zarf package inspect oci://<registry>/<pkg>` | Examine remote package metadata    |
| `zarf package deploy oci://<registry>/<pkg>`  | Deploy directly from registry      |
| `zarf package pull oci://<registry>/<pkg>`    | Download package locally for reuse |

## Requirements

- `metadata.version` must be set in `zarf.yaml` before publishing
- Registry must be OCI Distribution Spec-compatible (Docker Hub, GHCR, Harbor, etc.)
- HTTP-only registries require `--plain-http` flag

## Workflow

1. Build package locally: `zarf package create .`
2. Publish to registry: `zarf package publish <pkg>.tar.zst oci://<registry>`
3. Remote artifact name is derived from package metadata (e.g., `helm-oci-chart:0.0.1-arm64`)
4. Deploy or pull using the `oci://` URI — identical flags to local deployment

## Common issues

- Missing `metadata.version` → publishing fails
- HTTP registry → add `--plain-http`
- `zarf-state` secret error → cluster not initialized (`zarf init` required)
- Cluster unreachable → verify kubeconfig

## Related

- [Zarf Packages](../concepts/zarf-packages.md)
- [Zarf](../entities/zarf.md)
- [Tutorial 3 — Deploy a Retro Arcade](zarf-retro-arcade.md) (OCI deploy via `oci://`)
