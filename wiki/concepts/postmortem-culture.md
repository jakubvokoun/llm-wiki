---
title: "Postmortem Culture"
tags: [sre, postmortem, blameless, reliability, incident-response]
sources: [sre-book-postmortem-culture.md]
updated: 2026-04-24
---

# Postmortem Culture

A postmortem is a written record of an incident: its impact, actions taken, root cause(s), and follow-up actions to prevent recurrence. A strong postmortem culture treats incidents as learning opportunities rather than failures to punish.

## Blameless Postmortems

The foundational principle: **focus on systems and processes, never on individual blame.**

- Originated in healthcare and avionics, where near-miss reporting saves lives
- Assumes all participants acted in good faith with the information they had
- Blame cultures cause underreporting — people hide incidents to avoid punishment
- The goal is to fix the system so the same information gap cannot cause the same failure again

> "You can't 'fix' people, but you can fix systems and processes." — Google SRE Book

## Postmortem Triggers

Define triggers _before_ an incident so everyone knows when one is required:

| Trigger                           | Notes                                          |
| --------------------------------- | ---------------------------------------------- |
| User-visible downtime/degradation | Above a team-defined threshold                 |
| Any data loss                     | Zero tolerance — always triggers               |
| On-call intervention              | Rollback, traffic rerouting, manual mitigation |
| Long resolution time              | Above a team-defined threshold                 |
| Monitoring failure                | Implies manual discovery — a systemic gap      |

Any stakeholder may also request a postmortem.

## Anatomy of a Good Postmortem

1. **Impact statement** — who/what was affected, for how long, at what magnitude
2. **Timeline** — chronological events from first alert to resolution
3. **Root cause(s)** — deep enough to be actionable; not "human error"
4. **Contributing factors** — conditions that made the failure more likely or worse
5. **Action items** — concrete, assigned, prioritized; filed as real bugs/tickets
6. **Lessons learned** — what worked, what didn't, what surprised us

## Review Process

**No postmortem left unreviewed.**

Review criteria:

- Key incident data collected for posterity?
- Impact assessments complete?
- Root cause sufficiently deep?
- Action plan appropriate, bugs at correct priority?
- Stakeholders informed?

After review, publish to a shared repository so the whole organization can learn.

## Culture Building

| Practice                    | Description                                                                          |
| --------------------------- | ------------------------------------------------------------------------------------ |
| **Postmortem of the Month** | Monthly newsletter feature of a well-written postmortem                              |
| **Reading Club**            | Team sessions reviewing old postmortems (months or years later) for ongoing learning |
| **Wheel of Misfortune**     | New engineers reenact a past incident; original IC attends for realism               |
| **Visible reward**          | Peer recognition, bonuses, leadership praise for good postmortem practice            |

## Common Anti-Patterns

| Anti-Pattern                            | Fix                                                                             |
| --------------------------------------- | ------------------------------------------------------------------------------- |
| "Human error" as root cause             | Ask why the human was in a position to make that error                          |
| Action items without owners or priority | Every action item must be a real ticket with an assignee                        |
| Postmortems written but never reviewed  | Schedule regular review sessions; treat unreviewed = nonexistent                |
| Blame language ("X caused the outage")  | Use system language ("The process lacked a safeguard that would have caught X") |
| Postmortems only for major outages      | Minor incidents can teach as much as major ones                                 |

## Related Pages

- [Incident Response](incident-response.md)
- [Site Reliability Engineering](site-reliability-engineering.md)
- [Troubleshooting](troubleshooting.md)
- [Runbooks](runbooks.md)
- [SRE Book Postmortem Culture](../sources/sre-book-postmortem-culture.md)
