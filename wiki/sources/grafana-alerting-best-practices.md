---
title: "Grafana Alerting Best Practices"
tags: [alerting, monitoring, grafana, sre, on-call, runbooks]
sources: [grafana-alerting-best-practices.md]
updated: 2026-04-24
---

# Grafana Alerting Best Practices

Official Grafana documentation guide for reliable, maintainable alert systems.

## 1. Define Clear Alert Rules

- Keep conditions simple and understandable
- Use meaningful, SLA-derived thresholds — test them in dev first
- Use **duration** (`for: 5m`) not instantaneous values:
  ```
  alert when CPU > 85% for 5 minutes (sustained)
  # not: alert when CPU > 80%
  ```
- Use relative thresholds where appropriate (e.g., >20% above baseline)

## 2. Organize with Folders and Groups

Structure by team/service:

```
/teams/
  /platform/
    database-alerts.yml
    kubernetes-alerts.yml
  /security/
    access-control-alerts.yml
```

Group related alerts; document the purpose of each folder.

## 3. Descriptive Names and Labels

**Names** — include metric and condition; make them searchable:

| Good                          | Avoid       |
| ----------------------------- | ----------- |
| `PostgresHighConnectionCount` | `alert1`    |
| `KubernetesNodeCPUHigh`       | `cpu_alert` |
| `ResponseTimeP99Elevated`     | `error`     |

**Labels** — route and group alerts:

```yaml
labels:
  severity: critical
  team: platform
  service: api
  environment: production
```

## 4. Severity Levels

| Level        | Meaning                                                   | Channel                        |
| ------------ | --------------------------------------------------------- | ------------------------------ |
| **Critical** | Immediate action required; service down/severely degraded | PagerDuty, SMS, Slack @channel |
| **Warning**  | Issue detected; may impact service; investigation needed  | Slack, email                   |
| **Info**     | Informational; no immediate action                        | Email digest                   |

Rules:

- Use **critical sparingly** — only for true immediate-action incidents
- Warning alerts must have clear remediation steps
- Always include runbook links or documentation in alert descriptions
- Match severity to actual business impact

## 5. Notification Channels

- Test all channels regularly
- Configure on-call rotation
- Use **alert grouping** to reduce noise
- Set escalation policies for critical alerts
- Monitor notification delivery health

## 6. Test Your Alerts

Three levels:

| Level           | Scope                    | What to check                                           |
| --------------- | ------------------------ | ------------------------------------------------------- |
| **Unit**        | Alert rule in isolation  | Threshold triggers, query performance, label generation |
| **Integration** | End-to-end flow          | Notifications sent, message formatting, routing logic   |
| **Load**        | Under production traffic | Evaluation performance, resource usage, data volume     |

Use Grafana's built-in testing, synthetic data sources, and staging environments.

## 7. Document Alert Rules

For each rule, document 6 dimensions:

| Field     | Content                           |
| --------- | --------------------------------- |
| **What**  | What is being monitored           |
| **Why**   | Business reason for the alert     |
| **When**  | Exact conditions that trigger it  |
| **How**   | Runbook link / response steps     |
| **Who**   | Responsible team                  |
| **Links** | Related dashboards, documentation |

Example YAML comment header:

```yaml
# PostgreSQL High Connection Count
# WHAT: Monitors active database connections
# WHY: High connections indicate potential connection leak
# WHEN: >500 connections for 5 minutes
# HOW: https://wiki.example.com/postgres-connections
# WHO: Database team
# LINKS: https://grafana.example.com/d/postgres-dashboard
```

## 8. Runbook Template

Each alert should link to a runbook with:

1. **Alert description** — what triggers it
2. **Impact** — what breaks for users
3. **Diagnosis steps** — concrete commands/queries to run
4. **Remediation steps** — ordered actions to resolve
5. **Escalation** — who to page if initial steps fail

## 9. Maintenance Schedule

| Cadence   | Activity                                      |
| --------- | --------------------------------------------- |
| Weekly    | Review firing patterns; identify noisy alerts |
| Monthly   | Review documentation and runbooks             |
| Quarterly | Evaluate thresholds against actual behavior   |
| Annually  | Full audit of all alert rules                 |

Track: alert firing frequency, MTTR, false positive rate, alert-to-incident ratio.

## 10. Common Pitfalls

| Pitfall               | Fix                                                                        |
| --------------------- | -------------------------------------------------------------------------- |
| **Alert fatigue**     | Monitor false positive rate; combine related alerts; adjust thresholds     |
| **Lack of context**   | Always include runbook links; document customer impact                     |
| **Poor routing**      | Clear labels; test notification delivery; verify routing rules             |
| **Static thresholds** | Use dynamic baselines; account for time-of-day variation                   |
| **No escalation**     | Define escalation policies; ensure on-call coverage; time-based escalation |

## Related Pages

- [Alert Severity Levels](../concepts/alert-severity.md)
- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Runbooks](../concepts/runbooks.md)
- [Grafana](../entities/grafana.md)
- [Observability](../concepts/observability.md)
