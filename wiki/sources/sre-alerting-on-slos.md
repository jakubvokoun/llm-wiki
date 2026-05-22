---
title: "SRE Workbook — Chapter 5: Alerting on SLOs"
tags: [sre, alerting, slo, error-budget, burn-rate, multiwindow]
sources: [sre-alerting-on-slos.md]
updated: 2026-05-22
---

# SRE Workbook — Chapter 5: Alerting on SLOs

By Steven Thurgood et al. Presents six progressively more sophisticated strategies for turning SLOs into actionable alerts, evaluated against four criteria.

## Four Alerting Criteria

| Criterion | Definition |
| --- | --- |
| **Precision** | Proportion of alerts that corresponded to a significant event |
| **Recall** | Proportion of significant events that triggered an alert |
| **Detection time** | Time from problem start to notification |
| **Reset time** | Time alert continues firing after the problem resolves |

## Six Approaches (Summary)

### 1 — Target Error Rate ≥ SLO Threshold (10 min window)

Alert when recent error rate ≥ SLO threshold over 10 minutes.

- Good detection time (0.6s for total outage)
- Very low precision: 0.1% error for 10 min = 0.02% budget spend but still alerts

### 2 — Increased Alert Window (36 hours)

Increase window to require 5% budget spend before alerting.

- Better precision
- Very poor reset time: fires for 36 hours after a 100% outage
- Expensive to compute

### 3 — Incrementing Alert Duration (`for: 1h`)

Use `for:` clause to require sustained error rate.

- Poor recall and detection time: both 100% outage and 0.2% outage alert after 1 hour
- Duration timer resets on any brief recovery — spike services can spend 35% of budget without ever alerting
- **Not recommended for SLO-based alerting**

### 4 — Alert on Burn Rate

Burn rate = how fast budget is consumed relative to SLO. At 99.9%/30 days:

| Burn rate | Error rate | Time to exhaustion |
| --------- | ---------- | ------------------ |
| 1         | 0.1%       | 30 days            |
| 10        | 1%         | 3 days             |
| 1,000     | 100%       | 43 min             |

Alert formula: `error_rate_1h > (burn_rate × (1 − SLO))` where burn_rate 36 = 5% budget in 1 hour.

- Good precision and detection
- Poor recall (35x burn rate never alerts), 58-min reset time

### 5 — Multiple Burn Rate Alerts

Use multiple windows + burn rates, different notification channels:

| Budget consumed | Window  | Burn rate | Action |
| --------------- | ------- | --------- | ------ |
| 2%              | 1 hour  | 14.4      | Page   |
| 5%              | 6 hours | 6         | Page   |
| 10%             | 3 days  | 1         | Ticket |

- Good precision + recall
- Long reset time from 3-day window; requires alert suppression to avoid triple-paging

### 6 — Multiwindow, Multi-Burn-Rate Alerts (Recommended)

Combine long window (burn detection) with short window (1/12 the long) to confirm the error is still ongoing:

```yaml
# Page: 2% budget in 1h and still burning
expr: (
    job:slo_errors_per_request:ratio_rate1h{job="myjob"} > (14.4*0.001)
  and
    job:slo_errors_per_request:ratio_rate5m{job="myjob"} > (14.4*0.001)
  )
or (
    job:slo_errors_per_request:ratio_rate6h{job="myjob"} > (6*0.001)
  and
    job:slo_errors_per_request:ratio_rate30m{job="myjob"} > (6*0.001)
  )
severity: page

# Ticket: 10% budget in 3d and still burning
expr: (
    job:slo_errors_per_request:ratio_rate3d{job="myjob"} > 0.001
  and
    job:slo_errors_per_request:ratio_rate6h{job="myjob"} > 0.001
  )
severity: ticket
```

Final reset time: ~5 minutes after errors stop (short window clears quickly).

## Low-Traffic Services

Multi-burn-rate alerting breaks down with low traffic because single failures produce extreme burn rates. Alternatives: increase time windows, use separate alerting for reliability-critical endpoints, or combine with user-impacting signals.

## Key Takeaways

- **Never use `for:` as the primary SLO alerting mechanism** — it has poor recall and a reset timer that can miss sustained spikes
- **Burn rate is the key concept** — normalize error rate against the SLO threshold
- **Multiwindow is the gold standard** — long window detects, short window confirms, gives fast reset
- **Ticket vs page** — slow budget drain warrants a ticket; fast exhaustion warrants a page

## Related

- [Service Level Objectives concept](../concepts/service-level-objectives.md)
- [Error Budgets concept](../concepts/error-budgets.md)
- [Prometheus Alerting best practices](../sources/prometheus-alerting.md)
- [Prometheus Alerting Rules config](../sources/prometheus-alerting-rules.md)
- [VictoriaMetrics Alerting Best Practices](../sources/victoriametrics-alerting-best-practices.md)
