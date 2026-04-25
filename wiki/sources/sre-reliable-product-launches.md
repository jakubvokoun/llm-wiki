---
title: "SRE Book — Chapter 27: Reliable Product Launches at Scale"
tags: [sre, launches, reliability, launch-coordination, feature-flags]
sources: [sre-reliable-product-launches.md]
updated: 2026-04-25
---

# SRE Book — Chapter 27: Reliable Product Launches at Scale

Written by Rhandeev Singh and Sebastian Kirsch.

Google performs up to 70 launches per week. SRE's role is enabling rapid change without compromising site stability. This chapter describes Launch Coordination Engineering (LCE), the team created to address this challenge.

## Key Takeaways

### Launch Coordination Engineering

A dedicated consulting team within SRE, staffed by software and systems engineers with strong communication/leadership skills. Created full-time in 2004. In 3.5 years at 5 engineers average: ~1,500 launches processed.

LCE responsibilities:

- Audit products/services for compliance with reliability standards
- Act as liaison between teams
- Drive technical aspects (maintain momentum)
- Act as gatekeepers (sign off on "safe" launches)
- Educate developers on best practices

LCE advantages:

- **Breadth of experience:** Active across all product areas; excellent knowledge transfer vehicles
- **Cross-functional perspective:** Holistic view spanning SRE, development, product management
- **Objectivity:** Nonpartisan advisor balancing stakeholders

### Criteria for a Good Launch Process

Lightweight, Robust, Thorough, Scalable, Adaptable. These are in tension. Balancing tactics:

- Simplicity: get the basics right, don't plan for every eventuality
- High touch: experienced engineers customize for each launch
- Fast common paths: simplified process for repeatable launch classes

Engineers sidestep burdensome processes—especially in crunch mode. LCE must optimize continuously.

### The Launch Checklist

Checklist items must be substantiated by a previous launch disaster. Every instruction must be concrete, practical, and reasonable.

Key checklist themes:

- **Architecture and dependencies:** Request flow; latency requirements; isolate user-facing from non-user-facing requests; validate request volume assumptions (1 page view → many requests)
- **Integration:** DNS, load balancers, monitoring setup
- **Capacity planning:** Launch spikes up to 15× estimates; N+2 replica planning; capacity has long lead times
- **Failure modes:** SPOF analysis; dependency unavailability; DoS; degraded mode if dependency fails
- **Client behavior:** Auto-save/sync/heartbeat → exponential backoff + jitter on failure
- **Processes and automation:** Document all manual processes; automate build/release; minimize human single points of failure
- **External dependencies:** Third-party code, data, services; contingency for vendor outages
- **Rollout planning:** Contingency measures for hard deadlines (conference keynote, press release)

The checklist drives convergence on common infrastructure—replacing custom solutions with hardened internal systems.

### Selected Techniques

**Gradual and staged rollouts:**

- Canary → single datacenter → global (with observation periods at each stage)
- Tools for automated changes implement canarying internally; auto-rollback on validation failure
- Even mobile app updates use gradual rollout (subset of installs → 100%)
- Invite systems rate-limit signups for gradual ramp

**Feature flag frameworks:**

- Roll out many changes in parallel, each to a subset (1–10% of users/servers/entities)
- Automatically handle failure of new code paths without affecting users
- Independently revert each change immediately
- Two classes: UI improvements (HTTP payload rewriter with cookie-based scoping); server-side/business logic (proxy/reroute requests by user ID or entity ID)
- **Dormant functionality:** Host new code in the client before activation → launch = config change, not new binary; abort = switch feature off

**Abusive client behavior:**

- Rate misjudgment: 60s vs 600s sync = 10× load
- Thundering herd: 2 a.m. sync causes huge spike at exactly 2 a.m. → randomize timing
- Retry synchronization: brief spike → synchronized retries at 1s, 2s, 4s → repeated spikes → exponential backoff + jitter
- Server-side client control: push config files to clients to adjust parameters (sync rate, retry behavior) and enable/disable features

**Overload behavior and load tests:**

- Services are rarely linear with load; they may have a breakdown point
- Debug logging example: logging backend errors cost more CPU than serving normally → as overload increased, more logging → more overload → total halt (similar to GC thrashing)
- Load tests required for most launches; both gradual ramp and impulse patterns

### Problems LCE Couldn't Solve

- **Scalability changes:** 2-orders-of-magnitude growth requires complete rearchitecting
- **Growing operational load:** Noisiness, complexity, and overhead grow over time without active effort (SRE goal: keep ops work <50%)
- **Infrastructure churn:** Services must constantly adapt to infrastructure changes; solution: infrastructure engineers automate client migrations when deprecating features

## Related Concepts

- [Launch Coordination](../concepts/launch-coordination.md) — full concept page
- [Progressive Delivery](../concepts/progressive-delivery.md) — gradual rollouts, canary deployments, feature flags
- [Overload Protection](../concepts/overload-protection.md) — client behavior, load shedding, load tests
- [Cascading Failures](../concepts/cascading-failures.md) — overload behavior at launch
