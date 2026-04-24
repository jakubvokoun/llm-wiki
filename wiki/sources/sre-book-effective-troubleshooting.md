---
title: "SRE Book — Chapter 12: Effective Troubleshooting"
tags: [sre, troubleshooting, debugging, incident-response, google]
sources: [sre-book-effective-troubleshooting.md]
updated: 2026-04-24
---

# SRE Book — Chapter 12: Effective Troubleshooting

Written by Chris Jones. Troubleshooting is learnable and teachable, not an innate skill.

## The Troubleshooting Model

Formally: **hypothetico-deductive method** applied to systems.

1. **Problem report** arrives (automated alert or human)
2. **Examine** telemetry and logs → understand current state
3. **Hypothesize** potential causes (using system knowledge + generic process)
4. **Test** hypotheses: compare observed state OR actively treat the system
5. **Iterate** until root cause identified
6. **Fix** proximate cause (needn't wait for full root-cause before acting)
7. **Postmortem** documenting what went wrong, how found, how fixed, how to prevent

## Common Pitfalls

- Looking at irrelevant symptoms / misreading metrics → wild goose chases
- Misunderstanding how to safely change the system to test hypotheses
- Latching on to past-incident causes ("it happened before, must be again")
- Hunting spurious correlations
- **Occam's Razor**: prefer simpler explanations
- **Correlation ≠ causation**: especially in large complex systems with many monitored metrics

## In Practice

### Problem Report

Effective report: expected behavior + actual behavior + reproduction steps. Log everything in a bug tracker — even alerts received via IM. Concentration of reports on specific engineers causes uneven load; prefer routing to the on-duty person.

### Triage: Stop the Bleeding First

> Your first response in a major outage may be to start troubleshooting and try to find a root cause as quickly as possible. **Ignore that instinct!**

Make the system work as well as it can under the circumstances:

- Divert traffic from broken clusters
- Drop traffic to prevent cascading failures
- Disable subsystems to reduce load
- Preserve evidence (logs) for subsequent root-cause analysis

Analogous to aviation: a pilot's first responsibility is to fly the airplane, not diagnose the problem.

### Examine

| Tool                | When to Use                                                                                              |
| ------------------- | -------------------------------------------------------------------------------------------------------- |
| **Metrics**         | Graph time-series to understand behavior and find correlations                                           |
| **Logs**            | Understand what a process was doing at a specific time; use multiple verbosity levels; consider sampling |
| **Traces**          | Distributed requests across service boundaries (Dapper, Jaeger)                                          |
| **State endpoints** | Per-RPC histograms, in-flight requests, configuration snapshots                                          |
| **Test client**     | Inject known requests to probe specific component behavior                                               |

### Diagnose

**Simplify and Reduce**: Look at data flowing between components. Use black-box testing at each step. Divide and conquer (linear or bisection).

**Ask What / Where / Why**:

- What is the system doing?
- Why is it doing that?
- Where are its resources going?

Example (Spanner high latency):

1. Why? Tasks using all CPU.
2. Where? Sorting log entries.
3. Where exactly? Regex evaluation against file paths.
4. Solution: Rewrite regex; use RE2 (linear time guarantee vs PCRE's exponential backtracking).

**What Touched It Last**: Systems have inertia. Recent config changes, code deployments, or load type shifts are productive starting points. Annotate dashboards with deployment times.

### Test and Treat

Design tests with mutually exclusive alternatives. Consider in decreasing order of likelihood. Account for:

- Confounding factors (firewall rules, IP-specific access)
- Side effects of active tests (verbose logging worsening latency)
- Non-definitive tests (race conditions rarely reproducible)

**Document everything** — test ideas, tests run, results — in a shared doc. Enables postmortem and prevents re-treading the same ground.

## Negative Results Are Magic

A "negative" result = expected effect is absent. **Do not ignore or discount them.**

- Conclusive: tells you something certain about the system's limits or design space
- Others benefit: prevents them from running the same experiment
- Tools outlive experiments: benchmarking infrastructure, load generators
- Publish everything: reduces bias, encourages industry-wide data-driven culture

> Be skeptical of any design document, performance review, or essay that doesn't mention failure.

## Cure

Definitively proving causation is hard in production because:

- Systems are complex; multiple factors may be jointly causal
- Systems are path-dependent
- Reproduction in production may be unacceptable

Often we can only find **probable** causal factors. Write the postmortem even without 100% certainty.

## Case Study: App Engine Latency

An App Engine customer saw 10× latency increase + 4× CPU + 4× instance count, starting on a Saturday with no code or config changes.

**Dead-ends followed**:

- Traffic spike theory: ruled out (traffic normalized but latency didn't)
- Suboptimal indexing (`merge_join` correlation): ruled out (static content was also slow, no RPC calls during the slow 250ms window)

**Mitigation**: Upgraded to CPU-rich instance type ahead of planned launch (sometimes mitigation before root cause is the right call).

**Root cause (found later)**: An automated security scanner had been testing the app for vulnerabilities and, due to a long-standing ACL bug, created thousands of whitelist objects in the datastore. Every request then had to check all of them in memory. No RPC calls were visible because the check was a local `for` loop. Fixing the bug + removing the objects restored performance.

**Lessons**:

- Spurious correlations can derail investigation
- "What is the system spending its time on?" is more useful than "what RPCs is it making?"
- Unexpected data volume changes (not code) can cause sudden performance degradation

## Making Troubleshooting Easier

- Build observability (white-box metrics + structured logs) into every component from day one
- Design systems with well-understood, observable interfaces between components
- Use a consistent unique request identifier across all RPCs for correlation
- Log and audit all changes to system state (deployments, config pushes)

## Related Pages

- [Troubleshooting](../concepts/troubleshooting.md)
- [Incident Response](../concepts/incident-response.md)
- [Observability](../concepts/observability.md)
- [Runbooks](../concepts/runbooks.md)
- [Four Golden Signals](../concepts/four-golden-signals.md)
- [SRE Book Emergency Response](sre-book-emergency-response.md)
