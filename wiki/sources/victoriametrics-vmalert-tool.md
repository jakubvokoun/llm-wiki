---
title: "VictoriaMetrics — vmalert-tool (Unit Testing)"
tags: [victoriametrics, vmalert, testing, unit-testing, metricsql, alerting]
sources: [victoriametrics-vmalert-tool.md]
updated: 2026-05-22
---

# VictoriaMetrics — vmalert-tool (Unit Testing)

`vmalert-tool` provides unit testing for alerting and recording rules without a running Prometheus/VictoriaMetrics instance.

## How It Works

1. Spins up an isolated VictoriaMetrics instance
2. Simulates periodic time series ingestion from test data
3. Evaluates recording and alerting rules like vmalert would
4. Checks results against expected alerts/values

## Running Tests

```bash
./vmalert-tool unittest --files /path/to/test.yaml
./vmalert-tool unittest --files http://server/path/to/test.yaml
```

Compatible with Prometheus unit test format, except uses `metricsql_expr_test` instead of `promql_expr_test` (since MetricsQL is not always backward-compatible with PromQL).

## Test File Format

```yaml
rule_files:
  - rules.yaml # rule files to test

evaluation_interval: 1m # how often rules are evaluated

group_eval_order:
  - groupA
  - groupB

tests:
  - interval: 1m
    input_series:
      - series: 'up{job="prometheus", instance="localhost:9090"}'
        values: "0+0x1440" # 0 for 1440 intervals

    alert_rule_test:
      - eval_time: 2h
        groupname: group1
        alertname: InstanceDown
        exp_alerts:
          - exp_labels:
              job: prometheus
              severity: page
              instance: localhost:9090
            exp_annotations:
              summary: "Instance localhost:9090 down"

    metricsql_expr_test:
      - expr: subquery_interval_test
        eval_time: 4m
        exp_samples:
          - labels: '{__name__="subquery_interval_test", instance="localhost:9090"}'
            value: 1
```

## Series Value Syntax

| Pattern | Meaning                         |
| ------- | ------------------------------- |
| `a+bxc` | `a, a+b, a+(2*b), ..., a+(c*b)` |
| `a-bxc` | `a, a-b, a-(2*b), ..., a-(c*b)` |
| `_`     | Missing sample                  |
| `stale` | Stale sample                    |

## Limitations

- All groups evaluated at `evaluation_interval`; per-group `interval` is ignored
- Recording rule chaining within a group is unsafe — use separate groups with `group_eval_order`

## Debug Mode

Set `debug: true` in a rule's config and run with `-loggerLevel=INFO` to get detailed logs for specific rules.

## Key Flags

```
-files           test file path or HTTP URL (array)
-disableAlertgroupLabel  don't add group Name label to alerts
-external.label  name=value label added to all rules and alerts
-external.url    external URL for template use
-loggerLevel     INFO | WARN | ERROR | FATAL | PANIC (default: ERROR)
```

## Related

- [VictoriaMetrics vmalert](../sources/victoriametrics-vmalert.md)
- [Prometheus Recording Rules config](../sources/prometheus-recording-rules.md)
- [VictoriaMetrics Alerting Best Practices](../sources/victoriametrics-alerting-best-practices.md)
