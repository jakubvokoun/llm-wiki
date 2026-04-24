---
title: "Zarf Tutorial 7 — Creating a Custom Init Package"
tags: [zarf, airgap, kubernetes, init-package, supply-chain]
sources: [zarf-custom-init-packages.md]
updated: 2026-04-23
---

# Zarf Tutorial 7 — Creating a Custom Init Package

Source: [docs.zarf.dev](https://docs.zarf.dev/tutorials/7-custom-init-packages/)

## Summary

The default Zarf init package covers most cases, but custom builds allow swapping images for
hardened/enterprise-vetted versions or removing unused components.

## Building the init package

Build from the Zarf git repository (requires internet access):

```bash
git checkout vX.X.X                               # match your zarf binary version
zarf package create . --set AGENT_IMAGE_TAG=vX.X.X
# → zarf-init-amd64-vX.X.X.tar.zst
```

## Swapping images (enterprise mirrors)

Use `--registry-override` or `zarf-config.toml` to pull from enterprise pull-through mirrors:

```bash
zarf package create . --set AGENT_IMAGE_TAG=vX.X.X \
  --registry-override docker.io=dockerio.enterprise.corp \
  --registry-override ghcr.io=ghcr.enterprise.corp \
  --registry-override quay.io=quay.enterprise.corp
```

Or as `zarf-config.toml`:

```toml
[package.create]
registry_override = [
  "docker.io=dockerio.enterprise.corp",
  "ghcr.io=ghcr.enterprise.corp",
  "quay.io=quay.enterprise.corp"
]
```

Fine-grained image overrides via `--set`:

| Flag                    | Purpose                        |
| ----------------------- | ------------------------------ |
| `AGENT_IMAGE_TAG`       | Zarf agent image tag           |
| `AGENT_IMAGE`           | Zarf agent image name          |
| `AGENT_IMAGE_DOMAIN`    | Zarf agent registry domain     |
| `REGISTRY_IMAGE_TAG`    | Internal registry image tag    |
| `REGISTRY_IMAGE`        | Internal registry image name   |
| `REGISTRY_IMAGE_DOMAIN` | Internal registry domain       |
| `GITEA_IMAGE`           | Gitea image (must be rootless) |

Source: [Iron Bank hardened images](https://repo1.dso.mil/dsop/opensource/defenseunicorns/zarf/zarf-agent)

## Removing components

The init package is a composed package — each component imports a sub-package from `packages/`.
Remove an import entry from the root `zarf.yaml` to slim the package.

## Related

- [Zarf](../entities/zarf.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [Tutorial 1 — Initializing a Cluster](zarf-initializing-k8s-cluster.md)
