---
title: "Cascading Failures"
tags: [sre, distributed-systems, reliability, overload]
sources: [sre-addressing-cascading-failures.md]
updated: 2026-04-25
---

# Cascading Failures

A cascading failure is a failure that grows over time as a result of positive feedback. When a portion of an overall system fails, it increases the probability that other portions of the system fail—the classic domino effect.

## How Cascades Start

The most common trigger is **server overload**: one cluster fails, its traffic redistributes to others, and those clusters become overloaded and fail in turn. The load balancing and task scheduling systems may act very quickly (minutes), making cascades rapid.

Other triggers: process death, new rollouts with changed resource profiles, organic traffic growth not matched by capacity, planned maintenance drains, request profile changes.

## Resource Exhaustion Cascade Patterns

Resource exhaustion scenarios feed from one another:

1. Java GC death spiral: less CPU → slower requests → more RAM used → more GC → even less CPU
2. Cache reduction spiral: more in-flight requests → less RAM for caches → lower cache hit rate → more backend RPCs → backend overload
3. Thread starvation → failed health checks → load balancer removes server → more load on remaining servers

Debugging is hard because secondary symptoms can look like root causes.

## Service Unavailability Snowball

Once servers start crash-looping: new servers come up, immediately receive high load, fail immediately. To stabilize, load may need to drop to a small fraction of normal (e.g., 10%) before enough servers can become healthy.

Load balancing policies that avoid servers with errors can exacerbate this—they don't contribute to available capacity, increasing load on remaining servers.

## Preventing Cascades

### Design Measures

- **Load test to breaking point** — most important single measure; reveals actual breaking points per component
- **Queue management** — small queue lengths (≤50% of thread pool) prefer early rejection over high-latency queuing; LIFO/CoDel discards stale requests
- **Load shedding** — reject requests when overloaded (HTTP 503 when in-flight count exceeds threshold)
- **Graceful degradation** — reduce work quality under load (subset search, less accurate algorithm)
- **Retry discipline** — exponential backoff + jitter; per-request retry limits; server-wide retry budget; avoid multi-layer retry amplification (frontend + backend + JS = 64× amplification)
- **Deadline propagation** — propagate absolute deadline through call tree so deep servers don't work on doomed requests
- **Avoid intra-layer communication** — cycles in call path cause distributed deadlock and amplify under load
- **Capacity planning** — N+2 per-cluster design; always load test to determine actual breaking point

### Bimodal Latency Trap

If a small fraction of requests never complete (due to an unavailable backend) and the deadline is very long, those requests hold threads continuously. With a 100s deadline and 5% stuck requests: the frontend may only handle 19.6% of total requests (80.4% error rate). Mitigation: use fail-fast for unavailable backends; avoid deadlines many orders of magnitude larger than mean latency.

### Cold Cache Risk

Distinguish **latency caches** (service survives without it) from **capacity caches** (service cannot handle expected load without it). Cold caches on cluster startup, maintenance return, or restart cause overload. Slowly ramp load when warming a cluster.

## Immediate Recovery Steps

1. **Add resources** — if not death-spiraling
2. **Disable health checks temporarily** — stops crash-loop from health-check-induced kills; distinguish process health check from service health check
3. **Restart servers** — for GC death spirals, deadlocks, unbounded in-flight requests
4. **Drop traffic aggressively** — allow only 1% through; stabilize; gradually ramp up; fix root cause first (cascade re-triggers without it)
5. **Enter degraded mode** — requires advance engineering
6. **Eliminate batch load** — index updates, stats gathering
7. **Block queries of death**

## Testing for Cascades

- Test each component separately and until failure and beyond
- Test both gradual ramp-up and impulse load patterns (reveals cold-cache effects)
- Test whether component can exit degraded mode without human intervention
- Test popular clients' behavior under service failure
- Test noncritical backends — even "noncritical" blackholed backends can exhaust resources

## Sources

- [SRE Book Ch. 22: Addressing Cascading Failures](../sources/sre-addressing-cascading-failures.md)
- [SRE Book Ch. 21: Handling Overload](../sources/sre-handling-overload.md) — complementary overload protection mechanisms
