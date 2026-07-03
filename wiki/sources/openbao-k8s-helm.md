---
title: "OpenBao — Helm Chart (overview)"
tags: [openbao, kubernetes, helm, deployment]
sources: [openbao-k8s-helm.md]
updated: 2026-07-03
---

# OpenBao — Helm Chart (overview)

The official [openbao/openbao-helm](https://github.com/openbao/openbao-helm) chart — recommended way to install [OpenBao](../entities/openbao.md) on [Kubernetes](../entities/kubernetes.md).

## Key Takeaways

- Requires **Helm 3.6+** (not Helm 2). Also the primary way to install the Agent Injector.
- Supported Kubernetes versions: **1.30–1.33**.
- Install: `helm repo add openbao https://openbao.github.io/openbao-helm`, then `helm install openbao openbao/openbao` (add `--version X.Y.Z` to pin). The chart is under heavy development — **always `--dry-run` first**.
- **Security warning:** the default **standalone** mode (single server, file storage) is not production-appropriate. For production, secure the cluster, review [config options](openbao-k8s-helm-configuration.md), and follow the [production checklist](openbao-k8s-helm-run.md).

## Related

- [Run on Kubernetes](openbao-k8s-helm-run.md)
- [Helm configuration](openbao-k8s-helm-configuration.md)
- [OpenTofu deployment](openbao-k8s-helm-terraform.md)
- [Examples](openbao-k8s-helm-examples.md)
- [OpenBao](../entities/openbao.md)
