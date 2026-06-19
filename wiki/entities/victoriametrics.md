---
title: "VictoriaMetrics"
tags: [monitoring, metrics, time-series, prometheus, alerting, observability]
sources: [victoriametrics-alerting-best-practices.md]
updated: 2026-04-24
---

# VictoriaMetrics

Open-source, high-performance time series database and monitoring solution. Designed as a drop-in Prometheus replacement with better scalability and lower resource usage.

## Core components

| Component | Purpose |
| --- | --- |
| **VictoriaMetrics** | Time series storage and query engine; compatible with PromQL (MetricsQL superset) |
| **vmalert** | Alerting and recording rules evaluation engine; replaces Prometheus alerting |
| **vmagent** | Metrics collection agent; replaces Prometheus scraping |
| **Alertmanager** | Alert routing, grouping, deduplication, inhibition (reuses Prometheus Alertmanager) |

## Key differentiators from Prometheus

- MetricsQL extends PromQL with additional functions (e.g. `query()` in annotations)
- vmalert executes instant queries for rules; default lookback window controlled by `-datasource.queryStep`
- `keep_firing_for` parameter extends alert active state beyond expr resolution (not in native Prometheus)
- ALERTS and ALERTS_FOR_STATE metrics for alert history tracking and dashboard analysis
- vmalert-tool for unit testing alerting rules
- Replay (backfilling): run rules against historical production data

## vmalert alert rule fields

| Field | Purpose |
| --- | --- |
| `expr` | MetricsQL expression defining the problematic state |
| `for` | Minimum sustained duration before firing; prevents flapping |
| `keep_firing_for` | Minimum firing duration after expr clears; prevents premature resolution |
| `labels` | Static metadata for routing and enrichment; avoid dynamic values |
| `annotations` | Human-readable context; supports `query()` function and `$externalURL` variable |

## Related pages

- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Alerting Best Practices Source](../sources/victoriametrics-alerting-best-practices.md)
- [Alert Severity Levels](../concepts/alert-severity.md)
- [Prometheus](../entities/prometheus.md)
- [VictoriaMetrics: Alerting, Recording Rules & Alertmanager (source)](../sources/victoriametrics-alerting-recording-rules-alertmanager.md)
