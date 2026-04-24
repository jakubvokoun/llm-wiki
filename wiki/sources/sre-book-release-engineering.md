---
title: "SRE Book — Chapter 8: Release Engineering"
tags: [sre, release-engineering, builds, deployment, configuration-management]
sources: [sre-book-release-engineering.md]
updated: 2026-04-24
---

# SRE Book — Chapter 8: Release Engineering

Author: Dinah McNutt

## Key Takeaways

**Release engineering** = building and delivering software reproducibly. Core insight: reliable services require reliable release processes. Releases must be repeatable, not "unique snowflakes."

**Four philosophy principles:**

| Principle                      | Description                                                                                                |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| Self-Service Model             | Product teams control their own release processes via tooling; minimal RE involvement                      |
| High Velocity                  | Frequent releases → fewer changes per version → easier testing/debugging; "Push on Green" for green builds |
| Hermetic Builds                | Same revision + same tools = identical binary regardless of build machine; no external build-time deps     |
| Policy & Procedure Enforcement | Gated operations (code review, cherry-pick approval, deploy approval); audit trail of all changes          |

**Release process pipeline (Google's Rapid system):**

1. **Build** — Blaze: declarative targets + deps; build identifier in every binary
2. **Branch** — branch from mainline at specific revision; cherry pick bug fixes back; never merge branch→mainline
3. **Test** — continuous test on mainline; re-run on release branch (catches cherry pick interactions)
4. **Package** — MPM (Midas Package Manager): hash-versioned, signed, labeled (dev/canary/production)
5. **Deploy** — Rapid for simple deploys; Sisyphus for complex rollouts (progressive, geographic expansion)

**Configuration management patterns:**

| Pattern                    | When to use                                               | Trade-off                                   |
| -------------------------- | --------------------------------------------------------- | ------------------------------------------- |
| Mainline config            | Simple; decoupled from binary                             | Running config can drift from checked-in    |
| Config bundled with binary | Config rarely changes or changes each release             | Tight coupling; one package to deploy       |
| Config as separate MPM pkg | Config changes independently of binary; hermetic snapshot | Two packages; coordinate with labels        |
| External store (Chubby/BT) | Config must change dynamically while binary runs          | Runtime complexity; availability dependency |

**Cherry picking:** Build at original revision + specific post-branch commits; build tools also versioned so compiler version matches original build.

**Canary → progressive rollout pattern:** Development → canary (few jobs) → 1 cluster → exponential expansion → all clusters. Risk profile of the service determines the rollout pace.

## Key Lessons

- Release engineering is best started at the **beginning** of a project — retrofitting is expensive
- Teams should explicitly budget for release engineering resources
- Developers, SREs, and REs must collaborate; devs should not "throw results over the fence"
- Automation should be self-service so REs don't become a bottleneck

## Related Pages

- [Release Engineering](../concepts/release-engineering.md)
- [Progressive Delivery](../concepts/progressive-delivery.md)
- [Continuous Integration](../concepts/continuous-integration.md)
- [Automation Hierarchy](../concepts/automation-hierarchy.md)
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
