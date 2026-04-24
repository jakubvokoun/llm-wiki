---
title: "Monitoring 101: Alerting on What Matters (Datadog)"
tags: [monitoring, alerting, observability, sre, on-call]
sources: [datadog-monitoring-101-alerting.md]
updated: 2026-04-24
---

# Monitoring 101: Alerting on What Matters (Datadog)

Published June 30, 2015. Part of the Monitoring 101 series. Draws on work by Brendan Gregg, Rob Ewaschuk, and Baron Schwartz.

## Two Core Principles

1. **Alert liberally; page judiciously** — capture everything, interrupt humans rarely
2. **Page on symptoms, rather than causes** — alert on what users experience, not on internal indicators

## Three Tiers of Alert Urgency

| Tier             | Severity | Action                                          | Example                                            |
| ---------------- | -------- | ----------------------------------------------- | -------------------------------------------------- |
| **Record**       | Low      | Log to monitoring system; no human notification | Data store queries slow but overall SLA unaffected |
| **Notification** | Moderate | Email/chat; can wait until business hours       | Disk space running low — needs attention in days   |
| **Page**         | High     | Immediate interrupt; respects no off-hours      | Web response times exceed internal SLA             |

All alerts should be logged centrally — even low-urgency ones provide valuable context when investigating later incidents.

## Three Questions Before Setting an Alert

1. **Is this issue real?** — Test env noise, planned maintenance, and fast-failover clusters should not page. Non-real issues generate alert fatigue and mask genuine problems.
2. **Does it require attention?** — If automatable, automate. If human action is needed: notify.
3. **Is it urgent?** — If users are affected right now: page. If fixable during business hours: notify.

Decision tree:

```
Real? → Yes → Needs attention? → Yes → Urgent? → Yes → PAGE
                                              ↓ No  → NOTIFY
                               ↓ No  → RECORD (log only)
   ↓ No → do nothing (test/noise)
```

## Why Symptoms, Not Causes

**Symptoms** = what users experience ("website responding slowly for 3 minutes").

**Causes** = internal metrics ("high load on web servers", "Cassandra node down").

Page on symptoms because:

- Users care about symptoms, not causes
- Symptom-based alerts are **durable** — they fire correctly even as architecture changes
- Cause-based alerts require constant maintenance as the stack evolves

## Exception: Early Warning Signs

A small set of metrics warrant paging _before_ symptoms appear — where the window to act is critically short:

- **Disk space** — when it runs out, the system hard-stops with almost no warning; automate remediation where possible (log rotation, cleanup)
- Any finite resource with catastrophic-and-non-recoverable exhaustion

These should still be designed with lead time: notify during business hours unless the window is measured in seconds.

## Key Takeaways

- Send a page **only** when symptoms of urgent problems are detected, or a critical finite resource limit is imminent
- Record all real issues in the monitoring system regardless of urgency — context for future investigation
- Fight alert fatigue by raising the bar for pages; use notifications for non-urgent issues

## Related Pages

- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Alert Severity Levels](../concepts/alert-severity.md)
- [Observability](../concepts/observability.md)
- [Application Performance Monitoring](../concepts/application-performance-monitoring.md)
- [Datadog](../entities/datadog.md)
