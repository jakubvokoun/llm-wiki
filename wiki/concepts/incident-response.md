---
title: "Incident Response"
tags: [sre, incident-response, emergency, on-call, reliability, google]
sources:
  [
    sre-book-emergency-response.md,
    sre-book-effective-troubleshooting.md,
    sre-book-managing-incidents.md,
  ]
updated: 2026-04-24
---

# Incident Response

Incident response is how an organization responds to unplanned degradation or outage of a system. Effective response is a learned skill that requires preparation, process, and practice — not just technical expertise.

## Immediate Response: Don't Panic

1. **Don't panic.** You're a professional trained for this.
2. **Assess severity.** Not every incident is a global all-hands-on-deck emergency.
3. **Follow the incident response process.** If one exists, use it.
4. **Pull in more people** if needed — even page the whole company for severe incidents.

## Core Priority: Stop the Bleeding

> Your first response in a major outage may be to start troubleshooting and try to find a root cause as quickly as possible. **Ignore that instinct.**

Make the system work as well as it can under the circumstances:

| Mitigation                                        | When to Apply                        |
| ------------------------------------------------- | ------------------------------------ |
| Traffic diversion (broken cluster → working ones) | Partial outage; redundancy available |
| Wholesale traffic drop                            | To prevent cascading failure         |
| Subsystem disabling                               | Lighten load; graceful degradation   |
| Feature flag rollback                             | When a recent change is suspected    |

Preserve evidence (logs, traces) for root-cause analysis — but don't let preservation delay mitigation.

## The Incident Lifecycle

1. **Detection**: Monitoring alert fires or user report received
2. **Triage**: Assess scope; activate appropriate response level
3. **Mitigation**: Stop the bleeding; restore service at degraded quality if needed
4. **Investigation**: Examine metrics, logs, traces; form and test hypotheses
5. **Resolution**: Fix root cause (or confirm mitigation is sufficient for now)
6. **Postmortem**: Document what happened, why, how fixed, and how to prevent recurrence

## When to Declare an Incident

Declare early — cheaper to de-escalate than to retroactively impose structure. Declare if any of the following is true:

- You need a second team to fix it
- The outage is visible to customers
- The issue is unsolved after one hour of focused analysis

## Incident Command System (ICS)

Google models incident management on the **Incident Command System** — a framework for recursive separation of responsibilities. Each role-holder has full autonomy within their domain; the IC holds all undelegated roles.

| Role                   | Responsibility                                                                              |
| ---------------------- | ------------------------------------------------------------------------------------------- |
| **Incident Commander** | Holds high-level state; structures task force; delegates roles; removes roadblocks          |
| **Ops Lead**           | _Only_ group allowed to modify the system during an incident                                |
| **Communications**     | Public face; periodic updates to team + stakeholders; keeps live incident doc accurate      |
| **Planning**           | Longer-horizon support: bugs, handoffs, dinner, tracking system divergence for later revert |

### Recognized Command Post

Teams need a known interaction point — War Room for co-located teams, IRC/chat for distributed. A persistent chat log is invaluable for postmortem analysis.

### Live Incident State Document

The IC's most important artifact. Must be concurrently editable (Google Docs). Template-driven; most important info at top; retained for postmortem.

### Handoff

At shift change, outgoing IC must explicitly state "You're now the incident commander, okay?" and wait for acknowledgment before leaving. Communicate the handoff to all responders.

## Process and Communication

### Incident Command

Designate a clear **incident commander** (IC) to coordinate, communicate, and track state. The IC's job is to manage the incident, not necessarily fix it.

### Shared Communication

Use a shared incident channel (Slack, chat, bridge) so everyone involved has the same information. Use out-of-band communication systems (CLI tools, backup networks) in case your primary systems are affected.

### Documentation

Keep a running log of hypotheses tested, changes made (with timestamps), and results. This becomes the raw material for the postmortem and prevents revisiting dead ends.

## What Good Response Looks Like (Google SRE Case Studies)

### Test-Induced Emergency

- Immediately aborted the test when unexpected impact materialized
- Used parallel restoration paths (replica permissions + dev library fix simultaneously)
- Full restoration within one hour despite failed rollback

### Change-Induced Emergency

- Monitoring detected within seconds
- Out-of-band CLI tools enabled rollback even when standard interfaces were down
- Push engineer's diligence in monitoring comms channels enabled 5-minute rollback

### Process-Induced Emergency (Diskerase)

- Disabled all automation to prevent further damage
- Team divided into three parallel groups (one per recovery step)
- Incident management protocols (matured since a previous incident) worked well

## Common Anti-Patterns

| Anti-Pattern                                            | What to Do Instead                                              |
| ------------------------------------------------------- | --------------------------------------------------------------- |
| Immediately hunting root cause                          | Stop the bleeding first; root cause can wait                    |
| Not following the incident process                      | Trust the process; it exists for a reason                       |
| Untested rollback procedures                            | Test rollback before you need it                                |
| Assuming canarying is sufficient for "low-risk" changes | Canary regardless of perceived risk                             |
| Automation without sanity checks                        | Explicit validation on empty/null inputs; "zero might mean all" |
| Alert storms during broad outages                       | Design alerting to be useful even when most things are down     |
| Debugging tools that depend on the downed services      | Maintain standalone tools and out-of-band access                |

## Learning from Incidents

- **Blameless postmortems**: focus on system and process failures, not individual blame
- **Publish and organize**: every team should be able to learn from every incident
- **Follow up on action items**: hold teams accountable
- **Ask "what if" questions**: proactively test improbable but catastrophic scenarios
- **Proactive failure injection**: Chaos Engineering mindset — discover failure modes during business hours, not at 2 a.m.

## Related Pages

- [Troubleshooting](troubleshooting.md)
- [Site Reliability Engineering](site-reliability-engineering.md)
- [Runbooks](runbooks.md)
- [Toil](toil.md)
- [Automation Hierarchy](automation-hierarchy.md)
- [SRE Book Emergency Response](../sources/sre-book-emergency-response.md)
- [SRE Book Effective Troubleshooting](../sources/sre-book-effective-troubleshooting.md)
- [SRE Book Managing Incidents](../sources/sre-book-managing-incidents.md)
