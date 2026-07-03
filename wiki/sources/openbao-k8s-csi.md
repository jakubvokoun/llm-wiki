---
title: "OpenBao — CSI Provider"
tags: [openbao, kubernetes, csi, secrets-store, deployment]
sources: [openbao-k8s-csi.md]
updated: 2026-07-03
---

# OpenBao — CSI Provider

Mounting [OpenBao](../entities/openbao.md) secrets into pods via [CSI Secrets Store](https://github.com/kubernetes-sigs/secrets-store-csi-driver) volumes. See the [k8s overview](openbao-k8s.md).

## Key Takeaways

- Requires the **CSI Secrets Store Driver** installed. Users define a `SecretProviderClass` (namespaced) with `provider: openbao`; the driver routes requests to the OpenBao CSI Provider, which uses the **pod's service account** to fetch secrets and mount them into the pod's CSI volume.
- Secrets are written during **ContainerCreation** — pods are **blocked from starting** until secrets are read. Written to ephemeral in-memory volumes.
- **Features:** all secret engines supported, service-account auth ([Kubernetes](https://openbao.org/docs/auth/kubernetes/) & [JWT](https://openbao.org/docs/auth/jwt/) auth methods), TLS/mTLS, render secrets to files, dynamic lease caching/renewal (via Agent), sync to Kubernetes Secrets for use as env vars, install via [Helm](openbao-k8s-helm.md).
- Supported Kubernetes **1.30–1.33**. Best practice: dedicated service accounts per pod so apps can't over-read. The pod's SA must be bound to an OpenBao role + [policy](../concepts/openbao-policies.md).
- `SecretProviderClass` `objects` map `objectName` (filename/alias) → `secretPath` + `secretKey`; `provider: openbao` needs Helm chart ≥ 0.18.0 (CSI Provider ≥ 2.0.0).

## Related

- [Kubernetes overview](openbao-k8s.md)
- [Helm chart](openbao-k8s-helm.md)
- [Policies](../concepts/openbao-policies.md)
- [Kubernetes](../entities/kubernetes.md)
