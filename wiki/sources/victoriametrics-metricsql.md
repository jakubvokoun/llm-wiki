---
title: "VictoriaMetrics — MetricsQL"
tags: [victoriametrics, metricsql, promql, query-language, rollup-functions]
sources: [victoriametrics-metricsql.md]
updated: 2026-05-22
---

# VictoriaMetrics — MetricsQL

MetricsQL is VictoriaMetrics' query language — a superset of PromQL with additional functionality for practical use cases.

## Key Features Beyond PromQL

### Syntax Enhancements

- **Graphite filters**: `{__graphite__="foo.*.bar"}` syntax for Graphite-compatible metric selection
- **Omit lookbehind window**: `rate(metric)` works without `[interval]` — VM auto-selects based on `step` and `scrape_interval`
- **Numeric underscore separators**: `1_234_567_890` for readability
- **Multiple `or` filters in selectors**: `{env="prod",job="a" or env="dev",job="b"}`
- **Multi-constant matching**: `status_code == (300, 301, 304)` and `!= (C1, ..., CN)`
- **`group_left(*)`**: copy all labels from the "one" side, with optional prefix: `group_left(*) prefix "ns_"`
- **Trailing commas** allowed in label filters, function args, and WITH expressions
- **Unicode metric/label names**: `ტემპერატურა{πόλη="Київ"}` is valid
- **Escaped chars in names**: `foo\-bar{baz\=aa="b"}`
- **Aggregate `limit N` suffix**: `sum(x) by (y) limit 3` caps output series
- **`@` modifier anywhere** in query: `sum(foo) @ end()`, `foo @ (end() - 1h)`
- **`[Ni]` step references**: `rate(metric[10i] offset 5i)` — 10 steps lookbehind
- **`offset` anywhere**: `sum(foo) offset 24h`
- **Fractional durations**: `rate(node_network_receive_bytes_total[1.5m] offset 0.5d)`
- **Duration suffix optional** (seconds default): `rate(m[300])` = `rate(m[5m])`
- **SI suffixes**: `8K` = 8000, `1.2Mi` = 1.2 × 1024²
- **String concatenation**: `WITH (p="prefix_") {__name__=p+"suffix"}`
- **`keep_metric_names` modifier**: prevents dropping metric name after functions

### Binary Operators

- **`default`**: `q1 default q2` fills gaps in `q1` with `q2`
- **`if`**: `q1 if q2` removes values from `q1` where `q2` has no values
- **`ifnot`**: `q1 ifnot q2` removes values from `q1` where `q2` exists

### WITH Templates

Reusable query expressions for managing complex queries:

```
WITH (
  commonRate = rate(http_requests_total[5m]),
  errorRate = rate(http_requests_total{status=~"5.."}[5m])
)
errorRate / commonRate
```

## Function Categories

- **Rollup functions**: compute over time windows (`rate`, `avg_over_time`, quantile functions)
- **Transform functions**: mathematical and logical transformations
- **Label manipulation functions**: extract, set, replace labels
- **Aggregate functions**: cross-series aggregation (support optional `limit N`)

## Auto-Lookbehind Selection

When the lookbehind window is omitted:

- For most rollup functions: uses `step` value (= `$__interval` in Grafana)
- For `default_rollup` and `rate`: uses `max(step, scrape_interval)`

## Related

- [VictoriaMetrics entity](../entities/victoriametrics.md)
- [VictoriaMetrics vmalert](../sources/victoriametrics-vmalert.md)
- [Prometheus Recording Rules concept](../concepts/prometheus-recording-rules.md)
