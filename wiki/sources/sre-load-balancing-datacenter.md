---
title: "SRE Book — Chapter 20: Load Balancing in the Datacenter"
tags: [sre, load-balancing, subsetting, weighted-round-robin, lame-duck]
sources: [sre-load-balancing-datacenter.md]
updated: 2026-04-24
---

# SRE Book — Chapter 20: Load Balancing in the Datacenter

Written by Alejandro Forero Cuervo.

## Problem Statement

Within a datacenter, _client tasks_ must decide which _backend task_ (among many homogeneous processes) should handle each query. Poor distribution is wasteful: if the most loaded task is at capacity but others are idle, you may be reserving 1,000 CPUs but only using 700.

Formally, wasted capacity = sum over all tasks of (CPU[most\_loaded] − CPU[task]).

## Identifying Bad Tasks

### Flow Control (Simple)

Clients track active request counts per connection. If count exceeds ~100, mark the backend unhealthy. Basic protection against extreme overload, but too coarse — backends can overload well before the limit, or hit the limit when still healthy (e.g., long-lived requests).

### Lame Duck State (Robust)

Backend task states:

- **Healthy:** Processing requests normally
- **Refusing connections:** Starting up, shutting down, or abnormal
- **Lame duck:** Listening but explicitly asking clients to stop sending new requests

When a task enters lame duck state, it broadcasts to active clients. Inactive clients receive the signal via periodic UDP health checks, typically within 1–2 RTT.

**Clean shutdown sequence:**

1. Job scheduler sends SIGTERM
2. Backend enters lame duck, notifies clients
3. Ongoing requests complete normally
4. Active request count gradually reaches zero
5. After configured interval (10–150s), task exits or scheduler kills it

Lame duck also enables backends to defer serving traffic during slow initialization — they can accept TCP connections early while still in lame duck, becoming healthy only when ready.

## Subsetting: Limiting Connection Pools

Every client-backend connection consumes memory and CPU at both ends (health checks). Connecting every client to every backend is impractical at scale.

**Subsetting:** Each client connects to a fixed-size subset of backends (typically 20–100 tasks).

### Why Random Subsetting Fails

Random selection creates severely uneven connection distribution. To spread load evenly via random subsetting, you'd need subset sizes of ~75% — impractical. At 10%, the most loaded backend gets 150% of the average load while the least loaded gets 50%.

### Deterministic Subsetting

```python
def Subset(backends, client_id, subset_size):
    subset_count = len(backends) / subset_size
    round = client_id / subset_count
    random.seed(round)
    random.shuffle(backends)
    subset_id = client_id % subset_count
    start = subset_id * subset_size
    return backends[start:start + subset_size]
```

Clients are grouped into "rounds" of `subset_count` clients each. Within a round, each backend is assigned to exactly one client. Across rounds, different shuffle seeds prevent correlated failures. The result: each backend receives exactly the same number of connections (or differs by at most 1).

**Why shuffle per round?** If N backends in a subset fail, their load spreads only among the remaining (subset_size − N) backends. With per-round shuffles, failed load spreads across all remaining backends.

## Load Balancing Policies

### Simple Round Robin

Send requests sequentially to each backend in the subset. Simple, works reasonably well. **Problem:** Can produce 2× CPU spread between least and most loaded tasks, for several reasons:

- **Small subsetting:** Clients issuing different request rates create inherent imbalance
- **Varying query costs:** Most expensive requests may cost 1000× more than cheapest
- **Machine diversity:** Different CPU architectures; Google uses GCU (Google Compute Units) to normalize
- **Unpredictable performance:** Antagonistic neighbors (up to 20% performance impact), task restarts (JIT warm-up effects)

### Least-Loaded Round Robin

Use Round Robin only among backends with the minimum number of active requests.

**Danger — sinkholing:** An unhealthy backend returning fast errors (low latency) appears "least loaded" and attracts all traffic. Mitigation: count recent errors as active requests.

**Limitations:**

- Active request count is a poor proxy when requests spend most time waiting on I/O
- Each client only sees its own requests, not total load on a backend

### Weighted Round Robin

Each client maintains a "capability" score per backend. Backends report observed QPS, error rate, and CPU utilization in every response (including health check responses). Clients update scores periodically and distribute requests proportionally.

**Result:** Significantly reduces CPU spread vs. Least-Loaded Round Robin. The most practical policy for large services.

## Key Principles

- Never use random subsetting at scale; use deterministic subsetting
- Lame duck state enables graceful shutdown without dropped requests
- Simple Round Robin is surprisingly poor due to machine diversity and query cost variance
- Weighted Round Robin uses backend telemetry to correct imbalances
- Count errors as active requests to prevent sinkholing

## See Also

- [Load Balancing](../concepts/load-balancing.md)
- [SRE Book — Chapter 19: Load Balancing at the Frontend](sre-load-balancing-frontend.md)
- [SRE Book — Chapter 21: Handling Overload](sre-handling-overload.md)
