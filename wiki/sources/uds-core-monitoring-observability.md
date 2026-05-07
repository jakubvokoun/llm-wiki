---
title: "UDS Core — Monitoring & Observability"
tags:
  [
    uds-core,
    prometheus,
    grafana,
    alertmanager,
    blackbox-exporter,
    monitoring,
    observability,
  ]
sources: [uds-core-monitoring-observability.md]
updated: 2026-05-07
---

# UDS Core — Monitoring & Observability

UDS Core ships a complete metrics-based monitoring stack. From the moment it is
deployed, platform components are automatically instrumented — operators get
visibility into cluster health without additional configuration.

## Observability stack

| Component             | Role                                                                 |
| --------------------- | -------------------------------------------------------------------- |
| **Prometheus**        | Scrapes metrics endpoints, stores time-series, evaluates alert rules |
| **Grafana**           | Dashboards and log exploration; access gated by UDS Core groups      |
| **Alertmanager**      | Routes alerts with grouping, silencing, and deduplication            |
| **Blackbox Exporter** | Probes HTTPS endpoints for availability independent of pod health    |

## Uptime monitoring

Three built-in mechanisms:

1. **Prometheus recording rules** — track workload health (pod/deployment status)
2. **Blackbox Exporter probes** — verify HTTPS reachability from outside the service mesh
3. **Default probe alert rules** — notify when endpoints go down or TLS certificates approach expiry

These feed two built-in dashboards: **Core Uptime** and **Probe Uptime**.

## How application teams add metrics

Declare monitoring needs in the `Package` CR `monitor` block. The UDS Operator creates
`ServiceMonitor`, `PodMonitor`, or `Probe` resources automatically.

Application-specific alerting is expressed as `PrometheusRule` CRDs deployed alongside
the application, keeping alerting logic version-controlled with the application code.

## Alert routing principles

- Prometheus-based rules → `PrometheusRule` CRDs
- Loki-based rules → Loki Ruler ConfigMaps
- Grafana-managed alerts → reserved for multi-source correlation scenarios

Alerts should be evaluated at the source, not in Grafana. This keeps alerting
declarative and consistent across environments.

## Related pages

- [Prometheus](../entities/prometheus.md)
- [Grafana](../entities/grafana.md)
- [Observability](../concepts/observability.md)
- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [UDS Package CR](../concepts/uds-package-cr.md)
