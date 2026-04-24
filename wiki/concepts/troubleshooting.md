---
title: "Troubleshooting"
tags: [sre, troubleshooting, debugging, incident-response, reliability]
sources: [sre-book-effective-troubleshooting.md]
updated: 2026-04-24
---

# Troubleshooting

Troubleshooting is a learnable, teachable skill — not an innate ability. It requires two things: a generic troubleshooting process and system-specific knowledge. Knowledge of the system limits effectiveness more than process does for new SREs.

## The Process (Hypothetico-Deductive Method)

1. **Problem Report**: Expected behavior + actual behavior + reproduction steps
2. **Triage**: Assess severity; prioritize stopping the bleeding over root-causing
3. **Examine**: Gather data (metrics, logs, traces, state endpoints)
4. **Diagnose**: Form hypotheses; use divide-and-conquer
5. **Test and Treat**: Experiment to confirm/rule out hypotheses
6. **Cure**: Fix; write postmortem

## Triage First: Stop the Bleeding

> Your first instinct in a major outage is to find root cause ASAP. **Ignore that instinct.**

Priority: make the system work as well as it can under the circumstances. Mitigations:

- Divert traffic from broken cluster to working ones
- Drop traffic to prevent cascading failure
- Disable non-essential subsystems to reduce load
- Preserve evidence (logs, traces) for subsequent root-cause analysis

Analogy: a pilot's first responsibility in an emergency is to fly the airplane; troubleshooting is secondary.

## Common Pitfalls

| Pitfall                                          | Antidote                                                                           |
| ------------------------------------------------ | ---------------------------------------------------------------------------------- |
| Looking at irrelevant symptoms                   | Understand the system well before troubleshooting                                  |
| Latching on to past failure modes                | Base rates matter: "horses not zebras"                                             |
| Spurious correlations                            | Correlation ≠ causation; large monitored systems produce coincidental correlations |
| Improbable theories                              | Occam's Razor: simpler explanations first                                          |
| Misunderstanding how to change the system safely | Document changes; know what to revert                                              |

## Examination Tools

| Tool                      | Use                                                                                    |
| ------------------------- | -------------------------------------------------------------------------------------- |
| **Metrics / time-series** | Graph to find correlations to events; overlay deployment timestamps                    |
| **Logs**                  | Multiple verbosity levels adjustable on the fly; statistical sampling for high-traffic |
| **Distributed traces**    | Request flows across service boundaries (Jaeger, Dapper)                               |
| **State endpoints**       | Live RPC histograms, in-flight requests, configuration snapshots                       |
| **Test client**           | Inject known requests to isolate component behavior                                    |

## Diagnostic Techniques

### Divide and Conquer

Start at one end of the stack, work toward the other. For very large systems, **bisect**: split in half, determine which half contains the problem, repeat.

### Ask What / Where / Why

A malfunctioning system is usually still doing _something_ — just not what you want. Find out what it's doing, why, and where resources are going. Related to Toyota's "5 Whys" technique.

### What Touched It Last

Systems have inertia. Recent changes (deployments, config pushes, traffic pattern shifts) are productive starting points. Annotate metric graphs with change events.

## Designing Good Experiments

- **Mutually exclusive alternatives**: each test rules one group in, another out
- **Decreasing order of likelihood**: test probable causes before exotic ones
- **Account for confounders**: firewall rules, IP-specific access, environmental differences
- **Side effects**: active tests may change system state (e.g., verbose logging worsening the latency you're measuring)
- **Non-definitive tests**: some (race conditions, deadlocks) may only be suggestive
- **Document everything**: ideas tried, tests run, results — essential for postmortem

## Negative Results Are Magic

A negative result (hypothesis tested, expected effect absent) is as valuable as a positive one:

- Conclusive: tells you something certain about the system
- Informative for peers: prevents redundant experiments
- Tools/infrastructure from negative experiments often outlive the experiment
- Publishing promotes industry data-driven culture

> Publish your results. If you're interested in the experiment's results, there's a good chance others are too.

## Making Systems Easier to Troubleshoot

- Build white-box metrics + structured logs into every component from day one
- Design systems with well-understood, observable interfaces
- Use a unique request identifier across all RPCs for log correlation
- Log and audit all system changes (deployments, config changes)

## Related Pages

- [Incident Response](incident-response.md)
- [Observability](observability.md)
- [Runbooks](runbooks.md)
- [Four Golden Signals](four-golden-signals.md)
- [Distributed Tracing](distributed-tracing.md)
- [SRE Book Effective Troubleshooting](../sources/sre-book-effective-troubleshooting.md)
