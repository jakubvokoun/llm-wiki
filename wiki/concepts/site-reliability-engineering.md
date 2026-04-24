---
title: "Site Reliability Engineering (SRE)"
tags: [sre, devops, reliability, on-call, error-budget, postmortem, google]
sources: [sre-book-introduction.md]
updated: 2026-04-24
---

# Site Reliability Engineering (SRE)

SRE is what happens when you ask a software engineer to design an operations team. Coined at Google by Benjamin Treynor Sloss (~2003), it resolves the structural conflict between development velocity and operational stability.

## The core insight

Traditional dev/ops split creates misaligned incentives: dev wants to ship fast, ops wants no changes. SRE resolves this by:

1. Staffing operations with software engineers who automate away toil.
2. Introducing an **error budget** that both dev and SRE share — giving them a common incentive.

## The 50% ops cap

Google's canonical rule: SREs spend at most **50% of their time on operational work** (on-call, tickets, manual tasks). Exceeding this triggers a feedback loop:

- Excess ops work is redirected back to the development team.
- Dev team is motivated to build systems that don't create operational load.
- Over time, well-engineered systems become automatic (not just automated).

SRE headcount scales **sublinearly** with service size.

## Error budgets

**Error budget = 1 − SLO**

- 99.9% SLO → 0.1% budget (~8.7 hours/year)
- 99.99% SLO → 0.01% budget (~52 minutes/year)

Spend the budget on taking risks with launches. When the budget is depleted, freeze new releases. This makes outages expected and managed — not feared — and aligns SRE and dev around the same goal: maximum feature velocity within the budget.

## On-call targets

| Metric                 | Target                                                |
| ---------------------- | ----------------------------------------------------- |
| Events per 8–12h shift | Max 2 (time to handle, restore, and postmortem)       |
| Fewer than 1/shift     | Inefficient use of on-call engineer                   |
| Postmortems            | Required for all significant incidents, paging or not |

## Postmortem culture

Blame-free postmortems for all significant incidents. Non-paging incidents are especially valuable — they reveal monitoring gaps. Goal: expose faults and apply engineering, not assign blame.

## SRE core responsibilities

| Domain             | Focus                                                                            |
| ------------------ | -------------------------------------------------------------------------------- |
| Availability       | Service uptime and SLO compliance                                                |
| Latency            | Response time targets                                                            |
| Performance        | Resource efficiency and throughput                                               |
| Efficiency         | Cost-optimal provisioning                                                        |
| Change management  | Progressive rollouts, detection, rollback (70% of outages are caused by changes) |
| Monitoring         | Three outputs: alerts, tickets, logs                                             |
| Emergency response | Playbooks → ~3× MTTR improvement vs winging it                                   |
| Capacity planning  | Organic + inorganic demand forecasting; load testing                             |

## SRE vs DevOps

DevOps is a generalization of SRE principles to broader organizations and management structures. SRE is a specific implementation of DevOps with extensions: error budgets, 50% ops cap, and postmortem culture.

## Related pages

- [Error Budgets](error-budgets.md)
- [Observability](observability.md)
- [Alert Severity Levels](alert-severity.md)
- [DORA Metrics](dora-metrics.md)
- [Runbooks](runbooks.md)
- [SRE Book Introduction Source](../sources/sre-book-introduction.md)
