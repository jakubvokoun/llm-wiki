---
title: "Launch Coordination"
tags: [sre, launches, reliability, launch-coordination, checklists]
sources: [sre-reliable-product-launches.md]
updated: 2026-04-25
---

# Launch Coordination

Launch coordination is the practice of systematically ensuring reliable, reproducible product and feature launches at scale. Google formalized this as **Launch Coordination Engineering (LCE)**, a dedicated consulting team within SRE.

## Why Launch Coordination

Internet companies launch at far higher rates than traditional companies (Google: up to 70/week). Each launch is an opportunity for reliability failures. Without systematic process:

- Novice engineers repeat mistakes of predecessors
- Knowledge is not transferred between teams
- Reliability suffers under time pressure

Good software engineers are experts at coding and design but may be unfamiliar with the challenges of launching to millions of users while minimizing outages.

## Launch Coordination Engineering (LCE)

A cross-product SRE team with deep product breadth + cross-functional perspective + objectivity as nonpartisan advisors.

Responsibilities:

- Audit products for compliance with reliability standards
- Act as liaison between SRE, development, product management, marketing
- Drive technical aspects of the launch
- Act as gatekeepers, sign off on "safe" launches
- Educate developers; transfer knowledge across products

## Good Launch Process Criteria

| Criterion   | Description                                    |
| ----------- | ---------------------------------------------- |
| Lightweight | Easy on developers                             |
| Robust      | Catches obvious errors                         |
| Thorough    | Consistent and reproducible                    |
| Scalable    | Works for many simple + fewer complex launches |
| Adaptable   | Works for common and novel launch types        |

Balance tactics: simplicity (don't plan for every eventuality), high-touch customization per launch, fast common paths for repeatable launch classes.

## Launch Checklist Themes

Items must be substantiated by previous launch disasters. Every instruction must be concrete and actionable.

**Architecture and dependencies:** Request flow, latency requirements, dependency inventory (used for capacity planning)

**Integration:** DNS setup, load balancer configuration, monitoring

**Capacity planning:** Launch spikes up to 15× initial estimates; public interest is notoriously hard to predict; N+2 replica planning; long lead times for datacenter/network resources

**Failure modes:** SPOF analysis; dependency unavailability at startup vs. runtime; DoS protection; degraded mode design

**Client behavior:** Auto-save/sync/heartbeat → exponential backoff + jitter; server-side control of client parameters

**Processes and automation:** Document all manual processes; automate build/release; minimize human single points of failure

**External dependencies:** Third-party code/data/services; contingency for vendor outages; migration strategies

**Rollout planning:** Sequence and dependencies between steps; hard deadline contingency measures

## Driving Convergence via Checklist

Checklist items that recommend existing shared infrastructure instead of custom solutions:

- Replace 20 lines about rate limiting requirements with "use system X"
- Concentrate engineering effort in hardened common infrastructure
- Enables knowledge transfer between services

LCEs are uniquely positioned to identify simplification opportunities—they see which checklist sections cause the most struggle across all product areas.

## Launching the Unexpected

New product spaces (e.g., first Android launch) require creating new checklist sections from scratch. Process:

1. Engage domain experts to identify applicable and inapplicable existing checklist items
2. Identify where new items are needed
3. Keep the _intent_ of each question in mind—don't mechanically apply questions that don't fit the design
4. Return to abstract first principles of safe launches; respecialize to concrete guidance

## What LCE Doesn't Solve

LCE addresses launch reliability, not long-term operational challenges:

- **Scalability changes:** 100× growth often requires complete rearchitecting
- **Growing operational load:** Without active effort, ops work grows until it consumes all engineering time
- **Infrastructure churn:** Services must constantly adapt to infrastructure changes; requires automated migration tooling from infrastructure teams

## Sources

- [SRE Book Ch. 27: Reliable Product Launches at Scale](../sources/sre-reliable-product-launches.md)
- [Progressive Delivery](../concepts/progressive-delivery.md) — gradual rollouts and feature flags
