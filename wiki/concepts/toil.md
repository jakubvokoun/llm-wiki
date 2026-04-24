---
title: "Toil"
tags: [sre, toil, automation, devops, reliability]
sources: [sre-book-part-ii-principles.md, sre-book-eliminating-toil.md]
updated: 2026-04-24
---

# Toil

In SRE, **toil** is defined as work tied to running a production service that has most of these properties:

| Attribute         | Description                                                                     |
| ----------------- | ------------------------------------------------------------------------------- |
| Manual            | Human hands-on time (even running a script counts)                              |
| Repetitive        | Done over and over; first/second time is NOT toil                               |
| Automatable       | A machine could do it; no essential human judgment required                     |
| Tactical          | Interrupt-driven and reactive; handling pager alerts                            |
| No enduring value | Service state unchanged after work; no permanent improvement                    |
| O(n) with growth  | Scales linearly with traffic/users; ideal service grows 10× with zero added ops |

**Not toil:**

- _Overhead_ — meetings, HR, goal-setting (administrative, not ops-tied)
- Novel problem-solving (first or second time encountering a problem)
- Grungy one-time work with lasting impact (e.g., cleaning up alerting config)

## Why Less Toil Is Better

Toil is the primary enemy of engineering productivity in SRE. If unchecked, it expands to fill 100% of time — preventing the engineering work that would reduce it.

Google's **50% ops cap**: SRE time must be ≥50% engineering, ≤50% ops (toil + on-call). On-call sets a floor of ~25–33% depending on rotation size.

**Toil is toxic in large quantities:**

- Career stagnation — no growth without project work
- Low morale, burnout, boredom
- Slows product feature velocity
- Sets bad precedent (Devs shift more ops work to SRE)
- Promotes attrition of the best engineers
- Breach of faith with new hires promised engineering work

## Engineering vs Toil vs Overhead

| Category             | Description                                       |
| -------------------- | ------------------------------------------------- |
| Software engineering | Writing/modifying code, automation, frameworks    |
| Systems engineering  | Config, monitoring, one-time lasting improvements |
| Toil                 | Repetitive manual ops work                        |
| Overhead             | Admin work (meetings, HR, peer reviews)           |

## What toil looks like

- Manually restarting failed services
- Triaging tickets that could be auto-closed
- Running the same deployment checklist by hand
- Responding to alerts that resolve themselves

## How to eliminate it

- Automate the trigger → response loop entirely
- Build self-healing systems that don't require intervention
- Implement automated rollback instead of manual rollback procedures
- Design services so they grow without proportional ops increase

## Related pages

- [Site Reliability Engineering](site-reliability-engineering.md)
- [Runbooks](runbooks.md)
- [Progressive Delivery](progressive-delivery.md)
- [SRE Book — Eliminating Toil](../sources/sre-book-eliminating-toil.md)
- [SRE Book Part II Source](../sources/sre-book-part-ii-principles.md)
