---
title: "SRE Book — Part II: Principles (Overview)"
tags:
  [sre, site-reliability-engineering, google, toil, slo, monitoring, automation]
sources: [sre-book-part-ii-principles.md]
updated: 2026-04-24
---

# SRE Book — Part II: Principles (Overview)

Introduction to the Principles section of the Google SRE book. Describes the key conceptual areas that underpin SRE operations.

## Chapters covered

| Chapter                        | Core idea                                                                               |
| ------------------------------ | --------------------------------------------------------------------------------------- |
| Embracing Risk                 | Error budgets; risk assessment and management as a neutral framework                    |
| Service Level Objectives       | SLI vs SLO vs SLA distinction; finding useful metrics                                   |
| Eliminating Toil               | Toil = mundane, repetitive ops work with no enduring value; scales linearly with growth |
| Monitoring Distributed Systems | What and how to monitor; implementation-agnostic best practices                         |
| The Evolution of Automation    | SRE's automation philosophy; case studies of success and failure                        |
| Release Engineering            | Release consistency; most outages result from pushing a change                          |
| Simplicity                     | Simplicity as a quality that is hard to recapture once lost                             |

## Key concepts introduced

- **Toil**: Mundane, repetitive operational work providing no enduring value. Scales linearly with service growth. The enemy of engineering work. SRE exists to eliminate it via software.
- **SLI/SLO/SLA**: The industry conflates these; SRE disentangles them. SLIs are measurements, SLOs are targets, SLAs are agreements with consequences.
- **Error budgets**: Neutral framework for balancing reliability vs velocity (see [Embracing Risk](sre-book-embracing-risk.md)).

## Key quote

> "Taking humans out of the release process can paradoxically reduce SREs' toil while increasing system reliability." — Google SRE, "Making Push On Green a Reality"

## Related pages

- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
- [Error Budgets](../concepts/error-budgets.md)
- [Toil](../concepts/toil.md)
- [SRE Book Introduction](sre-book-introduction.md)
- [SRE Book Embracing Risk](sre-book-embracing-risk.md)
