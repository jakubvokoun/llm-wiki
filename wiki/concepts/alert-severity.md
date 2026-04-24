---
title: "Alert Severity Levels"
tags: [alerting, monitoring, sre, on-call, observability]
sources: [datadog-monitoring-101-alerting.md]
updated: 2026-04-24
---

# Alert Severity Levels

A tiered alerting model separates noise from actionable signals and pages from non-urgent notifications — the foundation of sustainable on-call operations.

## Core Principle: Symptoms Over Causes

Page on what **users experience** (symptoms), not on internal indicators (causes):

- Symptom: "90% of requests exceed 500ms SLA"
- Cause: "Web server CPU at 95%"

Symptoms are durable — they fire correctly as architecture evolves. Cause-based alerts require constant maintenance.

## Three Urgency Tiers

| Tier             | Also Called     | Delivery                 | Human Interruption       | Example                                  |
| ---------------- | --------------- | ------------------------ | ------------------------ | ---------------------------------------- |
| **Record**       | Low / Info      | Log to monitoring system | None                     | Slow queries, no user impact             |
| **Notification** | Moderate / Warn | Email, chat message      | Async, business hours OK | Disk 80% full, needs attention this week |
| **Page**         | High / Critical | PagerDuty, SMS, phone    | Immediate, any hour      | Response times breaching SLA             |

All tiers should be logged centrally — low-urgency records provide context when investigating later incidents.

## Decision Framework

Before setting any alert, ask three questions:

1. **Is this real?** — Exclude test environments, planned maintenance, auto-healing clusters. Non-real alerts cause fatigue.
2. **Does it need human attention?** — If automatable, automate. If human judgment is needed: notify or page.
3. **Is it urgent right now?** — Users affected now → page. Can wait until business hours → notify.

## Alert Fatigue

Alert fatigue occurs when too many low-signal alerts desensitize teams to genuine incidents. Consequences:

- Engineers ignore pages or turn off notifications
- Real incidents missed
- On-call burnout

Prevention:

- Raise the bar for pages; use notifications for non-urgent issues
- Tune thresholds continuously; retire alerts that never lead to action
- Avoid paging on causes (flapping internal metrics)

## Early Warning Exceptions

A small set of **leading indicators** warrant pages before symptoms appear — where resource exhaustion is sudden and non-recoverable:

- **Disk space** — hard stop with minimal warning; automate cleanup where possible
- Any finite resource with catastrophic exhaustion semantics

Design early warning alerts with lead time; notify during business hours unless the window is measured in seconds.

## Related Pages

- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Observability](../concepts/observability.md)
- [Application Performance Monitoring](../concepts/application-performance-monitoring.md)
- [Datadog](../entities/datadog.md)
