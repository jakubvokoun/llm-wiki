---
title: "OpenBao — Kubernetes Service Registration"
tags:
  [openbao, configuration, kubernetes, service-registration, high-availability]
sources: [openbao-config-service-registration-kubernetes.md]
updated: 2026-07-03
---

# OpenBao — Kubernetes Service Registration

Tagging [OpenBao](../entities/openbao.md) pods with HA status labels for use with Kubernetes selectors. Only available in [HA mode](../concepts/openbao-high-availability.md).

## Key Takeaways

- The `service_registration "kubernetes"` stanza lets OpenBao label its own pods so [Kubernetes](../entities/kubernetes.md) `Service` selectors can target nodes by role — e.g. always route to the active node.
- Config via `namespace` + `pod_name`, or the env vars `BAO_K8S_NAMESPACE` / `BAO_K8S_POD_NAME` (typically injected via the Downward API). An empty `service_registration "kubernetes" {}` block is still required to signal intent.
- **RBAC:** the pod service account needs a `Role` allowing `get`, `update`, `patch` on `pods` to apply labels.
- **Labels applied:** `openbao-active` (leader vs standby), `openbao-initialized`, `openbao-sealed`, `openbao-perf-standby`, `openbao-version`. Updated dynamically as status changes.
- Enables an **active-only Service** (`selector: openbao-active: "true"`, `publishNotReadyAddresses: false`) and label-driven rolling upgrades (`OnDelete` + `kubectl delete pod --selector=...`).

## Related

- [Kubernetes deployment](openbao-k8s.md)
- [High Availability](../concepts/openbao-high-availability.md)
- [Server config](openbao-config.md)
- [Kubernetes](../entities/kubernetes.md)
