---
title: "Prometheus Metric and Label Naming Practices"
tags: [prometheus, monitoring, metrics, observability]
sources: [prometheus-naming.md]
updated: 2026-04-24
---

# Prometheus Metric and Label Naming Practices

Official Prometheus style guide for metric and label naming conventions.

## Metric Name Rules

- Single-word application prefix relevant to domain: `prometheus_`, `http_`, `process_`
- Base units only (seconds, bytes, meters, celsius) — never derived (milliseconds, megabytes)
- Unit suffix in plural form: `_seconds`, `_bytes`, `_total`
- Accumulating counters: `_total` suffix
- Single logical measurement across all label dimensions

**Good examples:**

```
http_request_duration_seconds
node_memory_usage_bytes
http_requests_total
process_cpu_seconds_total
```

## Why Naming Conventions Matter

Most metric consumption happens through plain YAML (alerting rules, recording rules, dashboards) — no IDE assistance. Well-named metrics are self-documenting during incident response. Unit suffixes also prevent naming collisions as metrics evolve.

## Label Guidelines

- Labels differentiate characteristics of measured items (HTTP status code, method, endpoint)
- Do **not** duplicate label name in the metric name
- Avoid high-cardinality labels: no user IDs, email addresses, UUIDs — these dramatically increase time series count and storage

## Base Units Reference

| Measurement   | Unit        |
| ------------- | ----------- |
| Time          | seconds     |
| Temperature   | celsius     |
| Length        | meters      |
| Data          | bytes       |
| Ratio/Percent | ratio (0–1) |
| Voltage       | volts       |
| Mass          | grams       |

## Related Pages

- [Prometheus](../entities/prometheus.md)
- [Prometheus Instrumentation](../concepts/prometheus-instrumentation.md)
- [Prometheus Metric Types](../concepts/prometheus-histograms.md)
- [Kubernetes Observability](../concepts/kubernetes-observability.md)
