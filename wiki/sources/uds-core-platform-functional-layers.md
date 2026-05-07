---
title: "UDS Core — Platform Functional Layers"
tags: [uds-core, zarf, layers, airgap, modular-deployment, edge]
sources: [uds-core-platform-functional-layers.md]
updated: 2026-05-07
---

# UDS Core — Platform Functional Layers

UDS Core is published as a single `core` package, but also as individual **functional
layers** — smaller Zarf packages grouped by capability. Layers let you deploy only the
features your environment needs (resource-constrained clusters, edge deployments, or
clusters that already provide some capabilities).

Default to the full `core` package. Individual layers are the exception; removing layers
may affect security and compliance posture.

## Available layers

| Layer                         | What it provides                                        | Dependencies                       |
| ----------------------------- | ------------------------------------------------------- | ---------------------------------- |
| `core-crds`                   | Standalone UDS CRDs (Package, Exemption, ClusterConfig) | None                               |
| `core-base`                   | Istio, UDS Operator, Pepr Policy Engine                 | None (foundation)                  |
| `core-identity-authorization` | Keycloak + Authservice (SSO)                            | Base                               |
| `core-metrics-server`         | Kubernetes Metrics Server                               | Base                               |
| `core-runtime-security`       | Falco + Falcosidekick                                   | Base                               |
| `core-logging`                | Vector + Loki                                           | Base; optionally Monitoring for UI |
| `core-monitoring`             | Prometheus + Grafana + Alertmanager + Blackbox          | Base + Identity & Authorization    |
| `core-backup-restore`         | Velero                                                  | Base                               |
| `core` (standard)             | All of the above combined                               | None (self-contained)              |

## Layer selection criteria

| Layer                    | When to include                                                |
| ------------------------ | -------------------------------------------------------------- |
| CRDs                     | Pre-existing components need UDS exemptions before base starts |
| Base                     | Required for all UDS deployments                               |
| Identity & Authorization | Deployment requires user authentication / SSO                  |
| Metrics Server           | Cluster does not already provide one (skip on EKS/AKS/GKE)     |
| Runtime Security         | Runtime threat detection via Falco needed                      |
| Logging                  | Centralized log aggregation needed                             |
| Monitoring               | Metrics dashboards, alerting, uptime monitoring needed         |
| Backup & Restore         | Critical data must survive cluster failures                    |

**Note:** The Monitoring layer requires the Identity & Authorization layer (Grafana login).
Do not deploy `core-metrics-server` if the cluster already has a metrics server.

## Dependency ordering

**Layer 0** (no deps): `core-crds` (optional; only if pre-core components need exemptions)

**Layer 1** (foundation): `core-base` (required before everything else)

**Layer 2** (depend on Base only): `core-identity-authorization`, `core-metrics-server`,
`core-runtime-security`, `core-logging`, `core-backup-restore`

**Layer 3** (depend on Base + Identity & Authorization): `core-monitoring`

## Pre-core infrastructure

On-prem and edge environments often need load balancer controllers (MetalLB) or storage
operators (MinIO Operator) deployed before UDS Core. Deploy `core-crds` first so
`Exemption` CRs can be created alongside those packages before Pepr becomes active.

## UDS add-ons

| Add-On           | What it provides                                              |
| ---------------- | ------------------------------------------------------------- |
| UDS UI           | Common operating picture for K8s clusters and UDS deployments |
| UDS Registry     | Artifact storage for UDS components and mission applications  |
| UDS Remote Agent | Remote cluster management and deployment beyond UDS CLI       |

## Related pages

- [UDS Core](../entities/uds-core.md)
- [Zarf](../entities/zarf.md)
- [UDS Core concepts overview](uds-core-concepts-overview.md)
