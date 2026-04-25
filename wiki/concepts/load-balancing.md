---
title: "Load Balancing"
tags:
  [
    sre,
    load-balancing,
    dns,
    vip,
    consistent-hashing,
    weighted-round-robin,
    subsetting,
  ]
sources: [sre-load-balancing-frontend.md, sre-load-balancing-datacenter.md]
updated: 2026-04-24
---

# Load Balancing

Load balancing distributes traffic across many machines, network links, and datacenters to maximize resource utilization and prevent any single component from becoming a bottleneck or single point of failure.

Optimal distribution is context-dependent:

- Latency-sensitive requests → route to nearest datacenter (RTT)
- Throughput-sensitive requests → route to underutilized links

## Two Levels

### Frontend Load Balancing (Cross-Datacenter)

**DNS load balancing:**

- Return multiple `A`/`AAAA` records; client picks an address
- Authoritative servers track resolver user-base size and geographic distribution
- EDNS0 client subnet extension allows optimization for user, not just resolver
- TTL bounds propagation speed; 512-byte reply size bounds address count
- DNS alone is insufficient

**VIP (Virtual IP) load balancing:**

- A VIP is shared across many backends; users see a single IP
- Network load balancer receives packets and forwards to a selected backend
- Google's approach: GRE encapsulation — wrap packet in IP+GRE addressed to backend; backend strips outer layer. LB and backend can be on different continents.
- 24-byte GRE overhead per packet; mitigated by larger datacenter MTU

**Backend selection for VIPs:**

| Method             | State                | Disruption on backend change         |
| ------------------ | -------------------- | ------------------------------------ |
| Least loaded       | Yes (per-connection) | High (rerouting on failure)          |
| `id(packet) mod N` | No                   | Catastrophic (all connections remap) |
| Consistent hashing | No                   | Minimal (only affected connections)  |

Consistent hashing (1997) provides a mapping that remains stable when backends are added or removed. Used as fallback under pressure (e.g., DDoS).

**Forwarding mechanisms:**

- NAT: modify destination IP; requires full connection state
- DSR (Direct Server Response): modify destination MAC; backend replies directly; all machines must share broadcast domain (doesn't scale)
- GRE encapsulation: current Google approach; no broadcast domain constraint

### Datacenter Load Balancing (Within Datacenter)

#### Identifying Unhealthy Backends

**Flow control:** Track active requests per connection; treat as unhealthy above threshold (~100). Too coarse.

**Lame duck state:** Backend explicitly signals clients to stop sending new requests. Propagated to all clients via UDP health checks within ~2 RTT. Enables graceful shutdown without dropped requests.

Lame duck clean shutdown sequence:

1. SIGTERM → enter lame duck → notify clients
2. In-flight requests complete normally
3. Active count reaches zero
4. After 10–150s, exit cleanly

#### Subsetting

Each client connects to a subset of backends (20–100 tasks). Random subsetting is inadequate — produces 50–150% load spread at 10% subset size.

**Deterministic subsetting** ensures even connection distribution:

- Clients grouped into "rounds" of `subset_count` clients
- Within each round, each backend assigned to exactly one client
- Each round uses a different shuffle seed to prevent correlated failures
- Result: each backend receives ±1 connections from average

#### Load Balancing Policies

| Policy                   | Info Used                  | CPU Spread           | Issues                                                        |
| ------------------------ | -------------------------- | -------------------- | ------------------------------------------------------------- |
| Simple Round Robin       | None                       | Up to 2×             | Ignores machine diversity, query cost variance                |
| Least-Loaded Round Robin | Active request count       | Similar to RR        | Sinkholing (fast-failing unhealthy task looks "least loaded") |
| Weighted Round Robin     | Backend QPS + errors + CPU | Significantly better | Most practical for large services                             |

**Sinkholing mitigation:** Count recent errors as active requests so a fast-failing backend is treated as loaded.

**Machine diversity:** Google uses GCU (Google Compute Units) to normalize CPU rates across architectures.

## Key Principles

- Load balance at multiple levels (DNS → VIP → datacenter)
- Consistent hashing minimizes disruption when backend pools change
- Deterministic subsetting enables even distribution without random variance
- Backend telemetry (Weighted Round Robin) is necessary at scale
- Lame duck state is required for graceful maintenance

## See Also

- [Overload Protection](overload-protection.md)
- [SRE Book — Chapter 19: Load Balancing at the Frontend](../sources/sre-load-balancing-frontend.md)
- [SRE Book — Chapter 20: Load Balancing in the Datacenter](../sources/sre-load-balancing-datacenter.md)
- [SRE Book — Chapter 21: Handling Overload](../sources/sre-handling-overload.md)
