---
title: "UDS Package CR"
tags: [kubernetes, crd, uds-core, networking, sso, monitoring, service-mesh]
sources:
  [
    uds-core-concepts-overview.md,
    uds-core-crd-overviews.md,
    uds-core-package-requirements.md,
  ]
updated: 2026-05-07
---

# UDS Package CR

The UDS `Package` custom resource is a Kubernetes object that lets application teams declare what they need from the [UDS Core](../entities/uds-core.md) platform. The [UDS Operator](uds-operator.md) reads it and provisions all necessary platform resources automatically.

## Structure

A `Package` CR can declare:

- **`expose`** — external interfaces (routes Istio ingress + creates AuthorizationPolicies)
- **`allow`** — network egress/ingress rules (generates Kubernetes NetworkPolicies)
- **`sso`** — Keycloak client registration for SSO-protected services
- **`monitor`** — metrics endpoints for Prometheus scraping (ServiceMonitor/PodMonitor/Probe)
- **Service mesh mode** — ambient or sidecar Istio mode per workload

## Constraints

- Only **one** `Package` CR is allowed per namespace; this enforces workload isolation and simplifies policy generation.
- `Package` CRs are typically included in application Helm charts, so they land in the cluster alongside the application during deployment.

## Network policies follow least privilege

All `allow` entries must permit only strictly necessary traffic. The operator generates deny-all baseline NetworkPolicies and adds explicit allow rules only for what is declared in the CR.

## Related pages

- [UDS Operator](uds-operator.md)
- [UDS Core CRD Overviews](../sources/uds-core-crd-overviews.md)
- [UDS Package Requirements](../sources/uds-core-package-requirements.md)
- [Service Mesh](service-mesh.md)
- [Network Policy](network-policy.md)
