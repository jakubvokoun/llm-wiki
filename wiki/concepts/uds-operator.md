---
title: "UDS Operator"
tags:
  [
    kubernetes,
    operator-pattern,
    uds-core,
    package-cr,
    automation,
    istio,
    keycloak,
  ]
sources: [uds-core-concepts-overview.md, uds-core-crd-overviews.md]
updated: 2026-05-07
---

# UDS Operator

The UDS Operator is the control plane for [UDS Core](../entities/uds-core.md). It
implements the Kubernetes operator pattern, watching custom resources and reconciling
them into low-level Kubernetes, Istio, and Keycloak resources.

## What it watches

- `Package` CR — per-namespace declaration of networking, SSO, and monitoring needs
- `Exemption` CR — policy bypass declarations for workloads that need them
- `ClusterConfig` CR — cluster-wide settings (domains, CIDRs, CA certs)

## What it generates from a Package CR

| Intent in Package CR | Resources generated                                            |
| -------------------- | -------------------------------------------------------------- |
| `expose` block       | Istio `VirtualService`, `AuthorizationPolicy`, ingress routing |
| `allow` block        | Kubernetes `NetworkPolicy` for egress/ingress                  |
| `sso` block          | Keycloak client registration + Authservice SSO flow            |
| `monitor` block      | `ServiceMonitor`, `PodMonitor`, or blackbox `Probe`            |

## Why it matters

Without the operator, platform teams would need to manually author Istio routing,
NetworkPolicies, Keycloak client configuration, and Prometheus scrape configs for
every application. The operator replaces all of this with a single
[`Package` CR](uds-package-cr.md) per namespace.

## Related pages

- [UDS Package CR](uds-package-cr.md)
- [UDS Core](../entities/uds-core.md)
- [UDS Core CRD Overviews](../sources/uds-core-crd-overviews.md)
