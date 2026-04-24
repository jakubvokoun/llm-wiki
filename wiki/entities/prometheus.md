---
title: "Prometheus"
tags: [monitoring, metrics, observability, timeseries]
sources:
  [
    prometheus-naming.md,
    prometheus-instrumentation.md,
    prometheus-histograms.md,
    prometheus-consoles.md,
    prometheus-alerting.md,
    prometheus-rules.md,
    prometheus-pushing.md,
    prometheus-remote-write.md,
    prometheus-the-zen.md,
  ]
updated: 2026-04-24
---

# Prometheus

Open-source monitoring system and time series database, originally developed at SoundCloud and now a CNCF graduated project. De facto standard for metrics collection in Kubernetes environments.

## Origin: Google Borgmon

Prometheus was directly inspired by Google's internal **Borgmon** monitoring system (built 2003). Borgmon pioneered the paradigm that Prometheus inherited:

- HTTP endpoint for metric export (Borgmon: `/varz`, Prometheus: `/metrics`)
- Time-series labeled by key-value pairs
- Algebraic rule language for deriving new time-series
- Centralized rule evaluation for alerting
- Separate Alertmanager for routing/deduplication

See [Borgmon](../concepts/borgmon.md) for full comparison.

## Core Concepts

**Pull-based scraping**: Prometheus scrapes HTTP `/metrics` endpoints from targets on a configured interval. Targets can also push via PushGateway (batch jobs).

**Time series model**: metrics are identified by name + label set. Each unique label combination is a separate time series.

**PromQL**: powerful query language for aggregation, rate calculation, and alerting.

## Metric Types

| Type      | Direction                   | Use For                                             |
| --------- | --------------------------- | --------------------------------------------------- |
| Counter   | Up only (resets on restart) | Events, totals; use `rate()`                        |
| Gauge     | Up and down                 | State snapshots (memory, in-progress reqs)          |
| Histogram | Bucketed observations       | Latency distributions; supports aggregation         |
| Summary   | Pre-computed quantiles      | Accurate quantiles; no aggregation across instances |

**Native histograms** (Prometheus 2.40+): preferred over classic histograms and summaries — dynamic exponential buckets, better accuracy, lower storage cost.

## Naming Conventions

- `<prefix>_<measurement>_<unit>` — e.g., `http_request_duration_seconds`
- Base units only: seconds, bytes, meters
- Counters end in `_total`
- No high-cardinality labels (no user IDs, email addresses)

## Service Instrumentation Patterns

- **Online-serving**: request rate + error rate + latency (both client and server side)
- **Offline processing**: per-stage counts + heartbeat timestamp
- **Batch jobs**: last success timestamp + stage durations → push to PushGateway

## Dashboard Design

- ≤ 5 graphs per console, ≤ 5 lines per graph
- Separate dashboards for on-call (operational) vs development (exploratory)
- Structure around failure modes, not data completeness

## Ecosystem

- **Alertmanager**: routing + deduplication of alerts
- **Grafana**: primary dashboard frontend
- **node_exporter**: system-level metrics
- **kube-state-metrics**: Kubernetes object state metrics
- **OpenTelemetry**: vendor-neutral instrumentation; can export to Prometheus

## Alerting

- Alert on **symptoms** (end-user pain), not causes — see [Prometheus Alerting](../concepts/prometheus-alerting.md)
- Recording rules follow `level:metric:operations` naming — see [Recording Rules](../concepts/prometheus-recording-rules.md)
- Pushgateway: only for service-level batch jobs; 3 key pitfalls (SPOF, no `up`, stale series) — see [Pushgateway](../concepts/prometheus-pushgateway.md)
- Remote write: WAL → shards → endpoint; +~25% memory; data lost after 2h outage — see [Remote Write](../concepts/prometheus-remote-write.md)

## Philosophy

The [Zen of Prometheus](../concepts/prometheus-zen.md) distills community best practices:
instrument first, cardinality matters, rate then aggregate, symptom-based paging.

## Related Pages

- [Kubernetes Observability](../concepts/kubernetes-observability.md)
- [Prometheus Instrumentation](../concepts/prometheus-instrumentation.md)
- [Prometheus Histograms vs Summaries](../concepts/prometheus-histograms.md)
- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Prometheus Recording Rules](../concepts/prometheus-recording-rules.md)
- [Prometheus Pushgateway](../concepts/prometheus-pushgateway.md)
- [Prometheus Remote Write](../concepts/prometheus-remote-write.md)
- [Zen of Prometheus](../concepts/prometheus-zen.md)
- [Prometheus Metric Naming](../sources/prometheus-naming.md)
- [Prometheus Consoles](../sources/prometheus-consoles.md)
