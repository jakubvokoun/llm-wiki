---
title: "Error Budgets"
tags: [sre, error-budget, slo, reliability, devops, google]
sources: [sre-book-introduction.md, sre-book-embracing-risk.md]
updated: 2026-04-24
---

# Error Budgets

An error budget is the allowed amount of unreliability for a service over a given period, defined as:

**Error budget = 1 − SLO**

| SLO     | Budget per year | Budget per month |
| ------- | --------------- | ---------------- |
| 99%     | 3.65 days       | 7.2 hours        |
| 99.9%   | 8.76 hours      | 43.8 minutes     |
| 99.99%  | 52.6 minutes    | 4.4 minutes      |
| 99.999% | 5.26 minutes    | 26 seconds       |

## Why 100% is the wrong target

No user can distinguish between 99.999% and 100% availability. Other systems in the user's path (ISP, WiFi, device, power grid) are collectively far less than 99.999% available. The marginal difference gets lost in the noise — the effort required to close that gap is not worth it.

## What makes a good SLO target

The right target is a **product and business question**, not a technical one:

- What availability level will users be satisfied with, given how they use the product?
- What alternatives exist if users are dissatisfied?
- How does usage change at different availability levels?

## How error budgets resolve dev-SRE conflict

| Without error budget         | With error budget                                       |
| ---------------------------- | ------------------------------------------------------- |
| Dev wants to ship fast       | Both teams maximize feature velocity                    |
| SRE wants zero outages       | SRE goal shifts from "zero outages" to "stay in budget" |
| Conflict over release gating | Shared incentive: spend budget on risk, not exceed it   |

Once the budget is depleted, new feature releases are frozen until it recovers. This gives the development team a direct incentive to build reliable systems.

## Spending the budget

Tactics that spend budget wisely:

- **Phased rollouts** — deploy to a fraction of users first
- **1% experiments** — test changes on tiny traffic slice
- **Canary deployments** — watch the canary before full rollout

Outages become expected parts of the innovation process — managed and learned from, not feared.

## Budget tracking

Track budget consumption rate. If budget is burning faster than expected, freeze launches until the system stabilizes or the error rate drops.

## Implementation mechanics (Google practice)

1. **Product Management** defines the SLO per quarter.
2. **Monitoring system** (neutral third party) measures actual performance.
3. **Gap = error budget** for the quarter.
4. Releases proceed while budget remains.
5. Releases halted when budget is depleted — until it recovers.

**Authority requirement:** SRE must have actual authority to halt launches when SLO is broken, otherwise the model collapses into politics.

**Self-policing effect:** When budget is nearly exhausted, the dev team advocates for more testing and slower releases — they don't want to freeze their own launches.

**Nuanced responses:** Full freeze is a last resort. When budget is low: slow rollouts, increase canary duration, defer riskier changes.

## Measuring availability: request success rate

For globally distributed services, time-based uptime is misleading (the system is always partially up somewhere). Use **request success rate** over a rolling window:

```
availability = successful requests / total requests
```

Example: 99.99% daily target with 2.5M requests/day → at most 250 errors allowed.

**ISP background error rate:** 0.01%–1%. When service error rate drops below this floor, errors are indistinguishable from connection noise — effectively invisible to users. This is a useful lower bound when setting SLOs.

## Setting the right SLO

A product/business question, not a technical one:

- What availability level will users be satisfied with?
- Does this service tie to revenue (directly or via customer SLAs)?
- Is it paid or free? Consumer or enterprise?
- What do competitors provide?
- What are the costs of reaching one more nine?

**Cost model:** Improvement from 99.9% → 99.99% = 0.09% additional availability. If service revenue is $1M, improvement is worth ~$900/year. Engineering cost to achieve it must be below $900 to be worthwhile.

## Related pages

- [Site Reliability Engineering](site-reliability-engineering.md)
- [Progressive Delivery](progressive-delivery.md)
- [DORA Metrics](dora-metrics.md)
- [SRE Book Introduction Source](../sources/sre-book-introduction.md)
- [SRE Book Embracing Risk Source](../sources/sre-book-embracing-risk.md)
