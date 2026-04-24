---
title: "SRE Book — Chapter 16: Tracking Outages"
tags: [sre, outage-tracking, alerting, reliability, google]
sources: [sre-book-tracking-outages.md]
updated: 2026-04-24
---

# SRE Book — Chapter 16: Tracking Outages

Chapter by Gabe Krabbe. Part of the Google SRE Book practices section.

## Key Premise

Postmortems cover high-impact individual incidents, but they miss:

- Low-impact but frequent issues that accumulate toil
- Cross-team systemic patterns invisible at the single-service level
- Quantitative baselines for measuring reliability improvement over time

An outage tracking system fills these gaps by passively collecting and annotating all alerts.

## Google's Tooling

### Escalator

Central replicated system that tracks alert acknowledgments across all SRE teams:

- Receives copies of emails sent to on-call aliases (zero workflow change)
- If no human acknowledgment within configured interval → escalates to next destination (e.g., primary → secondary on-call)
- Transparent by design: integrates with existing monitoring without behavior change

### Outalator

Built on top of Escalator to operate at the "outage" abstraction level:

| Feature              | Description                                                                                          |
| -------------------- | ---------------------------------------------------------------------------------------------------- |
| **Interleaved view** | Time-interleaved notifications across multiple queues; no manual queue switching                     |
| **Annotations**      | Rich notes stored alongside original notification; email replies silently captured; "important" flag |
| **Grouping**         | Multiple alerts → single incident; separates "incidents/day" from "alerts/day" analysis              |
| **Tags**             | Free-form metadata with semantic prefixes (`cause:network`, `action:rollback`, `bug:76543`)          |
| **Shift handoff**    | Select outalations → generate handoff email with subjects, tags, and important annotations           |
| **Report mode**      | Weekly review format with inline expanded annotations for service lowlights                          |

## Aggregation

A single event triggers multiple alerts (network failure → all dependent services alert, plus NOC). Grouping multiple alerts into one incident:

- Prevents duplicate debugging effort across teams
- Enables accurate "incidents per day" vs "alerts per day" metrics
- Scales across teams and time in ways that per-alert emails cannot

## Tagging

Free-form tags are the Outalator's most valuable feature:

- **Hierarchical**: `cause:network:switch` vs `cause:network:cable`
- **Semantic prefixes**: `cause:`, `action:` (team-specific suggestions based on usage history)
- **Auto-linking**: `bug:76543` becomes a link to the bug tracker
- **Catch-all**: `bogus` for false positives; no predetermined list — teams find their own conventions
- Result: rich metadata enabling self-service analysis without formal process

## Analysis Layers

| Layer                   | What It Provides                                                     |
| ----------------------- | -------------------------------------------------------------------- |
| **Counting/stats**      | Incidents per week/quarter; alerts per incident; basic reporting     |
| **Comparison/trends**   | Team vs team; service vs service; over time — is this load "normal"? |
| **Semantic/cross-team** | Which infrastructure component causes most incidents across teams?   |

## Unexpected Benefits

- **Cross-team visibility**: If your service is impacted but the owning team hasn't been alerted → manually alert them
- **System-of-record uses**: Log privileged DB access; record periodic job runs; audit schema migrations
- **False positive tracking**: "bogus" tags let teams measure and reduce alert noise

## Related Pages

- [Outage Tracking](../concepts/outage-tracking.md)
- [Incident Response](../concepts/incident-response.md)
- [Postmortem Culture](../concepts/postmortem-culture.md)
- [Alert Severity Levels](../concepts/alert-severity.md)
- [Alertmanager](../concepts/alertmanager.md)
- [SRE Book Postmortem Culture](sre-book-postmortem-culture.md)
- [SRE Book Managing Incidents](sre-book-managing-incidents.md)
