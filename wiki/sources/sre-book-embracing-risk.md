---
title: "SRE Book — Chapter 3: Embracing Risk"
tags:
  [
    sre,
    site-reliability-engineering,
    google,
    error-budget,
    slo,
    risk,
    reliability,
  ]
sources: [sre-book-embracing-risk.md]
updated: 2026-04-24
---

# SRE Book — Chapter 3: Embracing Risk

**Authors:** Marc Alvidrez, Mark Roth  
**Editors:** Kavita Guliani, Carmela Quinito

The foundational SRE chapter on risk management and error budgets. Core thesis: past a certain point, increasing reliability is _worse_ for users and the organization.

## Why 100% reliability is wrong

Users on a 99% reliable smartphone can't distinguish between 99.99% and 99.999% service reliability — the user experience is dominated by less reliable components (cellular network, device, ISP). Extra reliability past the user's detection threshold has zero user value but enormous engineering cost.

**Cost is non-linear**: each increment of reliability costs progressively more. An incremental improvement in reliability may cost 100× more than the previous increment.

**Two cost dimensions:**

1. **Redundant resource cost** — extra machines, parity storage, standby capacity.
2. **Opportunity cost** — engineering time spent on reliability instead of user-visible features.

## Measuring service risk

Google's approach: use **request success rate** (proportion of successful requests), not time-based uptime. For globally distributed services, the system is always partially up somewhere, making uptime meaningless.

```
Request success rate = successful requests / total requests (rolling window)
```

Example: 99.99% daily target with 2.5M requests/day → up to 250 errors allowed per day.

**Quarterly tracking:** Set availability targets per quarter; track weekly or daily against the target.

**ISP background error rate:** Typical range is **0.01%–1%**. If a service's error rate drops below this, errors blend into the noise of the user's connection — effectively invisible to the user.

## Risk tolerance of services

### Consumer services

Work with the product team to determine:

- Required availability level
- Revenue impact of downtime (paid vs free service, enterprise vs consumer)
- Shape of failures: partial outage vs full outage have vastly different user trust implications
- Competitors' availability levels
- Other metrics beyond uptime (e.g., latency)

**Example:** Google Apps for Work (enterprise) → 99.9% external SLO with contractual penalties. YouTube (consumer, rapid-growth phase) → lower SLO to enable faster feature velocity.

**Partial vs full outage:** Leaking private data to wrong users → take the service fully down. Broken profile pictures → fix but don't take down. Failure shape matters more than failure rate.

**Cost model example:**

- 99.9% → 99.99% improvement = 0.09% additional availability
- Service revenue = $1M → improvement worth $900/year
- If the engineering cost > $900, it's not worth it.

### Infrastructure services

Multi-client infra (e.g., Bigtable storage) serves clients with conflicting needs:

- Low-latency services: want empty queues, high availability
- Batch/analytics: want maximum throughput, tolerate latency

**Solution: service tiers.** Partition infra into multiple levels of service with different cost/reliability profiles:

- Low-latency cluster: high redundancy, high cost
- Throughput cluster: runs hot, less redundancy, 10–50% of low-latency cost

Expose cost externally so clients self-select the right tier for their actual needs.

## Error budget mechanics

The error budget is the mechanism that resolves the dev/SRE tension:

1. **Product Management** defines the SLO (e.g., 99.999% of requests succeed per quarter).
2. **Monitoring system** (neutral third party) measures actual uptime.
3. **Gap = error budget** available for the quarter.
4. While budget remains: launches proceed.
5. When budget depletes: releases halted until budget recovers.

Error budget usage example: SLO = 99.999% → budget = 0.001% failure rate. An incident causing 0.0002% failures uses 20% of the quarterly budget.

**Self-policing effect:** When the budget is nearly exhausted, the dev team (not SRE) advocates for more testing or slower releases — they don't want to burn the budget and freeze their launches.

**Authority requirement:** SRE must have the authority to actually halt launches when SLO is broken for the model to work.

**Nuanced responses beyond on/off:** Slow rollouts when budget is low; only hard freeze when fully depleted.

## Key insights

1. Managing reliability = managing risk. Risk management has cost.
2. 100% is never the right target — match reliability to what users can detect and business can afford.
3. Error budgets align incentives: SRE and dev share responsibility for uptime.
4. Error budgets make outage discussions data-driven instead of political.

## Related pages

- [Error Budgets](../concepts/error-budgets.md)
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
- [SRE Book Introduction](sre-book-introduction.md)
- [SRE Book Part II Principles](sre-book-part-ii-principles.md)
- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Progressive Delivery](../concepts/progressive-delivery.md)
