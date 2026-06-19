---
title: "Zen of Prometheus"
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

# Zen of Prometheus

Core values and guidelines from the Prometheus community for instrumentation and alerting. Inspired by the Zen of Python and Go Proverbs.

## Instrumentation

| Principle | Rule |
| --- | --- |
| Instrument first | Always instrument; you don't know what you'll need later |
| Measure user experience | Alert on latency/availability, not CPU/DB health |
| Labels are the new hierarchies | Use labels generously; slice/dice after the fact |
| Avoid missing metrics | Initialize with `0` to prevent broken dashboards and misfiring alerts |
| Cardinality matters | Every label set = new time series; unbounded labels blow up Prometheus |
| Counters rule | Expose raw counters; let `rate()`/`increase()` derive; never pre-rate |
| Rate then aggregate | Always `rate()` before `sum()` across instances |
| Log it → metric it | Count logged events by category; cheap, enables alerting |

## Histograms

Prefer **native histograms** — no predefined buckets, dynamic resolution, sparse. Classic histograms require upfront knowledge of latency ranges; let SLOs guide bucket boundaries when classic histograms are required.

## Alerting

| Principle | Rule |
| --- | --- |
| Graph it → alert on it | PromQL powers both dashboards and alerts |
| Run it → alert on it | At minimum: `up` metric for presence and healthiness |
| Quality gates | Alerts must be urgent, important, actionable, and real |
| Symptom-based paging | Page on user impact, not internal causes |
| `for` ≥ 5 minutes | Prevents single scrape failure from triggering a page |
| Context is king | Preserve labels for alert routing and silencing |

## Related

- [Prometheus Alerting](prometheus-alerting.md)
- [Prometheus Instrumentation](prometheus-instrumentation.md)
- [Prometheus Histograms vs Summaries](prometheus-histograms.md)
- [Prometheus Recording Rules](prometheus-recording-rules.md)
- [Prometheus Pushgateway](prometheus-pushgateway.md)
- [Prometheus Remote Write](prometheus-remote-write.md)
- [Prometheus](../entities/prometheus.md)
- [The Prometheus Zen (source)](../sources/prometheus-the-zen.md)
