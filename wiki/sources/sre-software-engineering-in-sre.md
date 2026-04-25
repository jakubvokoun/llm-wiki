---
title: "SRE Book — Chapter 18: Software Engineering in SRE"
tags: [sre, software-engineering, capacity-planning, auxon, intent-based]
sources: [sre-software-engineering-in-sre.md]
updated: 2026-04-24
---

# SRE Book — Chapter 18: Software Engineering in SRE

Written by Dave Helstroom and Trisha Weir with Evan Leonard and Kurt Delimon.

## Why SREs Build Software

SRE's guiding principle: **team size should not scale directly with service growth.** Achieving linear team growth with exponential service growth requires perpetual automation and tool development.

SREs have unique advantages as tool developers:

- Deep production knowledge → design for scalability, graceful degradation, infrastructure integration
- Embedded subject-matter expertise → understand requirements without translation
- Direct relationship with fellow SREs as users → high-signal feedback, fast iteration

## Case Study: Auxon — Intent-Based Capacity Planning

### The Problem with Traditional Capacity Planning

Traditional capacity planning cycle:

1. Collect demand forecasts
2. Devise build/allocation plans
3. Review and sign off
4. Deploy and configure resources

**Brittle:** Any minor change (efficiency drop, adoption increase, delivery slippage, product decisions) requires cross-checking or rewriting the entire plan.

**Laborious:** Bin packing is NP-hard; spreadsheets don't scale; manual allocation is approximate at best; constraints are opaque by the time they reach allocators.

### Intent-Based Capacity Planning

_Specify requirements, not implementation._

Levels of intent abstraction:

1. "I want 50 cores in clusters X, Y, Z" — explicit but inflexible
2. "I want 50 cores in any 3 clusters in region YYY" — more flexible
3. "I want N+2 redundancy in each geographic region" — understandable rationale, high flexibility
4. "I want 5-nines reliability" — most abstract, maximum flexibility

Best wins typically come at level 3. With true intent captured, the system can autogenerate an optimal allocation plan when inputs change.

**Three precursors to intent:**

- **Dependencies:** Nested production dependencies constrain placement. Foo needs Bar needs Baz and Qux → all placements must be co-constrained.
- **Performance metrics:** Convert higher-level demand to lower-level resource demand (e.g., N queries of Foo → M Mbps of Bar).
- **Prioritization:** Explicit ranking of requirements enables transparent trade-offs under resource constraints.

### Auxon Architecture

Auxon represents resource requirements as a mixed-integer or linear program and solves it at scale (hundreds to thousands of parallel machines).

| Component              | Purpose                                                          |
| ---------------------- | ---------------------------------------------------------------- |
| Performance Data       | Service scaling coefficients                                     |
| Demand Forecast        | Per-service QPS/demand signal trends                             |
| Resource Supply        | Available capacity upper bounds                                  |
| Resource Pricing       | Cost objective for solver                                        |
| Intent Config          | Human-readable service definitions and relationships             |
| Config Language Engine | Translates intent config to protocol buffer optimization request |
| Auxon Solver           | Formulates + solves the linear program                           |
| Allocation Plan        | Output: which resources go where; unmet requirements listed      |

### Lessons Learned

**Approximate early, refactor later.** The "Stupid Solver" (simple heuristics) validated the vision before investing in linear programming. Solver internals were abstracted behind an interface to enable the swap.

**Design agnostically.** Not requiring customers to commit to a specific forecast tool, turnup tool, or performance data tool was key to broad adoption. "Come as you are; we'll work with what you've got."

**Target early adopters strategically.** Teams with no existing capacity planning processes are easiest first customers — they must invest configuration effort regardless. Success with them creates internal advocates.

**White-glove onboarding works.** One-on-one support for early adopters addresses automation fears and builds trust. Quantifying time savings with case studies convinces subsequent adopters.

## Building a Software Engineering Culture in SRE

### What Makes a Good SRE Software Project?

Strong signals:

- Engineers with firsthand domain experience
- Highly technical target user base (high-signal bug reports)
- Clear benefit: reduces toil, improves infrastructure, streamlines processes
- Fits organizational objectives (executive advocacy possible)

Weak signals / risks:

- Touches many moving parts at once
- All-or-nothing design (prevents iterative development)
- Overly specific to one service (won't generalize across SRE)
- Overly generic (no concrete use case, no immediate value)

### Staffing

Mix of:

- Generalists who get up to speed quickly
- Domain specialists (e.g., operations research, statistics) brought in once project is validated

SREs developing software **must remain active SREs** — on-call, production-immersed. Their production experience is the source of the product's value.

### Cultural Guidelines

1. **Clear message:** "This reduces toil and makes SRE knowledge portable."
2. **Evaluate capabilities:** What's missing? Agile coaching, product management, domain experts.
3. **Launch and iterate:** First products should target achievable goals. Six-month release rhythm builds credibility.
4. **Don't lower standards:** Code review, integration tests, production readiness reviews — same bar as product teams.

## See Also

- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
- [Toil](../concepts/toil.md)
- [Intent-Based Capacity Planning](../concepts/intent-based-capacity-planning.md)
- [Automation Hierarchy](../concepts/automation-hierarchy.md)
