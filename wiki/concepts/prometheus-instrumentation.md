---
title: "Prometheus Instrumentation"
tags: [prometheus, monitoring, observability, metrics, instrumentation]
sources: [prometheus-instrumentation.md]
updated: 2026-04-24
---

# Prometheus Instrumentation

Best practices for instrumenting services, libraries, and subsystems with Prometheus metrics. Core rule: instrument everything — every library and service needs at minimum a few metrics.

## Service Classification

### Online-Serving Systems

Immediate response expected (HTTP, database, gRPC). Key metrics:

- `<name>_requests_total` — counter
- `<name>_errors_total` — counter (also track against total for ratio)
- `<name>_request_duration_seconds` — histogram
- `<name>_requests_in_flight` — gauge

Monitor on both client and server sides. Count at request completion.

### Offline Processing

Batched, multi-stage. Per stage:

- Items in / in-progress / out
- `<stage>_last_processed_timestamp_seconds` — gauge
- Batch counts in/out

Use **heartbeat items** with insertion timestamps rather than simple "last processed" gauges — reveals actual propagation latency.

### Batch Jobs

Non-continuous; push to PushGateway **only for service-level batch jobs** (not
machine-bound). Key metrics:

- `<job>_last_success_timestamp_seconds` — gauge (most important)
- Duration per major stage
- `<job>_records_processed_total` — counter

If runtime > 15 min, also enable pull scraping for resource tracking.

Pushgateway pitfalls: SPOF, no `up` metric, stale series never auto-expire.
For machine-bound jobs, use Node Exporter textfile collector instead.
See [Prometheus Pushgateway](prometheus-pushgateway.md).

## Subsystem Guidelines

**Libraries**: query count, errors, latency. Use labels to distinguish resources (DB names, not client identity).

**Logging**: counter per log level; counter per interesting log message. Export `info_messages_total`, `warning_messages_total`, `error_messages_total`.

**Failures**: counter per failure type + a corresponding total-attempts counter (enables ratio). Failures may bubble up to a general error counter.

**Threadpools**: queued requests, threads in use, total threads, tasks processed, task duration, queue wait time.

**Caches**: total queries, cache hits, latency, plus the downstream system's query/error/latency.

**Custom collectors**: export `<collector>_scrape_duration_seconds` (gauge) and `<collector>_scrape_errors_total`.

## Label Cardinality

Each unique label set = a separate time series = RAM + CPU + disk cost.

| Cardinality | Action                                       |
| ----------- | -------------------------------------------- |
| < 10        | Fine                                         |
| 10–100      | Monitor growth                               |
| > 100       | Redesign; move to general-purpose processing |

Never put user IDs, email addresses, or UUIDs in labels.

## Metric Type Selection

> "If the value can go down, it is a gauge."

| Type      | When                                                  |
| --------- | ----------------------------------------------------- |
| Counter   | Events, totals; use `rate()` for per-second           |
| Gauge     | State snapshots; never `rate()`                       |
| Histogram | Latency/size distributions; supports aggregation      |
| Summary   | Accurate quantiles; cannot aggregate across instances |

## Other Rules

- **Timestamps not durations**: export Unix timestamp, calculate age with `time() - metric`
- **Default zero**: always export `0` for known time series; missing series break PromQL
- **Inner loops**: counters cost ~12–17 ns; only optimize if > 100k/s per process

## Related Pages

- [Prometheus](../entities/prometheus.md)
- [Prometheus Histograms vs Summaries](../concepts/prometheus-histograms.md)
- [Kubernetes Observability](../concepts/kubernetes-observability.md)
