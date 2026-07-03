---
title: "OpenBao — Kubernetes (overview)"
tags: [openbao, kubernetes, deployment, agent-injector, csi]
sources: [openbao-k8s.md]
updated: 2026-07-03
---

# OpenBao — Kubernetes (overview)

Deploying [OpenBao](../entities/openbao.md) on [Kubernetes](../entities/kubernetes.md) via the official Helm chart.

## Key Takeaways

- The [Helm chart](openbao-k8s-helm.md) deploys OpenBao in four modes: **dev** (in-memory), **standalone** (default; single server, file storage), **HA** (cluster on an HA backend), and **external** (only the Agent Injector, pointing at an external OpenBao).
- **Use cases:** run an OpenBao service in-cluster, store/access secrets via secret engines + auth methods, run [HA](../concepts/openbao-high-availability.md) with pod affinity + HA storage + [auto-unseal](../concepts/openbao-seal-unseal.md), encryption-as-a-service (Transit), and persistent-volume audit logs.
- **Two integrations to deliver secrets to pods** (no app changes needed):
  - **Agent Injector** — sidecar; secrets only in ephemeral in-memory volumes; fetched with the pod's own service account (no privileged impersonation); more mature (templating, many auth methods).
  - **[CSI provider](openbao-k8s-csi.md)** — based on the vendor-neutral CSI Secrets Store driver; also in-memory unless the secret-sync feature is used.

## Related

- [Helm chart](openbao-k8s-helm.md)
- [Run on Kubernetes](openbao-k8s-helm-run.md)
- [CSI provider](openbao-k8s-csi.md)
- [K8s service registration](openbao-config-service-registration-kubernetes.md)
- [Kubernetes](../entities/kubernetes.md)
