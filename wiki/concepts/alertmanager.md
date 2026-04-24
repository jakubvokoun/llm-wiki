---
title: "Alertmanager"
tags: [alerting, alertmanager, prometheus, victoriametrics, monitoring, sre]
sources:
  [
    prometheus-alerting.md,
    victoriametrics-alerting-recording-rules-alertmanager.md,
  ]
updated: 2026-04-24
---

# Alertmanager

Prometheus Alertmanager handles alert routing, grouping, deduplication, inhibition, silencing, and notification delivery. Used by both Prometheus and vmalert (VictoriaMetrics).

## Alert flow

```
vmalert / Prometheus → Alertmanager → receivers (Slack, email, PagerDuty, ...)
```

Before sending, Alertmanager passes each alert through: routing → grouping → inhibition → silencing → notification.

## Routing

The routing tree matches alerts by label matchers and sends them to the appropriate receiver.

```yaml
route:
  receiver: "default-email"
  routes:
    - receiver: "oncall-pager"
      matchers:
        - severity="critical"
      continue: true # allow further matching after this route
```

- `continue: true` — alert can match multiple routes (otherwise stops at first match).
- Nested child routes can override `group_by` for finer-grained grouping.

## Grouping and timing

Groups related alerts into a single notification to reduce noise.

| Parameter         | Purpose                                                                 |
| ----------------- | ----------------------------------------------------------------------- |
| `group_by`        | Labels to group alerts by (e.g. `alertname`, `environment`)             |
| `group_wait`      | Delay before first notification (collects additional co-firing alerts)  |
| `group_interval`  | How often Alertmanager re-checks for new/resolved alerts within a group |
| `repeat_interval` | Resend frequency when nothing changes (reminder cadence)                |

Distinction: `group_interval` sends updates when alert state changes; `repeat_interval` resends as a reminder even without changes.

## Inhibition

Suppresses downstream (symptom) alerts when a root-cause alert is active.

```yaml
inhibit_rules:
  - source_match:
      service: "kafka_producer"
    target_match:
      service: "kafka_consumer"
    equal: ["environment", "topic"]
```

Inhibited alerts remain visible in the Alertmanager UI; only notifications are suppressed. Use inhibition to avoid alert storms during cascading failures (e.g. datacenter outage → suppress all dependent service alerts).

## Silencing

Temporarily mutes notifications for matching alerts without changing rules.

- Applied via: Alertmanager UI, `POST /api/v2/silences`, or `amtool` CLI.
- Each silence requires: label matchers, start/end time, creator name, comment.
- Commonly used for planned maintenance windows.

## Notification templates

Receivers use Go templates for message formatting:

| Placeholder                  | Value                           |
| ---------------------------- | ------------------------------- |
| `{{ .CommonAnnotations.X }}` | Annotation shared by all alerts |
| `{{ .Alerts.Firing }}`       | List of currently firing alerts |
| `{{ .Alerts.Resolved }}`     | List of just-resolved alerts    |

`send_resolved` default by receiver type:

- **True (default):** Discord, Email, PagerDuty, Slack, Telegram
- **False (default):** Webhook, VictorOps, Jira

## Related pages

- [Prometheus Alerting](prometheus-alerting.md)
- [Alert Severity Levels](alert-severity.md)
- [VictoriaMetrics](../entities/victoriametrics.md)
- [Prometheus](../entities/prometheus.md)
