---
title: "Istio"
tags: [product, service-mesh, mtls, kubernetes, cncf, zero-trust, networking]
sources: [uds-core-networking.md, uds-core-concepts-overview.md]
updated: 2026-05-07
---

# Istio

Istio is an open-source service mesh for Kubernetes, maintained by Google, IBM, and Lyft and graduated in the CNCF. It provides mutual TLS, traffic management, and observability as a transparent infrastructure layer — applications do not need to implement TLS or network policies themselves.

## Key capabilities

- **mTLS** — automatic mutual TLS for all in-cluster traffic; workload identity via SPIFFE certificates derived from Kubernetes service accounts
- **Authorization policies** — fine-grained L7 rules on which workloads can communicate with which other workloads; defaults to deny-all
- **Ingress/egress gateways** — consistent point for TLS termination, traffic inspection, and access control for external traffic
- **Traffic management** — VirtualServices, DestinationRules for load balancing, retries, circuit breaking, and canary deployments

## Data plane modes

| Mode                              | Proxy location                          | Overhead                |
| --------------------------------- | --------------------------------------- | ----------------------- |
| **Ambient** (default in UDS Core) | Node-level ztunnel + optional waypoints | Lower (shared per node) |
| **Sidecar**                       | Per-pod Envoy sidecar                   | Higher (per pod)        |

Ambient mode is Istio's long-term investment direction — no pod restarts needed for upgrades, lower resource footprint.

## Role in UDS Core

Istio is the core networking layer in [UDS Core](uds-core.md). The [UDS Operator](../concepts/uds-operator.md) generates Istio `VirtualService` and `AuthorizationPolicy` resources automatically from `Package` CR declarations. Application teams never write Istio YAML directly.

## Related pages

- [Service Mesh](../concepts/service-mesh.md)
- [Zero Trust Architecture](../concepts/zero-trust.md)
- [UDS Core — Networking](../sources/uds-core-networking.md)
- [mTLS](../concepts/tls.md)
