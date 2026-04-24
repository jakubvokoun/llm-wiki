---
title: "Grafana"
tags: [org/product, observability, monitoring, dashboards, alerting]
sources: [grafana-alerting-best-practices.md]
updated: 2026-04-24
---

# Grafana

Open-source visualization and observability platform by Grafana Labs. Provides dashboards, alerting, and data exploration across many data sources.

## Core Products

- **Grafana** — dashboard and alerting platform; connects to Prometheus, Loki, Tempo, and 100+ datasources
- **Grafana Alerting** — unified alerting engine; rule-based alerts, contact points, notification policies, silences
- **Grafana Loki** — log aggregation system (like ELK but label-based, lower cost)
- **Grafana Tempo** — distributed tracing backend
- **Grafana Mimir** — horizontally scalable Prometheus-compatible metrics backend
- **Grafana OnCall** — on-call management and escalation (formerly Amixr)

## Alerting Model

Grafana Alerting unifies Grafana-managed alerts and datasource-managed alerts (Prometheus Alertmanager) in one UI. Contact points and notification policies control routing.

## Related Pages

- [Grafana Alerting Best Practices](../sources/grafana-alerting-best-practices.md)
- [Alert Severity Levels](../concepts/alert-severity.md)
- [Observability](../concepts/observability.md)
- [Prometheus](../entities/prometheus.md)
- [Distributed Tracing](../concepts/distributed-tracing.md)
