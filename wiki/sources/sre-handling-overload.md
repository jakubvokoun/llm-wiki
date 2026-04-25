---
title: "SRE Book — Chapter 21: Handling Overload"
tags: [sre, overload, throttling, criticality, load-shedding, retry]
sources: [sre-handling-overload.md]
updated: 2026-04-24
---

# SRE Book — Chapter 21: Handling Overload

Written by Alejandro Forero Cuervo.

## Core Principle

No load balancing policy is perfect — _eventually_ some part of any system becomes overloaded. Graceful overload handling is fundamental to reliability. The goal: **backends should continue accepting as much traffic as capacity allows, and reject the rest gracefully** rather than crashing.

## Degraded Responses

First option under overload: serve degraded responses rather than errors.

- Search: query only a small percentage of the candidate corpus
- Data service: serve from a local (possibly stale) cache instead of canonical storage

When even degraded responses are too expensive, errors are unavoidable. At that point, return `overloaded; don't retry` to prevent amplification.

## The Pitfall of QPS-Based Capacity

Modeling capacity as "queries per second" is a poor metric because:

- Query cost varies enormously (1000× or more between cheapest and most expensive)
- Cost ratios can change abruptly with software changes

**Better approach:** Model capacity directly in available resources (CPU cores, memory). Use CPU consumption as the primary signal because:

- GC-based platforms: memory pressure → increased CPU consumption
- Non-GC platforms: other resources can be over-provisioned so CPU is the binding constraint

## Per-Customer Limits

When a service serves many internal clients, define per-customer CPU quotas (e.g., Gmail allowed 4,000 CPU-sec/sec out of 10,000 total). Limits may add up to more than available capacity, relying on the fact that not all customers hit limits simultaneously.

Usage is aggregated globally in real time across all backend tasks, and effective limits are pushed to individual tasks. Computing per-request CPU cost is complex for non-thread-per-request servers.

## Client-Side Throttling (Adaptive Throttling)

Rejecting requests at the backend still consumes resources. If rejection rate is high, backends can become overloaded just handling rejections.

**Adaptive throttling:** When a client sees significant `out-of-quota` rejections, it self-regulates and drops requests locally before they hit the network.

**Algorithm:** Each client tracks over a 2-minute sliding window:

- `requests`: total requests attempted by the application layer
- `accepts`: requests actually accepted by the backend

Self-regulation kicks in when `requests ≥ K × accepts`. New requests are rejected locally with a calculated probability.

Default **K = 2**: allows up to 2× the accepted rate to propagate. This wastes some backend resources but speeds up state propagation (e.g., when backend recovers, clients detect it sooner).

For services where rejection is nearly as expensive as processing, reduce K to 1.1 (only 1 rejection per 10 accepts).

**Advantage:** Entirely client-side, no additional dependencies, works without coordination.

**Limitation:** Works poorly for sporadic clients with infrequent requests (insufficient view of backend state).

## Criticality

Requests carry a criticality value, propagated automatically through the RPC stack:

| Level            | Description                                                |
| ---------------- | ---------------------------------------------------------- |
| `CRITICAL_PLUS`  | Most critical — serious user-visible impact if lost        |
| `CRITICAL`       | Default for production jobs — user-visible impact          |
| `SHEDDABLE_PLUS` | Partial unavailability expected; batch jobs default        |
| `SHEDDABLE`      | Frequent partial + occasional full unavailability expected |

**Overload behavior:**

- A task only rejects `CRITICAL` requests after it's already rejecting all `SHEDDABLE` and `SHEDDABLE_PLUS` requests
- Per-customer limits can also be set per criticality
- Adaptive throttling maintains separate stats per criticality

Criticality is orthogonal to latency requirements. A highly sheddable request (search-as-you-type suggestions) may still have tight latency requirements.

**Best practice:** Set criticality as close to the browser/mobile client as possible (usually at the HTTP frontend), override only at specific well-reasoned points.

## Utilization Signals

Task-level overload protection is based on _utilization_. The primary signal is **executor load average**: count of active threads (running or ready to run, waiting for CPU). Smoothed with exponential decay; rejection begins when active threads exceed available processors.

Other pluggable signals: memory pressure, custom resource metrics. Multiple signals can be combined.

## Handling Overload Errors

Two scenarios when a client receives `task overloaded`:

| Scenario                              | Response                               |
| ------------------------------------- | -------------------------------------- |
| Large subset of datacenter overloaded | Don't retry; bubble error to caller    |
| Small subset overloaded (typical)     | Retry immediately on different backend |

Retries are indistinguishable from new requests — no explicit routing to a different backend, just relies on probability across the backend pool.

### Retry Budgets

**Per-request retry budget:** Maximum 3 attempts. After 3 failures, return error upward.

**Per-client retry budget:** Track retry ratio (retries / total requests). Stop retrying if ratio exceeds 10%.

**Combined effect:** Without client retry budget, load could grow to ~3× under full overload. With 10% retry ratio limit, growth capped at ~1.1×.

**Retry counter metadata:** Clients include a retry counter in request metadata. Backends track histograms of these values. If histograms show significant retries (indicating cluster-wide overload), backend returns `overloaded; don't retry` instead of `task overloaded`.

**Critical rule:** Retries should only happen at the layer **immediately above** the rejecting layer. Multi-layer retries cause combinatorial explosion.

## Load from Connections

High connection count and high connection churn are often overlooked sources of load:

- Inactive clients doing UDP health checks can cost more than serving their actual requests
- Large batch jobs creating thousands of connections simultaneously can overload backends

**Mitigations:**

- Tune health check frequency and TCP connection lifetime
- Use **batch proxy** pattern: batch clients → batch proxy → backend. Proxy acts as a fuse, shields backends from connection storms, and can use larger subsets for better backend visibility.

## See Also

- [Overload Protection](../concepts/overload-protection.md)
- [Load Balancing](../concepts/load-balancing.md)
- [SRE Book — Chapter 19: Load Balancing at the Frontend](sre-load-balancing-frontend.md)
- [SRE Book — Chapter 20: Load Balancing in the Datacenter](sre-load-balancing-datacenter.md)
