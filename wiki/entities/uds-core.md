---
title: "UDS Core"
tags:
  [
    product,
    kubernetes,
    defense-unicorns,
    platform,
    airgap,
    service-mesh,
    identity,
    monitoring,
  ]
sources:
  [
    uds-core-concepts-overview.md,
    uds-core-platform-security.md,
    uds-core-platform-functional-layers.md,
  ]
updated: 2026-05-07
---

# UDS Core

UDS Core is an opinionated Kubernetes platform baseline created by
[Defense Unicorns](defense-unicorns.md). It packages Istio, Keycloak, Prometheus,
Grafana, Vector, Loki, Falco, Velero, and more into a single deployable
[Zarf](zarf.md) package.

## Purpose

Answers the question _"what secure platform layer does a team need before deploying
an application on Kubernetes?"_ — especially for regulated, air-gapped, or
DoD/FedRAMP environments. UDS Core provides:

- Zero-trust networking via Istio (mTLS, deny-all by default, explicit egress)
- Centralized SSO via Keycloak + Authservice
- Metrics/alerting via Prometheus + Grafana + Alertmanager
- Log aggregation via Vector + Loki
- Runtime security via Falco + Falcosidekick
- Backup/restore via Velero
- Admission control via [Pepr](pepr.md) policy engine

## Key components

| Layer                         | Technology                                           |
| ----------------------------- | ---------------------------------------------------- |
| `core-base` (required)        | Istio, UDS Operator, Pepr                            |
| `core-identity-authorization` | Keycloak, Authservice                                |
| `core-metrics-server`         | Kubernetes Metrics Server                            |
| `core-runtime-security`       | Falco, Falcosidekick                                 |
| `core-logging`                | Vector, Loki                                         |
| `core-monitoring`             | Prometheus, Grafana, Alertmanager, Blackbox Exporter |
| `core-backup-restore`         | Velero                                               |

## UDS Operator

The control plane for UDS Core. Watches `Package`, `Exemption`, and `ClusterConfig`
custom resources. When a `Package` CR is created/updated, the operator generates
Istio routing, NetworkPolicies, Keycloak clients, and Prometheus monitoring resources
automatically. See [UDS Operator concept](../concepts/uds-operator.md).

## Versioning

Versions follow `<upstream-app-version>-uds.<uds-sub-version>`, e.g., `0.1.0-uds.0`.

## Related pages

- [UDS Core concepts overview](../sources/uds-core-concepts-overview.md)
- [UDS Package CR](../concepts/uds-package-cr.md)
- [Pepr](pepr.md)
- [Defense Unicorns](defense-unicorns.md)
