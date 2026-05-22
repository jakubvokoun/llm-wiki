---
title: "VictoriaMetrics — vmalert"
tags:
  [victoriametrics, vmalert, alerting, recording-rules, alertmanager, metricsql]
sources: [victoriametrics-vmalert.md]
updated: 2026-05-22
---

# VictoriaMetrics — vmalert

`vmalert` is VictoriaMetrics' alerting and recording rule evaluation engine — heavily inspired by Prometheus alerting but with MetricsQL support and additional features.

## Quick Start

```bash
./bin/vmalert \
  -rule=alert.rules \                        # rule files (YAML)
  -datasource.url=http://victoriametrics:8428 \  # VictoriaMetrics endpoint
  -notifier.url=http://alertmanager:9093 \   # Alertmanager
  -remoteWrite.url=http://victoriametrics:8428 \ # persist recording rule results
  -remoteRead.url=http://victoriametrics:8428    # restore alert state on restart
```

## Features

- **MetricsQL and PromQL** support for alerting/recording rules
- **VictoriaLogs integration** via LogsQL for log-based alerts
- **VictoriaTraces integration** for trace-based alerting
- **Prometheus-compatible rule format** (alerting + recording rules)
- **Alertmanager integration** (v0.16.0-alpha+)
- **Alert state persistence** across restarts via remoteRead/remoteWrite
- **Graphite datasource** support
- **Rules backfilling** (replay historical data)
- **Reusable annotation templates**
- **Load rules from**: local files, URL, GCS, S3
- **Detect rules matching no series**
- Lightweight, no extra dependencies

## Rule Types

### Alerting Rules

```yaml
groups:
  - name: MyAlerts
    interval: 1m
    rules:
      - alert: HighErrorRate
        expr: sum(rate(errors_total[5m])) / sum(rate(requests_total[5m])) > 0.01
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate: {{ $value }}"
```

### Recording Rules

```yaml
groups:
  - name: RecordingRules
    interval: 5m
    rules:
      - record: job:request_errors:ratio_rate5m
        expr: sum(rate(errors_total[5m])) by (job) / sum(rate(requests_total[5m])) by (job)
```

## Key Flags

| Flag                    | Description                                       |
| ----------------------- | ------------------------------------------------- |
| `-rule`                 | Rule file path or URL (array)                     |
| `-datasource.url`       | Prometheus-compatible datasource                  |
| `-notifier.url`         | Alertmanager URL (array)                          |
| `-remoteWrite.url`      | Storage for recording results and alert state     |
| `-remoteRead.url`       | Prometheus-compatible endpoint to restore state   |
| `-rule.defaultRuleType` | `prometheus` (default), `graphite`, or `vlogs`    |
| `-rule.evalDelay`       | Compensation for intentional data ingestion delay |
| `-rule.evalConcurrency` | Number of concurrent rule evaluations             |

## Limitations

- Network-based queries have reliability risk — design thresholds with network failure in mind
- Recording rule chaining within one group is unsafe due to async persistence; use separate groups or `group_eval_order`

## Chaining Groups

When recording rule B depends on recording rule A, put them in separate groups with A listed first:

```yaml
groups:
  - name: groupA
    rules:
      - record: A
        expr: sum(xxx)
  - name: groupB
    rules:
      - alert: B
        expr: A >= 0.75
        for: 1m
```

## Rules Backfilling (Replay)

```bash
./bin/vmalert \
  -rule=path/to/your.rules \
  -datasource.url=http://localhost:8428 \
  -remoteWrite.url=http://localhost:8428 \
  -replay.timeFrom=2024-01-01T00:00:00Z \
  -replay.timeTo=2024-01-31T23:59:59Z
```

## Related

- [VictoriaMetrics entity](../entities/victoriametrics.md)
- [MetricsQL](../sources/victoriametrics-metricsql.md)
- [vmalert-tool (unit testing)](../sources/victoriametrics-vmalert-tool.md)
- [VictoriaLogs vmalert](../sources/victorialogs-vmalert.md)
- [vmanomaly + vmalert guide](../sources/vmanomaly-vmalert-guide.md)
- [Alertmanager concept](../concepts/alertmanager.md)
- [VictoriaMetrics Alerting Best Practices](../sources/victoriametrics-alerting-best-practices.md)
