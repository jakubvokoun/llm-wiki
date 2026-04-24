---
title: "Zarf Tutorial 4 — Creating a K8s Cluster with Zarf"
tags: [zarf, kubernetes, k3s, init]
sources: [zarf-creating-k8s-cluster.md]
updated: 2026-04-23
---

# Zarf Tutorial 4 — Creating a K8s Cluster with Zarf

Official Zarf tutorial showing how to use Zarf's built-in k3s component to bootstrap a Kubernetes cluster on a bare Linux machine — no pre-existing cluster needed.

## Key Takeaways

- The init-package includes an optional `k3s` component that installs k3s directly on the host
- Requires **true root** (not just `sudo`) because k3s modifies the host system
- After init, only root has cluster access by default; copy kubeconfig and adjust ownership for regular users
- `--components="k3s" --confirm` fully automates the process for scripting/CI

## Commands

```bash
# As root:
zarf init --components="k3s" --confirm

# Grant non-root user access:
cp /root/.kube/config /home/user/.kube/config
chown user:user /home/user/.kube/config

# Destroy cluster + Zarf:
zarf destroy --confirm
```

## Use Case

Ideal for edge/airgap scenarios where the target machine has no existing K8s cluster. Zarf ships k3s inside the init-package, making it possible to bootstrap a fully functional cluster with zero internet access.

## See Also

- [Zarf](../entities/zarf.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [Kubernetes](../entities/kubernetes.md)
- [Zarf Tutorial 1 — Initializing a K8s Cluster](zarf-initializing-k8s-cluster.md)
