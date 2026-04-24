---
title: "Prometheus Recording Rules Best Practices"
tags: [prometheus, recording-rules, promql, monitoring]
sources: [prometheus-rules.md]
updated: 2026-04-24
---

# Prometheus Recording Rules Best Practices

Official Prometheus guidance on naming and aggregating recording rules.

## Naming convention: `level:metric:operations`

| Component    | Meaning                                                  |
| ------------ | -------------------------------------------------------- |
| `level`      | Aggregation level and label dimensions present in output |
| `metric`     | Original metric name; strip `_total` for counter rates   |
| `operations` | Operations applied, newest first                         |

Rules:

- `_sum` omitted when other operations also exist
- Associative operations collapse: `min_min` → `min`
- Use `sum` when no obvious operation applies
- Division: use `_per_` separator and `ratio` operation (e.g. `failures_per_requests:ratio_rate5m`)

Examples:

```
instance_path:requests:rate5m
job:request_failures_per_requests:ratio_rate5m
path:request_latency_seconds:mean5m
```

## Aggregation rules

1. **Ratio aggregation** — aggregate numerator and denominator separately, then divide
2. **Never** average a ratio or average an average (statistically invalid)
3. **Summary mean** — keep metric name without `_count`/`_sum`, replace `rate` with `mean`
4. **Always use `without` clause** — preserves useful labels like `job`, avoids conflicts

## Correctness check

When aggregating, the labels removed in the `without` clause must be removed from
the `level` component of the output metric name relative to the input. If levels
don't match after aggregation, a mistake was made.

## See also

- [Prometheus Recording Rules Concept](../concepts/prometheus-recording-rules.md)
- [Prometheus Alerting Practices](prometheus-alerting.md)
- [Prometheus](../entities/prometheus.md)
