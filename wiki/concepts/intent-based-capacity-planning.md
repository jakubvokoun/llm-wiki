---
title: "Intent-Based Capacity Planning"
tags: [sre, capacity-planning, auxon, linear-programming, resource-allocation]
sources: [sre-software-engineering-in-sre.md]
updated: 2026-04-24
---

# Intent-Based Capacity Planning

_Specify requirements, not implementation._

Intent-based capacity planning replaces manual bin-packing with programmatic encoding of a service's true requirements and constraints. The encoded intent is fed to an optimization engine that autogenerates an allocation plan.

## Traditional vs. Intent-Based

| Dimension          | Traditional                     | Intent-Based                         |
| ------------------ | ------------------------------- | ------------------------------------ |
| Representation     | "50 cores in cluster X"         | "N+2 redundancy per continent"       |
| Flexibility        | Fixed                           | High — system finds valid solutions  |
| Response to change | Manual rework                   | Re-run solver with updated inputs    |
| Optimality         | Approximate (human bin-packing) | Bounded-optimal (linear programming) |
| Transparency       | Ad hoc prioritization           | Explicit, ranked requirements        |

## Levels of Intent

From least to most abstract:

1. **Explicit:** "I want 50 cores in clusters X, Y, Z"
2. **Flexible:** "50 cores in any 3 clusters in region YYY"
3. **Rationale-driven:** "N+2 redundancy in each geographic region" ← best wins here
4. **Goal-driven:** "5-nines reliability"

Most services achieve the best wins at level 3, where flexibility is high and consequences of under-provisioning are clearly stated.

## Three Inputs to Intent

**Dependencies:** Services have nested production dependencies that constrain placement. If Foo needs Bar needs Baz, all three must be co-located within latency constraints.

**Performance metrics:** Convert higher-level demand to lower-level resource demand. E.g., N QPS of Foo generates M Mbps of Bar. Derived from load testing and production monitoring.

**Prioritization:** Explicit ranking of which requirements to sacrifice under resource constraints. Forced transparent trade-offs replace ad hoc decision-making.

## Auxon: Google's Implementation

Auxon represents all requirements as a mixed-integer or linear program and solves it at scale (hundreds to thousands of parallel machines).

Key design decisions:

- **Agnostic to tooling:** Customers don't need to switch forecast, turnup, or performance data tools to use Auxon
- **Modular solver interface:** The Stupid Solver (simple heuristics) validated the vision; the interface allowed swapping in a real LP solver later
- **Intent Config:** Human-readable, version-controlled configuration defining service intent and relationships
- **Allocation Plan output:** Which resources go where, plus a list of requirements that couldn't be satisfied (making trade-offs explicit)

## Benefits

- Bin packing quality: computational optimization beats human approximation
- Nimble response: any input change → re-run solver → new plan in minutes
- Cost savings: better bin packing = fewer over-provisioned resources
- Transparency: trade-offs are surfaced, not hidden

## See Also

- [SRE Book — Chapter 18: Software Engineering in SRE](../sources/sre-software-engineering-in-sre.md)
- [Site Reliability Engineering](site-reliability-engineering.md)
- [Toil](toil.md)
