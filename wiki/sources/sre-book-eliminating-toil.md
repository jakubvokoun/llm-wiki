---
title: "SRE Book — Chapter 5: Eliminating Toil"
tags: [sre, toil, automation, reliability, engineering]
sources: [sre-book-eliminating-toil.md]
updated: 2026-04-24
---

# SRE Book — Chapter 5: Eliminating Toil

Author: Vivek Rau

> If a human operator needs to touch your system during normal operations, you have a bug. — Carla Geisser, Google SRE

## Key Takeaways

**Toil definition:** Work tied to running a production service that is:

| Attribute         | Description                                                                     |
| ----------------- | ------------------------------------------------------------------------------- |
| Manual            | Human hands-on time (even running a script counts)                              |
| Repetitive        | Done over and over; first/second time is not toil                               |
| Automatable       | A machine could do it as well; no essential human judgment                      |
| Tactical          | Interrupt-driven, reactive; handling pager alerts                               |
| No enduring value | Service state unchanged after work is done                                      |
| O(n) with growth  | Scales linearly with traffic/users; ideal service grows 10× with zero added ops |

**Not toil:**

- _Overhead_ — meetings, HR, goal-setting (administrative, not ops)
- Novel problem-solving (first/second time)
- Grungy work with lasting impact (e.g., cleaning up alerting config)

**50% engineering rule:** SRE time must be ≥50% engineering, ≤50% ops (toil + on-call). On-call floor is ~25–33% depending on rotation size (2 weeks in 6–8 person rotation).

**Engineering categories:**

- _Software engineering_ — writing/modifying code, automation, frameworks
- _Systems engineering_ — config, monitoring setup, architecture consulting (one-time lasting improvements)
- _Toil_ — repetitive manual ops
- _Overhead_ — admin work

**Toil is toxic in large quantities:**

- Career stagnation — no growth without project work
- Low morale, burnout, boredom
- Slows feature velocity
- Sets bad precedent (Devs shift more operational work to SRE)
- Promotes attrition of best engineers
- Breach of faith with new hires promised engineering work

**Measurement:** Google SRE average ~33% toil (well under 50% cap). Outliers range 0–80%. Excessive individual toil signals uneven load distribution or blocked engineering opportunities.

## Related Pages

- [Toil](../concepts/toil.md)
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
- [Runbooks](../concepts/runbooks.md)
