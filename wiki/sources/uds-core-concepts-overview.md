---
title: "UDS Core — Concepts Overview"
tags: [uds-core, kubernetes, defense-unicorns, operator, policy-engine, airgap]
sources: [uds-core-concepts-overview.md]
updated: 2026-05-07
---

# UDS Core — Concepts Overview

UDS Core is a curated collection of Kubernetes platform capabilities packaged as a
single deployable [Zarf](../entities/zarf.md) package. It provides a secure, compliant
baseline for cloud-native systems operating in regulated or air-gapped environments.
It is the answer to the question: _what platform layer does a team need before deploying
an application on Kubernetes?_

## Functional layers

UDS Core is organized into discrete Zarf packages grouped by capability. Only `core-base`
is required; all others are optional.

| Layer                         | What it provides                                                                                                            |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `core-crds`                   | Standalone UDS CRDs (Package, Exemption, ClusterConfig); deploy before base when pre-core components need policy exemptions |
| `core-base`                   | **Required.** Istio service mesh, UDS Operator, Pepr Policy Engine                                                          |
| `core-identity-authorization` | Keycloak + Authservice (SSO)                                                                                                |
| `core-metrics-server`         | Kubernetes Metrics Server                                                                                                   |
| `core-runtime-security`       | Falco + Falcosidekick                                                                                                       |
| `core-logging`                | Vector + Loki                                                                                                               |
| `core-monitoring`             | Prometheus + Grafana + Alertmanager + Blackbox Exporter                                                                     |
| `core-backup-restore`         | Velero                                                                                                                      |

## The UDS Operator

The UDS Operator is the control plane for UDS Core. Application teams create a
[`Package` CR](../concepts/uds-package-cr.md) declaring networking intent, SSO requirements,
and monitoring needs. The operator reconciles the CR and creates all necessary platform
resources automatically:

- **Istio resources** — `VirtualService` and `AuthorizationPolicy` for traffic control
- **Kubernetes `NetworkPolicy`** — enforcing network boundaries per workload
- **Keycloak clients** — for SSO-protected services
- **Authservice SSO flow** — for apps that don't natively implement OIDC
- **`ServiceMonitor`, `PodMonitor`, blackbox probes** — for Prometheus scraping

This means platform teams do not write low-level Istio or Kubernetes networking
configuration per application, and do not manually configure SSO per app. The `Package`
CR drives all of it from a single declaration.

## The Policy Engine

The UDS Policy Engine, built on [Pepr](../entities/pepr.md), runs as Kubernetes admission
webhooks. It enforces a security baseline across all workloads:

- **Mutations** — automatically correcting safe defaults (e.g., set `allowPrivilegeEscalation: false`)
- **Validations** — blocking unsafe configurations (e.g., reject privileged containers)

When a workload legitimately needs an exemption, teams create an `Exemption` CR to
declare it explicitly, preserving the audit trail.

## Key relationships

- UDS Core depends on [Zarf](../entities/zarf.md) for packaging and delivery
- [Defense Unicorns](../entities/defense-unicorns.md) created and maintains UDS Core
- Core CRDs (`Package`, `Exemption`, `ClusterConfig`) are documented in
  [CRD Overviews](uds-core-crd-overviews.md)
- The full policy list is in [Policy Engine](uds-core-policy-engine.md)
