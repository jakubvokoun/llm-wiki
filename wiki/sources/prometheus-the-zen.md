---
title: "The Zen of Prometheus"
tags:
  [
    prometheus,
    philosophy,
    instrumentation,
    alerting,
    best-practices,
    cardinality,
  ]
sources: [prometheus-the-zen.md]
updated: 2026-04-24
---

# The Zen of Prometheus

Community-maintained core values and guidelines for Prometheus instrumentation and alerting. Inspired by the Zen of Python and Go Proverbs.

## Instrumentation principles

### Instrument first, ask questions later

You will never know during development what questions you need to ask later. Instrument everything — a metric without labels is cheap.

### Measure what users care about

Users care about latency and availability, not about CPU or database health directly. Let SLOs guide instrumentation. Use RED, USE, or Four Golden Signals as starting frameworks. Keep internal metrics for troubleshooting and capacity.

### Labels are the new hierarchies

Labels enable slicing and aggregation after the fact. Provide as much context as possible — but be mindful of cardinality.

### Avoid missing metrics

Initialize metrics with `0` to prevent broken dashboards and misfiring absence alerts. Client libraries cannot infer which label values will appear.

### Cardinality matters

Every unique label set creates a new time series. Unbounded labels blow up Prometheus. Prometheus performance almost always comes down to cardinality.

### Naming is hard

Respect community naming conventions over personal preferences. Conventions are no one's favorite, yet everyone's favorite.

### Counters rule, gauges suck

Expose raw counters; let PromQL's `rate()`/`increase()` derive rates. Don't pre-calculate rates on the target — that throws away information. Gauges only for things you measure directly (temperature, disk fullness, queue depth).

### First the rate, then aggregate

`rate()` must come before `sum()` across instances. Summing raw counter values across instances before taking the rate produces wrong results due to resets.

### If you can log it, you can have a metric for it

Whenever you log an event, count it. Cheap, and gives alerting on error rates.

## Histogram guidance

- **Native histograms** > classic histograms — no predefined buckets, dynamic resolution, sparse representation (empty buckets cost nothing)
- Classic histograms require knowing latency ranges upfront (conflicts with "instrument first"); let SLOs guide bucket boundaries when classic is required

## Alerting principles

- **If you can graph it, you can alert on it** — PromQL powers both dashboards and alerts
- **If you run it, alert on it** — at minimum: presence and healthiness (`up` metric)
- **Alerts should be urgent, important, actionable, and real** — alert fatigue is real
- **Symptom-based for paging, cause-based for troubleshooting** — don't page for CPU saturation if users are unaffected
- **`for` ≥ 5 minutes** — prevents a single scrape failure from firing; default to 5m minimum
- **Context is king** — preserve labels for routing and silencing

## See also

- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Prometheus Instrumentation](../concepts/prometheus-instrumentation.md)
- [Prometheus Histograms vs Summaries](../concepts/prometheus-histograms.md)
- [Prometheus Naming Practices](prometheus-naming.md)
- [Prometheus](../entities/prometheus.md)
