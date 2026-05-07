---
title: "UDS Core — CRD Overviews"
tags: [uds-core, crd, package-cr, exemption-cr, clusterconfig, kubernetes]
sources: [uds-core-crd-overviews.md]
updated: 2026-05-07
---

# UDS Core — CRD Overviews

UDS Core provides three custom resource definitions (CRDs). Think of them as forms you fill out to tell the platform what you need; the operator reads them and does the work behind the scenes.

## Package CR

A `Package` CR is a **request form** for the platform. Instead of manually configuring Istio routes, NetworkPolicies, and Keycloak clients, an application team fills out one declaration and the operator provisions everything.

A Package can declare:

- **Networking** — which services to expose externally and what outbound traffic to allow
- **SSO** — Keycloak client registration and authentication flows
- **Monitoring** — metrics endpoints for Prometheus to scrape
- **Service mesh mode** — ambient or sidecar mode

**Constraint:** Only one `Package` CR can exist per namespace. This enforces workload isolation and simplifies policy generation.

See [UDS Package CR concept](../concepts/uds-package-cr.md) for full details.

## Exemption CR

An `Exemption` CR is a **permission slip**. It names exactly which policies to bypass and targets specific workloads by namespace and name. It also supports title and description fields so the reason is documented next to the exemption itself.

Exemptions are restricted to the `uds-policy-exemptions` namespace by default. Centralizing them makes them easier to audit and control with RBAC. This can be relaxed via `ClusterConfig` if needed.

When a resource is exempted, it is annotated as: `uds-core.pepr.dev/uds-core-policies.<POLICY>: exempted`

## ClusterConfig CR

`ClusterConfig` holds **shared global information** about the cluster deployment:

- **Domains** — tenant and admin domains for ingress gateways
- **CA certificates** — custom trust bundles propagated to platform components
- **Networking CIDRs** — Kubernetes API and node ranges for policy generation
- **Policy settings** — e.g., whether exemptions can exist outside the default namespace
- **Cluster identity** — name and tags for identification and reporting

Unlike `Package` and `Exemption`, application teams do not touch `ClusterConfig`. Platform operators manage it. `ClusterConfig` is a singleton — exactly one per cluster.

## Related pages

- [UDS Operator](../concepts/uds-operator.md)
- [UDS Package CR](../concepts/uds-package-cr.md)
- [Pepr](../entities/pepr.md)
- [UDS Core — Policy & Compliance](uds-core-policy-compliance.md)
