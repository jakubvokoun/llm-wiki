---
title: "SRE Book — Chapter 1: Introduction"
tags:
  [
    sre,
    site-reliability-engineering,
    google,
    devops,
    error-budget,
    monitoring,
    on-call,
  ]
sources: [sre-book-introduction.md]
updated: 2026-04-24
---

# SRE Book — Chapter 1: Introduction

**Author:** Benjamin Treynor Sloss (Google)  
**Editor:** Betsy Beyer

Foundational chapter establishing why SRE exists and its core tenets. "Hope is not a strategy."

## The sysadmin problem

Traditional dev/ops split creates structural conflict:

- **Development** wants to launch features fast.
- **Operations** wants to prevent changes that cause outages.
- ~70% of outages are caused by changes in a live system.

The two groups end up in trench warfare: ops adds launch gates; dev responds with "flag flips" and "cherrypicks" to avoid those gates. The split causes miscommunication, divergent risk models, and loss of trust.

## What SRE is

> "SRE is what happens when you ask a software engineer to design an operations team." — Benjamin Treynor Sloss

Google SRE teams are staffed:

- 50–60%: standard software engineers
- 40–50%: near-SWE with unique technical skills (UNIX internals, L1–L3 networking)

What all SREs share: belief in and aptitude for building software systems to solve complex problems — including replacing manual operational work.

## The 50% ops cap

Google caps aggregate ops work (tickets, on-call, manual tasks) at **50% of SRE time**. The remaining 50% is engineering work. Enforcement:

- Measure SRE time spent on ops.
- If ops > 50%, redirect excess to development team (reassign bugs, pull devs into on-call).
- Goal: systems that are **automatic**, not just automated.

Goal is sublinear scaling: SRE headcount grows slower than service traffic.

## On-call targets

- **Max 2 events per 8–12-hour shift** — enough time to handle, restore, and write a postmortem.
- More than 2 recurring events → engineers overwhelmed, can't learn.
- Fewer than 1/shift consistently → keeping them on point is wasteful.

## Blame-free postmortem culture

Write postmortems for all significant incidents — including those that didn't page. Non-paging incidents reveal monitoring gaps. Goal: expose faults and apply engineering fixes, not assign blame.

## Error budgets

100% reliability is the wrong target for essentially everything. Users can't distinguish between 99.999% and 100% availability — other systems in the path (ISP, WiFi, power) are far less reliable.

The right reliability target is a product/business question, not a technical one:

- Error budget = 1 − SLO (e.g. 99.99% SLO → 0.01% budget = ~52 min/year)
- Spend the budget on taking risks with launches.
- Once budget is depleted: freeze new releases until it recovers.

Effect: SRE and dev teams now share the same goal — maximize feature velocity while staying within the error budget. Outages are expected and managed, not feared.

## Three kinds of monitoring output

| Output     | Urgency         | Action                                             |
| ---------- | --------------- | -------------------------------------------------- |
| **Alert**  | Immediate       | Human must act now to prevent/stop damage          |
| **Ticket** | Within days     | Human needed but system can wait                   |
| **Log**    | None (forensic) | Recorded for diagnosis; nobody reads unless needed |

Software should interpret monitoring; humans should only be notified when they need to take action.

## Emergency response — playbooks

Humans add latency. When human intervention is required, **playbooks produce ~3× improvement in MTTR** compared to "winging it." Supplement with exercises like the "Wheel of Misfortune."

## Change management — the trio

Best practices for managing 70% of outages caused by changes:

1. Progressive rollouts
2. Quick and accurate problem detection
3. Safe rollback

Removing humans from the loop avoids fatigue, familiarity bias, and inattention.

## SRE responsibilities

Availability · Latency · Performance · Efficiency · Change management · Monitoring · Emergency response · Capacity planning

## SRE vs DevOps

DevOps is a generalization of SRE principles to broader organizations. SRE can be viewed as a specific implementation of DevOps with idiosyncratic extensions (error budgets, 50% ops cap, postmortem culture).

## Related pages

- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
- [Error Budgets](../concepts/error-budgets.md)
- [Observability](../concepts/observability.md)
- [Alert Severity Levels](../concepts/alert-severity.md)
- [Runbooks](../concepts/runbooks.md)
- [DORA Metrics](../concepts/dora-metrics.md)
