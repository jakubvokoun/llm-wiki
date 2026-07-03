---
title: "OpenBao — Helm Configuration"
tags: [openbao, kubernetes, helm, configuration, values]
sources: [openbao-k8s-helm-configuration.md]
updated: 2026-07-03
---

# OpenBao — Helm Configuration

Customizing the [OpenBao Helm chart](openbao-k8s-helm.md) via values. Requires **Helm 3.6+**.

## Key Takeaways

- The chart is customized through [Helm configuration values](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing); each value has a getting-started default.
- **Before production**, review the full default [`values.yaml`](https://github.com/openbao/openbao-helm/blob/main/charts/openbao/values.yaml) and confirm each setting suits your deployment.
- Values can be set with OpenTofu/Terraform — see [Helm with OpenTofu](openbao-k8s-helm-terraform.md).

## Related

- [Helm chart](openbao-k8s-helm.md)
- [OpenTofu deployment](openbao-k8s-helm-terraform.md)
- [Examples](openbao-k8s-helm-examples.md)
- [Run on Kubernetes](openbao-k8s-helm-run.md)
