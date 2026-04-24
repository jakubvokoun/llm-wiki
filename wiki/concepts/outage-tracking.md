---
title: "Outage Tracking"
tags: [sre, outage-tracking, alerting, reliability, incident-response]
sources: [sre-book-tracking-outages.md]
updated: 2026-04-24
---

# Outage Tracking

Outage tracking is the practice of systematically recording, annotating, and analyzing all alerts and incidents over time — beyond what individual postmortems capture. While postmortems cover high-impact events, outage tracking surfaces low-impact-but-frequent patterns and enables reliability improvement over measurable baselines.

## Why Outage Tracking

Postmortems answer "what happened in this incident?" Outage tracking answers:

- "How many alerts does this team get per on-call shift?"
- "What's the actionable/non-actionable alert ratio this quarter?"
- "Which service generates the most toil?"
- "Is this failure pattern getting better or worse over time?"

## Core Capabilities

| Capability         | Purpose                                                                                     |
| ------------------ | ------------------------------------------------------------------------------------------- |
| **Alert capture**  | Passively receive all monitoring alerts — no workflow change required                       |
| **Annotations**    | Attach notes, important flags, and email replies to individual alerts                       |
| **Grouping**       | Merge multiple alerts into one incident; separate "alert rate" from "incident rate"         |
| **Tagging**        | Free-form metadata with semantic prefixes (`cause:`, `action:`) and hierarchical namespaces |
| **Trend analysis** | Compare teams/services over time; detect normal vs abnormal load                            |
| **Shift handoff**  | Generate context-rich handoff emails from selected incidents                                |

## Alert Aggregation

A single failure event typically triggers many alerts (e.g., a network outage alerts every dependent service plus the NOC). Grouping these into one incident:

- Prevents duplicate investigation across teams
- Gives accurate incident rates (vs raw alert rates)
- Enables cross-team coordination ("your dependency caused this alert cluster")

## Tagging Best Practices

Free-form tagging with suggested prefixes beats rigid taxonomies:

- `cause:network`, `cause:network:switch`, `cause:database:replication`
- `action:rollback`, `action:reroute`
- `bogus` for false positives
- `bug:12345` for auto-links to the bug tracker

Teams develop their own vocabularies; suggestion systems surface the most-used prefixes. The flexibility produces more useful data than predetermined category lists.

## Analysis Layers

1. **Counting**: incidents/week, alerts/incident — basic reporting metrics
2. **Comparison**: team vs team, time period vs time period — is this normal?
3. **Semantic**: which shared infrastructure component causes most incidents across all teams? What's the cost/benefit of fixing it?

## Google's Implementation

- **Escalator**: central ack-tracking system; escalates if no ack within interval
- **Outalator**: outage-level abstraction on top of Escalator; all the features above plus weekly report mode

## Related Pages

- [Incident Response](incident-response.md)
- [Postmortem Culture](postmortem-culture.md)
- [Alert Severity Levels](alert-severity.md)
- [Alertmanager](alertmanager.md)
- [Runbooks](runbooks.md)
- [SRE Book Tracking Outages](../sources/sre-book-tracking-outages.md)
