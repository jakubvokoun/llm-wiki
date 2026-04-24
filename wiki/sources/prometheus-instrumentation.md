---
title: "Prometheus Instrumentation Best Practices"
tags: [prometheus, monitoring, instrumentation, observability, metrics]
sources: [prometheus-instrumentation.md]
updated: 2026-04-24
---

# Prometheus Instrumentation Best Practices

Official Prometheus guide for instrumenting code with metrics. Core principle: **instrument everything** — every library, subsystem, and service needs at least a few metrics.

Instantiate metric classes in the same file where they're used — this enables fast alert→console→code navigation during incidents.

## Service Types

### Online-Serving Systems

Human or system expects an immediate response (HTTP, database). Key metrics:

- Request rate (queries per second)
- Error rate (failed queries / total)
- Latency distribution (histogram/summary)
- In-progress requests (gauge)

Monitor on **both client and server sides**. Count queries at completion (aligns with error/latency stats).

### Offline Processing

No immediate response expected; batched work with multiple stages. Per stage:

- Items incoming / in-progress / sent out
- Last time something was processed
- Batch counts in/out

**Heartbeat pattern**: inject a dummy item with an insertion timestamp. Each stage exports the most recent heartbeat it has seen — reveals propagation delays.

### Batch Jobs

Distinguished by non-continuous execution (scraping is difficult). Key metrics:

- Last successful completion (gauge, pushed to PushGateway)
- Duration per major stage
- Overall runtime
- Total records processed

Batch jobs running > 15 minutes should also be scraped via pull for resource/latency tracking.

## Subsystem Instrumentation

| Subsystem         | Key Metrics                                                 |
| ----------------- | ----------------------------------------------------------- |
| Libraries         | query count, errors, latency                                |
| Logging           | counter per log line + totals by level                      |
| Failures          | counter per failure type + total attempts                   |
| Threadpools       | queued requests, threads in-use, tasks processed, wait time |
| Caches            | total queries, hits, latency                                |
| Custom collectors | collection duration (gauge), errors encountered             |

## Label Guidelines

- Use labels instead of multiple metric names for dimensions you want to aggregate/sum
- No part of a metric name should be procedurally generated — use labels instead
- Keep label cardinality **below 10** per metric
- Metrics with cardinality > 100: reconsider the design or move analysis to a general-purpose system

## Counter vs Gauge Decision

> "If the value can go down, it is a gauge."

- **Counter**: only goes up; use `rate()` to get per-second rates. Never `rate()` a gauge.
- **Gauge**: can go up or down; snapshots of state (in-progress requests, memory, temperature)

## Timestamps vs Time-Since

Export the Unix timestamp of the last event, not "time since event". Calculate age in PromQL: `time() - my_timestamp_metric`. Avoids stale update logic.

## Avoid Missing Metrics

Export `0` by default for all known time series. Most client libraries do this automatically for metrics without labels. Missing time series break simple PromQL operations.

## Inner Loop Performance

Java counter increment: ~12–17 ns. Usually negligible. For loops called > 100k/s, minimize label lookups and metric updates. Benchmark before optimizing.

## Related Pages

- [Prometheus](../entities/prometheus.md)
- [Prometheus Metric Naming](../sources/prometheus-naming.md)
- [Prometheus Histograms vs Summaries](../concepts/prometheus-histograms.md)
- [Kubernetes Observability](../concepts/kubernetes-observability.md)
