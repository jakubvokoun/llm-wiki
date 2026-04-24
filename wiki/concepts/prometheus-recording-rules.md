---
title: "Prometheus Recording Rules"
tags: [prometheus, recording-rules, promql, monitoring, performance]
sources: [prometheus-rules.md]
updated: 2026-04-24
---

# Prometheus Recording Rules

Recording rules pre-compute frequently needed or expensive PromQL expressions
and save results as new time series, improving query performance and dashboard
load times.

## Naming scheme

```
level:metric:operations
```

| Component    | Meaning                                            |
| ------------ | -------------------------------------------------- |
| `level`      | Aggregation level and labels present in the output |
| `metric`     | Original metric name (strip `_total` for rates)    |
| `operations` | Applied operations, newest first                   |

Examples: `instance_path:requests:rate5m`, `job:request_failures_per_requests:ratio_rate5m`

## Aggregation correctness

- **Ratios**: aggregate numerator and denominator separately, then divide
- **Never** average of averages (statistically invalid)
- **Summary means**: replace `rate` with `mean` in the operation name
- **`without` clause**: always specify labels being aggregated away to preserve
  useful labels like `job`

## Consistency check

The labels removed in the `without` clause should also be removed from the `level`
component of the output metric name compared to inputs. Mismatches indicate an error.

## Use cases

- Pre-aggregation for dashboards with high time-series fan-out
- Cross-job ratio computations (failure rate, latency percentiles)
- Alert rules that would otherwise be slow to evaluate

## Related

- [Prometheus Recording Rules Source](../sources/prometheus-rules.md)
- [Prometheus Alerting](prometheus-alerting.md)
- [Prometheus](../entities/prometheus.md)
