---
title: "SRE Book — Chapter 15: Postmortem Culture: Learning from Failure"
tags: [sre, postmortem, blameless, reliability, google]
sources: [sre-book-postmortem-culture.md]
updated: 2026-04-24
---

# SRE Book — Chapter 15: Postmortem Culture: Learning from Failure

Chapter by John Lunney and Sue Lueder. Part of the Google SRE Book practices section.

> The cost of failure is education. — Devin Carraway

## Definition

A **postmortem** is a written record of an incident covering: its impact, the actions taken to mitigate or resolve it, the root cause(s), and the follow-up actions to prevent recurrence.

## When to Write a Postmortem

Define triggers _before_ an incident. Common Google triggers:

- User-visible downtime or degradation beyond a threshold
- Any data loss
- On-call engineer intervention (rollback, traffic rerouting, etc.)
- Resolution time above a threshold
- Monitoring failure (implies manual discovery)

Any stakeholder may also request a postmortem for an event.

## Blameless Postmortems

The core philosophy: **focus on systems and processes, not people.**

- Assumes everyone had good intentions and did the right thing with the information they had
- Blame cultures cause underreporting: people hide issues to avoid punishment
- Originated in healthcare and avionics, where mistakes can be fatal
- "You can't 'fix' people, but you can fix systems and processes"

| Blaming                                                       | Blameless                                                                                        |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| "We need to rewrite it! I'm tired of being paged every week!" | "A rewrite could prevent these pages; the maintenance manual is very long and hard to train on." |

## Collaboration and Review

**Tooling requirements:**

- Real-time collaboration (rapid data collection)
- Open commenting/annotation (crowdsourced solutions)
- Email notifications (loop in stakeholders)

**Review criteria:**

- Was key incident data collected for posterity?
- Are impact assessments complete?
- Was root cause analysis sufficiently deep?
- Is the action plan appropriate with bugs at correct priority?
- Were relevant stakeholders informed?

**Best practice: No postmortem left unreviewed.** Regular review sessions close discussions, capture ideas, and finalize action items. Reviewed postmortems go into a shared repository for organization-wide learning.

## Culture Building Activities

| Activity                    | Description                                                                                       |
| --------------------------- | ------------------------------------------------------------------------------------------------- |
| **Postmortem of the Month** | Monthly newsletter highlighting a well-written postmortem to the whole org                        |
| **Postmortem Reading Club** | Team-hosted sessions reviewing old incidents (months or years old); open dialogue                 |
| **Wheel of Misfortune**     | New SREs reenact a past postmortem; original incident commander attends to make it realistic      |
| **Social/peer recognition** | Peer bonuses and visible leadership recognition for good postmortem culture and incident handling |

## Introducing Postmortem Culture

Challenges and strategies:

- **Ease in**: trial with several successful postmortems to prove value
- **Reward publicly**: celebrate good postmortem practice through social recognition and performance management
- **Leadership participation**: senior management and founders visibly endorsing the culture

## Organizational Scale

At Google scale, automated tooling aggregates postmortems for trend analysis across products (YouTube, Gmail, Maps, Cloud, etc.). Future work: ML to predict weaknesses, facilitate real-time investigation, reduce duplicate incidents.

## Related Pages

- [Postmortem Culture](../concepts/postmortem-culture.md)
- [Incident Response](../concepts/incident-response.md)
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
- [SRE Book Managing Incidents](sre-book-managing-incidents.md)
- [SRE Book Emergency Response](sre-book-emergency-response.md)
