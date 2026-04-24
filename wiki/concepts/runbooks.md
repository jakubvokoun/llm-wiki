---
title: "Runbooks"
tags: [runbooks, sre, incident-response, alerting, on-call]
sources: [grafana-alerting-best-practices.md, sre-book-introduction.md]
updated: 2026-04-24
---

# Runbooks

Runbooks are documented, step-by-step procedures for diagnosing and resolving specific incidents. They codify institutional knowledge, enabling consistent and rapid incident response without relying on individual expertise.

## Why Runbooks Matter

- Reduce cognitive load during high-stress incidents
- Enable junior engineers to handle known incidents independently
- Ensure consistent remediation across different on-call rotations
- Codify post-incident learnings to prevent recurrence
- Satisfy audit/compliance requirements (documented procedures)

## Runbook Template

Each alert should link to a runbook with five sections:

1. **Alert description** — what triggers this runbook (query, threshold, duration)
2. **Impact** — what breaks for users; business consequences
3. **Diagnosis steps** — ordered, concrete commands/queries to understand state:
   ```sql
   SELECT count(*) FROM pg_stat_activity;
   SELECT * FROM pg_stat_activity WHERE state != 'idle';
   ```
4. **Remediation steps** — ordered actions to resolve; include rollback if applicable
5. **Escalation** — who to page if initial steps fail; escalation paths and SLAs

## Alert Documentation Fields

For every alert rule, document:

| Field     | Content                          |
| --------- | -------------------------------- |
| **What**  | What is being monitored          |
| **Why**   | Business reason for the alert    |
| **When**  | Exact conditions that trigger it |
| **How**   | Link to this runbook             |
| **Who**   | Owning team                      |
| **Links** | Dashboards, docs, related alerts |

## Runbook Management

- Store runbooks in **version control** (Git) alongside IaC and alert definitions
- Link runbooks directly from alert annotations/descriptions — on-call engineers get the link in the page
- **Update runbooks after every incident** where the procedure was insufficient or incorrect
- Review runbooks on a maintenance schedule (monthly/quarterly)
- Retire runbooks for decommissioned services; stale runbooks are worse than none

## MTTR impact

Google SRE data: **on-call playbooks produce ~3× improvement in MTTR** compared to "winging it." Even though no playbook substitutes for smart engineers thinking on the fly, clear and thorough troubleshooting steps are highly valuable during high-stakes, time-sensitive incidents.

## Automated Runbooks

Where possible, automate runbook steps:

- **ChatOps** — trigger runbook scripts from Slack/Teams bot commands during incidents
- **Auto-remediation** — for well-understood failure modes, automate the fix entirely (e.g., auto-restart crashlooping pods, auto-block brute-force IPs)
- **Guided automation** — run diagnostic commands automatically and present results to the on-call engineer

## Related Pages

- [Alert Severity Levels](../concepts/alert-severity.md)
- [Grafana Alerting Best Practices](../sources/grafana-alerting-best-practices.md)
- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Observability](../concepts/observability.md)
