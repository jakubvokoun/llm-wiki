---
title: "SRE Book — Chapter 22: Addressing Cascading Failures"
tags: [sre, distributed-systems, reliability, overload, cascading-failures]
sources: [sre-addressing-cascading-failures.md]
updated: 2026-04-25
---

# SRE Book — Chapter 22: Addressing Cascading Failures

Written by Mike Ulrich.

> If at first you don't succeed, back off exponentially.

A cascading failure is a failure that grows over time as a result of positive feedback. When a portion of an overall system fails, it increases the probability that other portions fail—the classic domino effect.

## Key Takeaways

### Causes

**Server overload** is the most common cause. When cluster B fails, cluster A receives its traffic, becomes overloaded, and starts failing too—spreading the failure globally in minutes.

**Resource exhaustion** cascades through dependencies:

- CPU exhaustion → more in-flight requests → more memory → reduced cache hit rate → more backend RPCs → backend overload
- Java GC death spiral: less CPU → slower requests → more RAM → more GC → even less CPU
- Thread starvation → failed health checks → load balancer removes the server → increased load on others

### Preventing Overload

1. **Load test to the breaking point** — most critical exercise; reveals which resource breaks first
2. **Serve degraded results** — lower quality, cheaper to compute
3. **Instrument servers to reject requests when overloaded** — fail early and cheaply
4. **Rate limit at proxies/load balancers/individual tasks**
5. **Capacity plan with performance testing** — N+2 cluster planning

### Queue Management

- Small queue lengths (≤50% of thread pool) are better for steady traffic — causes early rejection rather than high latency
- LIFO or CoDel queuing discards requests that are no longer worth processing (user already refreshed browser)

### Load Shedding and Graceful Degradation

**Load shedding:** Return HTTP 503 when in-flight requests exceed a threshold.

**Graceful degradation:** Reduce work quality under load (search in-memory cache only, use less accurate algorithm).

Pitfall: rarely-used code paths don't work well — regularly run a subset of servers near overload to exercise the code path.

### Retries

Naive retries can destabilize a system by amplifying load. Guidelines:

- **Always use randomized exponential backoff**
- **Limit retries per request**
- **Use a server-wide retry budget** (e.g., 60 retries/minute max)
- **Avoid amplifying retries at multiple layers** — if frontend, backend, and JavaScript each retry 3× (4 attempts), 1 user action → 64 database attempts
- **Use clear response codes** — distinguish retriable from non-retriable errors

### Latency and Deadlines

**Deadline propagation:** Set a deadline high in the stack; propagate absolute deadline throughout the call tree. Without this, a server deep in the stack may spend 15 seconds on a doomed request.

**Bimodal latency trap:** If 5% of requests have a 100s deadline and never complete, they consume so many threads that the frontend handles only 19.6% of total requests (80.4% error rate), despite only 5% of requests being inherently unfulfillable.

**Cancellation propagation:** Advise servers that their work is no longer needed (used with hedged requests).

### Cold Caching

Distinguish **latency caches** (service survives without it) from **capacity caches** (service cannot handle load without it). Slowly ramp up load when adding a cluster to warm caches.

### Intra-Layer Communication

Avoid communication cycles in the user request path — susceptible to distributed deadlock, and amplifies under high load. Instead of backend-to-backend proxying, have the client retry on the correct backend.

### Triggering Conditions

Process death, process updates, new rollouts, organic growth, planned drains/turndowns, request profile changes, cluster resource limit changes.

### Testing

- Load test each component until failure and beyond
- Test both gradual ramp and impulse load patterns
- Test popular clients' behavior (backoff? queue work when down?)
- Test noncritical backends — even "noncritical" blackholed backends can cause resource exhaustion

### Immediate Steps During a Cascade

1. Increase resources (if not death-spiraling)
2. Temporarily disable health checks (stop crash-loop from health-check deaths)
3. Restart servers (GC death spiral, deadlocks, threadlocked servers)
4. Drop traffic aggressively (1% through, stabilize, slowly ramp up)
5. Enter degraded mode
6. Eliminate batch load (index updates, stats gathering)
7. Block queries of death

## Related Concepts

- [Overload Protection](../concepts/overload-protection.md) — adaptive throttling, criticality levels, retry budgets
- [Load Balancing](../concepts/load-balancing.md) — lame duck state, datacenter-level distribution
- [Cascading Failures](../concepts/cascading-failures.md) — full concept page
- [Incident Response](../concepts/incident-response.md) — managing the cascade when it occurs
