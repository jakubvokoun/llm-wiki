---
title: "SRE Book — Chapter 13: Emergency Response"
tags: [sre, incident-response, emergency, postmortem, google]
sources: [sre-book-emergency-response.md]
updated: 2026-04-24
---

# SRE Book — Chapter 13: Emergency Response

Written by Corey Adam Baye, edited by Diane Bates. Three real Google incident case studies with detailed findings.

> Things break; that's life.

A proper emergency response takes preparation and periodic, pertinent, hands-on training — not just natural ability.

## What to Do When Systems Break

1. **Don't panic.** You're a professional trained for this.
2. **Pull in more people** if overwhelmed — even page the entire company if needed.
3. **Follow the incident response process** if one exists.

## Case Study 1: Test-Induced Emergency

**What happened**: Attempt to flush hidden dependencies on one database out of 100 in a large distributed MySQL cluster. No one foresaw the blast radius.

**Impact**: Within minutes, numerous dependent services reported external and internal users unable to access key systems.

**Response**: Immediately aborted the test. Rollback of permissions change failed. Used an alternate already-tested approach to restore permissions to replicas/failovers. Reached out to developers to fix the DB application layer library. Full restoration within one hour.

**Key lessons**:

- Rollback procedures must be **tested in a test environment** before large-scale tests — the flawed rollback lengthened the outage
- Incident response process wasn't disseminated — teams didn't know to follow it
- Hidden dependencies aren't obvious even after thorough review
- Parallel restoration efforts (different teams, different approaches) shorten recovery

## Case Study 2: Change-Induced Emergency (The Config Push)

**What happened**: A config change to the abuse-protection infrastructure was pushed globally on a Friday. It triggered a crash-loop bug across the entire fleet, affecting both external and internal systems.

**Impact**: Within seconds, monitoring alerts fired. Engineers lost access to corporate network, relocating to panic rooms. Within 5 minutes, the push engineer (independently noticing corporate outage) rolled back the change. Most services recovered within 10 minutes; some with unrelated triggered bugs took up to an hour.

**What went well**:

- Monitoring detected immediately
- Out-of-band communications (CLI tools, alternative access methods) worked
- The affected system's rate-limiting throttled the crash-loop, preventing complete outage
- The push engineer's diligence in monitoring real-time channels enabled rapid rollback

**Key lessons**:

- Thorough canarying is essential **regardless of perceived risk** — an earlier canary didn't test the specific keyword/feature combination
- Alert storms during total outages are counterproductive; alerting should be designed to be useful even when "everything is down"
- Debugging tools that depend on the crashed jobs are themselves unavailable — design for self-sufficiency
- The quick rollback was **lucky** (push engineer happened to be watching) — cannot be relied upon as a process

## Case Study 3: Process-Induced Emergency (The Diskerase Incident)

**What happened**: Two consecutive turndown requests were submitted for the same server installation. A subtle bug in the automation passed an empty filter to the machine database — interpreted as "Diskerase all machines." Hard drives of installations globally were wiped.

**Impact**: Pagers everywhere firing for all such server installations. Traffic diverted within one hour. Recovery took three days for the vast majority of capacity; stragglers recovered over the next month or two.

**What went well**:

- Large installations (managed differently) were unaffected; traffic moved quickly
- Engineers quickly followed incident response protocols (which had matured considerably since the test-induced incident)
- Communication and collaboration were superb

**Root cause**: Turndown automation server lacked sanity checks. Empty filter → machine database treated it as "all machines." "Sometimes zero does mean all."

**Lessons**:

- Automation must have **explicit sanity checks** on inputs, especially empty/null values
- Reinstallation infrastructure was unable to handle thousands of simultaneous setups — don't assume the recovery path scales
- TFTP at lowest network QoS is inadequate for mass reinstallation — QoS matters for recovery traffic
- Manual process design: dividing the team into three parallel parts (one per reinstall step) was an effective improvisation

## Cross-Cutting Lessons

| Lesson                                                 | From case(s) |
| ------------------------------------------------------ | ------------ |
| Don't panic; stay professional                         | All          |
| Follow incident response process                       | 1, 2         |
| Test rollback procedures explicitly before major tests | 1            |
| Canary regardless of perceived risk                    | 2            |
| Automation needs sanity checks on empty/null inputs    | 3            |
| Design alerting to be useful even during broad outages | 2            |
| Out-of-band communication systems are essential        | 2, 3         |
| Recovery infrastructure must scale to disaster size    | 3            |
| Parallel restoration efforts shorten recovery          | 1, 3         |
| Document everything; update processes after incidents  | All          |

## Principles

### Keep a History of Outages

Publish and organize postmortems. Hold everyone accountable to following up on action items. Once you have a solid track record, extend from preventing known failures to preventing unknown ones.

### Ask "What If" Questions

What if the building power fails? What if the primary datacenter goes dark? What if someone compromises your web server? Having answers to these questions before the emergency is the difference between a practiced response and chaos.

### Encourage Proactive Testing

Theory and reality diverge. Proactive failure injection (during business hours, with your best engineers on hand) is infinitely preferable to discovering failure modes at 2 a.m.

## Related Pages

- [Incident Response](../concepts/incident-response.md)
- [Troubleshooting](../concepts/troubleshooting.md)
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
- [Runbooks](../concepts/runbooks.md)
- [Automation Hierarchy](../concepts/automation-hierarchy.md)
