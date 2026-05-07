---
title: "UDS Core — Core Features Overview"
tags:
  [
    uds-core,
    networking,
    identity,
    logging,
    monitoring,
    runtime-security,
    policy,
  ]
sources: [uds-core-features-overview.md]
updated: 2026-05-07
---

# UDS Core — Core Features Overview

UDS Core's capabilities are organized into seven functional areas that together form an integrated security and observability stack.

| Feature area | Technology | What it addresses |
| --- | --- | --- |
| Networking & Service Mesh | Istio | mTLS, traffic management, ingress/egress control |
| Identity & Authorization | Keycloak + Authservice | SSO, OIDC, group-based authorization |
| Logging | Vector + Loki | Centralized log aggregation, durable storage, alerting |
| Monitoring & Observability | Prometheus + Grafana + Alertmanager | Metrics, dashboards, alerting |
| Runtime Security | Falco + Falcosidekick | Runtime threat detection inside running containers |
| Backup & Restore | Velero | Scheduled backup and recovery of K8s + PV data |
| Policy & Compliance | Pepr | Admission control, pod security enforcement |

## Detailed pages

- [Networking & Service Mesh](uds-core-networking.md)
- [Identity & Authorization](uds-core-identity-authorization.md)
- [Logging](uds-core-logging.md)
- [Monitoring & Observability](uds-core-monitoring-observability.md)
- [Runtime Security](uds-core-runtime-security.md)
- [Policy & Compliance](uds-core-policy-compliance.md)
- [Policy Engine reference](uds-core-policy-engine.md)
