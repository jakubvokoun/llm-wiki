---
title: "Zarf Tutorial 1 — Initializing a K8s Cluster"
tags: [zarf, kubernetes, init, airgap]
sources: [zarf-initializing-k8s-cluster.md]
updated: 2026-04-23
---

# Zarf Tutorial 1 — Initializing a K8s Cluster

Official Zarf tutorial covering `zarf init`: bootstrapping Zarf infrastructure onto an existing Kubernetes cluster using the init-package.

## Key Takeaways

- `zarf init` deploys the init-package, which installs Zarf's internal registry (and optionally k3s, a git server, etc.) into the cluster
- Prompts whether to deploy optional components (e.g. k3s on Linux)
- Validate with `zarf tools monitor` (launches k9s) — look for Zarf pods in the `zarf` namespace
- `zarf destroy --confirm` removes all Zarf resources cleanly

## Commands

```bash
zarf init                 # interactive — prompts for component selection
zarf tools monitor        # k9s UI (press 0 for all namespaces)
zarf destroy --confirm    # full cleanup
```

## Prerequisites

- Zarf binary on `$PATH`
- An existing Kubernetes cluster (kubeconfig configured)
- An init-package (built or downloaded from GitHub releases)

## See Also

- [Zarf](../entities/zarf.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [Zarf Tutorial 0 — Creating a Zarf Package](zarf-creating-package.md)
