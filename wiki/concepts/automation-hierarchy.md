---
title: "Automation Hierarchy"
tags: [sre, automation, reliability, operations]
sources: [sre-book-automation-at-google.md]
updated: 2026-04-24
---

# Automation Hierarchy

The SRE automation hierarchy describes the maturity levels of operational automation, from purely manual to fully autonomous. The goal is always to move up the hierarchy.

## The Five Levels

| Level | Description                                    | Example                                        |
| ----- | ---------------------------------------------- | ---------------------------------------------- |
| 1     | No automation — manual human action            | SRE manually fails over database master        |
| 2     | Externally maintained, system-specific         | SRE has failover script in home directory      |
| 3     | Externally maintained, generic                 | Shared generic failover script for all DBs     |
| 4     | Internally maintained, system-specific         | Database ships its own failover tooling        |
| 5     | Autonomous — self-healing without intervention | Database detects problem and fails over itself |

Level 5 is the goal. Automation replaces toil; autonomy eliminates the need for automation.

## Why Autonomy, Not Just Automation

Automation multiplies human force but still requires humans to trigger it. Autonomous systems:

- React faster than humans (essential past the threshold of manual manageability)
- Are self-repairing — necessary at scale where failures are statistically guaranteed every second
- Don't require operators to maintain their reaction skills

The highest-leverage investment is at **design time**: build systems that don't require external glue logic at all.

## Values of Automation

| Value          | Why it matters                                                                     |
| -------------- | ---------------------------------------------------------------------------------- |
| Consistency    | Humans performing a task 100× will not do it the same way each time; machines will |
| Platform       | Centralizes bug fixes; exports metrics; extensible without adding headcount        |
| Faster Repairs | Lower MTTR for common faults; earlier detection is cheaper to fix                  |
| Faster Action  | Machines react faster; humans can't keep up past a certain scale                   |
| Time Saving    | Decouples operator from operation; savings multiply across all users               |

## Design Principles for Automation

- **Ownership by the operating team** — automation maintained by a separate team loses relevance (bit rot) and creates bad incentives; the team not running automation has no incentive to build automatable systems
- **APIs and decoupling** — build systems with programmable interfaces; decouple subsystems; minimize side effects
- **Idempotency** — automation that can be safely re-run without damage is much safer
- **Rate limiting destructive operations** — empty sets or unexpected inputs should never silently operate on maximum scope
- **Expose internals** — autonomous systems must allow human introspection when they fail

## Risks of Automation at Scale

- **Catastrophic blast radius**: a bug in automation can affect far more systems than a human error (Diskerase incident: empty-set bug wiped entire CDN disk fleet)
- **Human skill atrophy**: operators who rarely perform manual actions lose proficiency; when automation fails, they can't fall back effectively
- **Bit rot**: automation maintained separately from the system it manages diverges over time as the system evolves

## Related Pages

- [Toil](toil.md)
- [Site Reliability Engineering](site-reliability-engineering.md)
- [Progressive Delivery](progressive-delivery.md)
- [CI/CD Security](cicd-security.md)
