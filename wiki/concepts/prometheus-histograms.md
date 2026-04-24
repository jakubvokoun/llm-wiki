---
title: "Prometheus Histograms vs Summaries"
tags: [prometheus, monitoring, histograms, summaries, metrics]
sources: [prometheus-histograms.md]
updated: 2026-04-24
---

# Prometheus Histograms vs Summaries

Prometheus offers four metric types. For **distribution tracking** (latency, sizes), the choice is between histograms and summaries.

## Decision Rule

**Prefer native histograms** whenever possible. They supersede both classic histograms and summaries.

Use summaries only when accurate per-instance quantiles are required and cross-instance aggregation is never needed.

## Comparison

| Property                   | Summary | Classic Histogram    | Native Histogram |
| -------------------------- | ------- | -------------------- | ---------------- |
| Quantile location          | Client  | Server (PromQL)      | Server (PromQL)  |
| Cross-instance aggregation | No      | Yes                  | Yes              |
| Bucket config required     | No      | Yes (pre-configured) | No (dynamic)     |
| Ad-hoc percentiles         | No      | Yes                  | Yes              |
| Ad-hoc time windows        | No      | Yes                  | Yes              |
| Storage efficiency         | Medium  | Low (many series)    | High             |
| Accuracy when values drift | High    | Low                  | High             |

## Why Summaries Cannot Be Aggregated

Summaries pre-compute quantiles over a sliding time window in the client. The p99 of a summary across 10 instances **cannot** be computed by averaging their p99 values — the result is mathematically meaningless. Use histograms and `histogram_quantile()` instead.

## Native Histograms

Introduced in Prometheus 2.40. Use dynamic exponential bucket boundaries — no pre-configuration needed. A single composite sample replaces many time series, dramatically reducing storage. Provide better accuracy when the observed value distribution drifts from the expected range.

## NHCB — Migration Path

**Native Histogram with Custom Bucket boundaries**: allows the Prometheus server to ingest classic histogram metrics as native histograms without changing client instrumentation. Provides storage efficiency benefits while maintaining backward query compatibility. Useful as an intermediate step when migrating large existing systems.

## Migration Path

```
Classic Histogram → NHCB (server-side) → Native Histogram (client-side)
```

## Related Pages

- [Prometheus](../entities/prometheus.md)
- [Prometheus Instrumentation](../concepts/prometheus-instrumentation.md)
- [Kubernetes Observability](../concepts/kubernetes-observability.md)
