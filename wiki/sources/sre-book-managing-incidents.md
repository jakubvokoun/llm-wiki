---
title: "SRE Book — Chapter 14: Managing Incidents"
tags: [sre, incident-management, incident-command, reliability, google]
sources: [sre-book-managing-incidents.md]
updated: 2026-04-24
---

# SRE Book — Chapter 14: Managing Incidents

Chapter by Andrew Stribblehill. Part of the Google SRE Book practices section.

## Key Takeaways

Effective incident management is a structured discipline, not improvisation. Google's approach is modeled on the **Incident Command System (ICS)**, a framework known for clarity and scalability.

## Anatomy of an Unmanaged Incident

The chapter opens with a war story: a cascading datacenter failure made catastrophic by three failure modes:

| Failure Mode              | Description                                                                                      |
| ------------------------- | ------------------------------------------------------------------------------------------------ |
| **Sharp technical focus** | On-call engineer too deep in debugging to coordinate; no one owned the big picture               |
| **Poor communication**    | Nobody knew what others were doing; business leaders angry, engineers duplicating work           |
| **Freelancing**           | Well-intentioned engineer deployed an untested fix without coordination → system died completely |

## Incident Command System Roles

Recursive separation of responsibilities is the core principle. Each role-holder has full autonomy within their domain. A person holds all undelegated roles.

| Role                   | Responsibility                                                                              |
| ---------------------- | ------------------------------------------------------------------------------------------- |
| **Incident Commander** | Holds high-level state; structures response task force; delegates roles; removes roadblocks |
| **Ops Lead**           | Only group modifying the system; executes operational changes under IC direction            |
| **Communications**     | Public face; periodic email updates to team + stakeholders; keeps incident doc accurate     |
| **Planning**           | Longer-horizon support: bugs, dinner, handoffs, tracking system divergence for later revert |

## Recognized Command Post

Incident teams need a known interaction point:

- **War Room**: physical colocation for large incidents
- **IRC / chat**: Google preferred IRC — reliable, geographically distributed, bot-loggable; invaluable for postmortem analysis

## Live Incident State Document

The IC's most important artifact. Requirements:

- Concurrently editable (Google Docs / Sites)
- Messy is fine; functional is mandatory
- Template-driven; most important info at top
- Retained for postmortem and meta-analysis

## Clear Live Handoff

At shift change:

1. Phone/video call with incoming IC
2. Outgoing IC explicitly states: "You're now the incident commander, okay?"
3. Wait for firm acknowledgment before leaving
4. Communicate handoff to all responders

## When to Declare an Incident

Declare early — it's cheaper to de-escalate than to retroactively impose structure:

- Do you need a second team to fix it?
- Is the outage visible to customers?
- Has the issue persisted unsolved for an hour?

## Best Practices

| Practice                  | Meaning                                                                |
| ------------------------- | ---------------------------------------------------------------------- |
| **Prioritize**            | Stop the bleeding → restore service → preserve evidence                |
| **Prepare**               | Document procedures in advance with incident participants              |
| **Trust**                 | Full autonomy within assigned roles; no second-guessing                |
| **Introspect**            | Monitor your own emotional state; request support if overwhelmed       |
| **Consider alternatives** | Periodically re-evaluate your current approach                         |
| **Practice**              | Use the framework routinely (change management, DR testing, role-play) |
| **Rotate roles**          | Everyone should know every role                                        |

## Related Pages

- [Incident Response](../concepts/incident-response.md)
- [Service Reliability Hierarchy](../concepts/service-reliability-hierarchy.md)
- [Troubleshooting](../concepts/troubleshooting.md)
- [Runbooks](../concepts/runbooks.md)
- [SRE Book Emergency Response](sre-book-emergency-response.md)
