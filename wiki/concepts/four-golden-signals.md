---
title: "Four Golden Signals"
tags:
  [
    sre,
    monitoring,
    alerting,
    observability,
    latency,
    traffic,
    errors,
    saturation,
  ]
sources: [sre-book-monitoring-distributed-systems.md]
updated: 2026-04-24
---

# Four Golden Signals

The Four Golden Signals are the minimum viable monitoring set for any user-facing service, as defined in the Google SRE Book. If you can only measure four metrics, measure these.

## The Signals

### Latency

Time to service a request.

- Distinguish **successful request latency** from **error latency** — slow errors are worse than fast errors and must be tracked separately
- Use **percentiles** (p50, p99, p99.9), not means — averages mask tail behavior
- p99 of a backend service can become p50 of a frontend (fan-out effect)
- Collect as histograms with exponentially spaced buckets (0–10ms, 10–30ms, 30–100ms, ...)

### Traffic

Demand placed on the system.

- Web service: HTTP requests/second (broken out by request type)
- Audio streaming: concurrent sessions or network I/O rate
- Key-value store: transactions/second and retrievals/second
- Use service-specific high-level metrics, not just raw network I/O

### Errors

Rate of failed requests — explicit, implicit, or by policy.

- **Explicit:** HTTP 500s, connection refused
- **Implicit:** HTTP 200 with wrong content (requires end-to-end validation)
- **By policy:** responses slower than SLO threshold count as errors

Catching 500s at the load balancer misses implicit failures; end-to-end tests are needed for those.

### Saturation

How "full" the service is — how close to its capacity limit.

- Focus on the most-constrained resource: CPU, memory, I/O, disk
- Most systems degrade before 100% utilization — set a utilization target, not just 100%
- **Leading indicator:** p99 latency increases often signal approaching saturation before resource exhaustion
- Include predictive saturation: "disk full in 4 hours"
- For simple services: static load-test value may suffice; most need indirect signals (CPU %, network bandwidth)

## Using All Four

Measure all four and page when any one is problematic (or for saturation, _nearly_ problematic) → decent baseline coverage.

## White-box vs Black-box

- **White-box monitoring** (internal metrics/logs): detects imminent problems, failures masked by retries; symptom or cause depending on depth
- **Black-box monitoring** (external behavior): detects active, real problems — forces paging discipline (only page when users are actually affected)

Combine both: heavy white-box for debugging and early warning; black-box for pager triggers.

## Symptom vs Cause

Page on **symptoms** (what's broken for users), not causes (why it's broken). Cause-oriented signals belong in dashboards for debugging, not on the pager.

## Alerting Rules

Before creating a paging alert, verify:

1. Does it detect an **otherwise undetected**, urgent, actionable, user-visible condition?
2. Can it ever be safely ignored? If yes — eliminate or fix the condition first.
3. Does it **definitely** indicate user impact? Filter drained traffic, test deployments.
4. Is action required? Is it urgent? Can it be automated? Is it a real fix or workaround?

**Paging philosophy:**

- Every page → react with urgency (sustainable only a few times/day)
- Every page → actionable
- Every page → requires intelligence (not robotic response)
- Every page → novel problem

## Monitoring System Design

- Keep it **simple**: complex dependency hierarchies fail at Google's pace of refactoring
- Rules catching real incidents → simple, predictable, reliable
- Rarely-triggered rules (< once/quarter) → candidates for removal
- Collected-but-unused metrics → candidates for removal
- Avoid ML-based auto-threshold detection (except for simple end-user rate anomalies)

## Related Pages

- [Observability](observability.md)
- [Alert Severity Levels](alert-severity.md)
- [Prometheus Alerting](prometheus-alerting.md)
- [Prometheus Instrumentation](prometheus-instrumentation.md)
- [Service Level Objectives](service-level-objectives.md)
- [Site Reliability Engineering](site-reliability-engineering.md)
