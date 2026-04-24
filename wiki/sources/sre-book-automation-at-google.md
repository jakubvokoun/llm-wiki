---
title: "SRE Book — Chapter 7: The Evolution of Automation at Google"
tags: [sre, automation, reliability, operations, platform]
sources: [sre-book-automation-at-google.md]
updated: 2026-04-24
---

# SRE Book — Chapter 7: The Evolution of Automation at Google

Authors: Niall Murphy, John Looney, Michael Kacirek

## Key Takeaways

**Automation is a force multiplier, not a panacea.** The best outcome is a system that requires no automation at all — designed to be autonomous. Thoughtless automation creates as many problems as it solves.

**Five values of automation:**

| Value          | Description                                                                         |
| -------------- | ----------------------------------------------------------------------------------- |
| Consistency    | Humans performing a task 100× will not do it the same way each time; machines will  |
| Platform       | Centralizes bug fixes; exports metrics; extensible; scales without staffing         |
| Faster Repairs | Automated fault resolution → lower MTTR; earlier problem detection is cheaper       |
| Faster Action  | Machines react faster than humans; essential past threshold of manual manageability |
| Time Saving    | Decouples operator from operation; savings multiply across all users of automation  |

**Hierarchy of automation classes (lowest to highest):**

1. No automation — manual human action
2. Externally maintained, system-specific automation (SRE's home-dir script)
3. Externally maintained, generic automation (shared failover script)
4. Internally maintained, system-specific automation (service ships its own failover)
5. Autonomous systems — detect problems and self-heal without human intervention

Goal: always move up the hierarchy. SRE hates manual operations; the ideal is self-healing systems.

**MySQL on Borg (case study):** Automated failover ("Decider") brought 95th-percentile failover time to <30 seconds. Ops time dropped 95%; hardware utilization improved enough to free 60% of machines. Evolution: manual 30–90 min failover → Borg (tasks move weekly) → forced full automation → autonomous.

**Cluster turnup (case study — pitfalls of specialization):**

- Shell scripts → brittle, bit rot, don't scale
- Prodtest: Python unit tests on real services — detect misconfigurations; dependency-chain testing
- Idempotent fix scripts: tests paired with automated fixes (run every 15 min safely)
- Separate "turnup team" created bad incentives: lost domain expertise, automation not maintained, no incentive for automation-friendly designs
- Final model: **Service-Oriented** — each service team owns Admin Server with turnup/turndown RPCs; automation sends RPCs when cluster is network-ready

**Borg:** Moved from machine-centric automation to cluster-as-resource management. Enabled continuous OS upgrades, machine lifecycle management with zero SRE effort. Made cluster management autonomous rather than automated.

**Risks of automation at scale:**

- _Diskerase incident_: bug in decommission automation interpreted empty set of machines as "all machines" → wiped disks on entire CDN. Lessons: rate-limit destructive operations, make workflows idempotent, add sanity checks before acting on empty sets.
- Human operator skill atrophy: when automation handles daily operations, humans lose proficiency. When automation fails, they can't fall back effectively.

**Design recommendations:**

- Invest in automation early: even at small scale, consistency and time savings matter
- Build APIs; decouple subsystems; minimize side effects — these enable autonomous behavior
- Automation must be owned by the teams whose systems it manages (not a separate turnup team)
- The highest-leverage approach is at **design time**: design systems that don't need external glue logic

## Related Pages

- [Automation Hierarchy](../concepts/automation-hierarchy.md)
- [Toil](../concepts/toil.md)
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
- [Progressive Delivery](../concepts/progressive-delivery.md)
