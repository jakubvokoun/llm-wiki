---
title: "UDS Core — Configuration & Packaging Overview"
tags: [uds-core, zarf, packaging, delivery, operator, configuration]
sources: [uds-core-configuration-packaging-overview.md]
updated: 2026-05-07
---

# UDS Core — Configuration & Packaging Overview

Two separate concerns when working with UDS: **delivery** (Zarf) and **platform integration** (UDS Operator). Knowing the distinction helps locate where to change behavior.

| Concern | Tool | Artifact | Solves |
| --- | --- | --- | --- |
| **Delivery** | Zarf | Zarf package (OCI artifact) | Getting software into disconnected environments |
| **Integration** | UDS Operator | Custom resources (K8s objects) | Declaring what applications need from the platform |

In practice, an application's Zarf package typically includes a `Package` CR in one of its Helm charts. When deployed, the CR lands in the cluster and the UDS Operator reconciles it, generating networking, SSO, and monitoring resources automatically. The two systems work together but are independent concerns.

## Sub-topics

**[Bundles](../entities/zarf.md)** — How Zarf packages are grouped into a single deployable artifact using the UDS CLI, including bundle structure, overrides, and deploy-time variables.

**[Core CRDs](uds-core-crd-overviews.md)** — The three custom resources (Package, Exemption, ClusterConfig) that declare platform intent at runtime. The operator reconciles them into Kubernetes, Istio, and Keycloak resources.

**[UDS Package Requirements](uds-core-package-requirements.md)** — Standards a UDS Package must meet to be secure, maintainable, and compatible with UDS Core.

## Related pages

- [UDS Operator](../concepts/uds-operator.md)
- [UDS Package CR](../concepts/uds-package-cr.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [Zarf](../entities/zarf.md)
