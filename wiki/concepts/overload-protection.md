---
title: "Overload Protection"
tags:
  [
    sre,
    overload,
    throttling,
    criticality,
    load-shedding,
    retry,
    adaptive-throttling,
  ]
sources: [sre-handling-overload.md]
updated: 2026-04-24
---

# Overload Protection

No load balancing policy prevents overload entirely. Systems must be designed to handle it gracefully: **accept as much traffic as capacity allows; reject the rest gracefully** rather than crashing.

## Degraded Responses

Under overload, serve degraded responses before serving errors:

- Search: query a small percentage of the corpus
- Data service: serve from a local (possibly stale) cache

When even degraded responses are too expensive: return `overloaded; don't retry` to prevent retry amplification.

## Capacity Modeling

Model capacity in resources, not QPS. CPU consumption is usually the right primary signal:

- GC platforms: memory pressure translates into CPU
- Non-GC platforms: other resources can be over-provisioned so CPU is binding

Use **CPU seconds/second** as the unit for per-customer limits.

## Per-Customer Quotas

Define per-customer CPU limits that may sum to more than total capacity (relying on statistical diversity). Enforce at the backend by tracking real-time global usage and pushing effective limits to individual tasks.

## Adaptive Throttling (Client-Side)

When backend rejections are high, backends may spend more CPU rejecting than serving. **Adaptive throttling** moves rejection to the client.

**Mechanism:** Over a 2-minute sliding window, each client tracks:

- `requests`: application-layer attempts
- `accepts`: requests accepted by backend

Self-regulate when `requests ≥ K × accepts`. Default K = 2. Reject new requests locally with increasing probability.

**K tuning:**

- K = 2 (default): wastes ~50% backend capacity on rejections, but propagates state faster
- K = 1.1: only 1 rejection per 10 accepts; use when rejection cost ≈ processing cost

Entirely client-local — no coordination required.

## Criticality

Requests carry a criticality level, propagated automatically through the RPC stack:

| Level            | Use                           | Shed Under        |
| ---------------- | ----------------------------- | ----------------- |
| `CRITICAL_PLUS`  | Most critical user operations | Last              |
| `CRITICAL`       | Default production traffic    | After SHEDDABLE\* |
| `SHEDDABLE_PLUS` | Batch jobs (retry in minutes) | Before CRITICAL   |
| `SHEDDABLE`      | Very sheddable batch work     | First             |

A task only rejects `CRITICAL` after shedding all `SHEDDABLE` traffic. Set criticality at the entry point (HTTP frontend → browser/mobile), override only where necessary.

Criticality is orthogonal to latency — a sheddable request can still be latency-sensitive.

## Utilization Signals

**Executor load average:** Count of active threads (running or waiting for CPU), smoothed with exponential decay. Begin rejecting when active threads exceed available processors.

Additional signals (memory pressure, custom) are pluggable and combinable.

## Retry Budgets

**Per-request budget:** Max 3 attempts. After 3 failures, propagate error up.

**Per-client budget:** Track retry ratio. If retry ratio > 10%, stop retrying. Caps load amplification at ~1.1× even under full overload (vs. up to 3× without this limit).

**Retry counter in metadata:** Backend histograms track retry counters. If many retries detected (cluster-wide overload), backend returns `overloaded; don't retry` instead of `task overloaded`.

**Cascade rule:** Retries only at the layer **immediately above** the rejecting layer. Multi-layer retries cause combinatorial explosion.

## Connection Load

Often-overlooked overload source:

- Large numbers of idle connections with health checks can cost more than serving actual requests
- Large batch jobs creating thousands of connections simultaneously can overload backends

**Batch proxy pattern:** `batch client → batch proxy → backend`

- Proxy absorbs connection storm, shielding backends
- Reduces backend connection count → better load balancing visibility
- Acts as a fuse for burst traffic

## See Also

- [Load Balancing](load-balancing.md)
- [Site Reliability Engineering](site-reliability-engineering.md)
- [SRE Book — Chapter 21: Handling Overload](../sources/sre-handling-overload.md)
- [SRE Book — Chapter 19: Load Balancing at the Frontend](../sources/sre-load-balancing-frontend.md)
- [SRE Book — Chapter 20: Load Balancing in the Datacenter](../sources/sre-load-balancing-datacenter.md)
