---
title: "Zarf Best Practice — Upgrading Zarf"
tags: [zarf, airgap, kubernetes, upgrade, operations]
sources: [zarf-upgrading-zarf.md]
updated: 2026-04-23
---

# Zarf Best Practice — Upgrading Zarf

Keep the Zarf CLI binary and the in-cluster init package at the same version for reliable
operation.

## Upgrade the CLI Binary

Follow the [CLI installation guide](https://docs.zarf.dev/getting-started/install) for the target
platform.

## Upgrade the Init Package

### 1. Obtain the Updated Init Package

```bash
# Download matching init package to current directory
zarf tools download-init

# Or fetch a specific version manually
VERSION="vX.X.X"; ARCH="amd64"
curl -LO https://github.com/zarf-dev/zarf/releases/download/${VERSION}/zarf-init-${ARCH}-${VERSION}.tar.zst
```

### 2. Re-initialize the Cluster

```bash
# Standard re-init (reads existing config from zarf-state secret)
zarf init --confirm

# Or deploy explicitly (allows specifying a custom init package path)
zarf package deploy zarf-init-amd64-vX.X.X.tar.zst --confirm
```

> `zarf package deploy` for init upgrades does **not** expose `--registry-url` /
> `--git-url` options — use `zarf init` if you need those.

### 3. Validate

```bash
zarf tools kubectl get pods -n zarf
```

Confirm the registry, agent, and optional git server pods are healthy.

## Special Considerations

- The `zarf-state` secret in the `zarf` namespace persists configuration from the original
  `zarf init` (registry creds, git server URL, etc.). Flags like `--registry-pull-password`
  are **ignored** on subsequent `zarf init` runs.
- To update stored credentials after init: use `zarf tools update-creds`.

## See Also

- [Zarf](../entities/zarf.md)
- [Tutorial 1 — Initializing a Cluster](zarf-initializing-k8s-cluster.md)
- [Tutorial 7 — Custom Init Packages](zarf-custom-init-packages.md)
