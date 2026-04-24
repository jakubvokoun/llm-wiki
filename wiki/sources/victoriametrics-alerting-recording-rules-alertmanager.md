---
title: "Prometheus Alerting 101: Rules, Recording Rules, and Alertmanager (VictoriaMetrics)"
tags:
  [
    alerting,
    recording-rules,
    alertmanager,
    prometheus,
    vmalert,
    victoriametrics,
    monitoring,
  ]
sources: [victoriametrics-alerting-recording-rules-alertmanager.md]
updated: 2026-04-24
---

# Prometheus Alerting 101: Rules, Recording Rules, and Alertmanager

**Author:** Phuong Le — VictoriaMetrics blog, Mar 18, 2025

Tutorial-level walkthrough of alerting rules, recording rules, rule groups, and Alertmanager in the VictoriaMetrics / Prometheus ecosystem.

## Alerting rules

A rule is a PromQL/MetricsQL expression evaluated periodically. An alerting rule creates an alert when the expression returns results.

```yaml
alert: HighCPUUsage
expr: avg by (instance) (rate(cpu_usage[5m])) > 80
for: 5m
labels:
  severity: critical
annotations:
  description: "Instance {{ $labels.instance }} has been using {{ $value }}% CPU for over 5 minutes."
```

- Each matching time series generates a **separate alert**.
- Alert is in **Pending** state until `for` duration passes; then becomes **Firing**.
- When expr returns no results, alert resolves and Alertmanager receives a resolved notification.

## Recording rules

Pre-compute expensive expressions; save results as new time series via remote write.

```yaml
record: instance:cpu_usage:avg5m
expr: avg by (instance) (rate(cpu_usage[5m]))
```

Naming convention: `level:metric:operations` (e.g. `instance:cpu_usage:avg5m`).  
The stored series can then be referenced in alerting rules, reducing evaluation cost.

## Alert templates

Annotations support Go templates with dynamic values:

| Placeholder       | Value                                    |
| ----------------- | ---------------------------------------- |
| `{{ $labels.X }}` | Label value from the matched time series |
| `{{ $value }}`    | Metric value at evaluation time          |
| `{{ $for }}`      | How long the condition has been active   |
| `{{ $activeAt }}` | Timestamp when the alert started         |

Additional functions: `humanize`, `jsonEscape`, `toTime`, and more (vmalert templating docs).

## Rule groups

Groups control evaluation scheduling:

```yaml
groups:
  - name: cpu-monitoring
    interval: 1m
    concurrency: 10 # run rules in parallel instead of sequentially
    eval_offset: 30m # run at :30 of each hour instead of :00
    rules:
      - record: instance:cpu_usage:avg5m
        expr: avg by (instance) (rate(cpu_usage[5m]))
      - alert: HighCPUUsage
        expr: instance:cpu_usage:avg5m > 80
        for: 5m
```

- Rules within a group run sequentially by default; `concurrency` parallelizes them.
- `eval_alignment: false` disables alignment to interval boundaries.
- `eval_offset` shifts the evaluation time within the interval.

## Alertmanager

Handles alert routing, grouping, deduplication, inhibition, silencing, and notification delivery.

### Routing

```yaml
route:
  receiver: "team-email"
  routes:
    - receiver: "engineer-pager"
      matchers:
        - severity="critical"
      continue: true # allow further route matching
    - receiver: "team-leader-pager"
      matchers:
        - severity="critical"
        - priority="high"
```

`continue: true` lets an alert match multiple routes (otherwise routing stops at first match).

### Grouping and timing

```yaml
route:
  group_by: ["alertname"]
  group_wait: 30s # wait before first notification (collect more alerts)
  group_interval: 5m # how often to check for updates within a group
  repeat_interval: 4h # resend unchanged notifications after this period
```

- `group_wait`: delay before first notification, collects additional alerts firing together.
- `group_interval`: how often Alertmanager re-checks for new/resolved alerts.
- `repeat_interval`: resend even if nothing changed (reminder cadence).

Child routes can override `group_by` for finer breakdown (e.g. by `environment` + `cluster`).

### Inhibition

Suppresses downstream alerts when a root-cause alert is present:

```yaml
inhibit_rules:
  - source_match:
      service: "kafka_producer"
    target_match:
      service: "kafka_consumer"
    equal: ["environment", "topic"]
```

Inhibited alerts still appear in the UI — they are silenced at the notification level only.

### Silencing

Mutes notifications without changing rules. Each silence requires: matchers, start/end time, comment, creator. Applied via Alertmanager UI, API (`POST /api/v2/silences`), or `amtool`.

### Notifications

- Templates available in receiver config: `{{ .CommonAnnotations.summary }}`, `{{ .Alerts.Firing }}`, `{{ .Alerts.Resolved }}`
- `send_resolved` controls whether resolved notifications are sent (default varies by receiver: true for Slack/Email/PagerDuty; false for Webhook/Jira)
- Resolved notifications are delayed until the next `group_interval` cycle.

## Related pages

- [VictoriaMetrics](../entities/victoriametrics.md)
- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Prometheus Recording Rules](../concepts/prometheus-recording-rules.md)
- [Alertmanager](../concepts/alertmanager.md)
- [Alert Severity Levels](../concepts/alert-severity.md)
