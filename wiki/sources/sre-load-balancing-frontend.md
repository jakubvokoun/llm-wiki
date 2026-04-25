---
title: "SRE Book — Chapter 19: Load Balancing at the Frontend"
tags: [sre, load-balancing, dns, vip, consistent-hashing, networking]
sources: [sre-load-balancing-frontend.md]
updated: 2026-04-24
---

# SRE Book — Chapter 19: Load Balancing at the Frontend

Written by Piotr Lewandowski.

## The Case for Multi-Level Load Balancing

Even an infinitely powerful single machine would fail the test: the speed of light bounds fiber optic communication; single points of failure are catastrophic at scale. Load balancing is how traffic is distributed across many machines, datacenters, and network links.

**Optimal distribution is context-dependent:**

- Search request → minimize latency → route to nearest datacenter (RTT)
- Video upload → maximize throughput → route to underutilized link

At the local (datacenter) level, all machines are treated as equidistant, so optimal distribution focuses on resource utilization and preventing single-server overload.

Google's approach: **load balance at multiple levels**, starting before the connection is even established.

## Layer 1: DNS Load Balancing

DNS is the first opportunity to balance load — before the client sends any HTTP request.

### How It Works

Simplest approach: return multiple `A`/`AAAA` records; client picks arbitrarily. Problems:

- No control over client behavior (all records attract equal traffic)
- SRV weight/priority records not adopted for HTTP

Better approach: anycast authoritative nameservers → DNS queries naturally flow to the nearest server → replies contain addresses closest to that server.

Even better: build a map of all networks and their approximate physical locations, serve DNS replies based on that mapping.

### The Recursive Resolver Problem

End users rarely talk directly to authoritative nameservers. A **recursive resolver** sits between them, proxying and caching queries.

**Three implications:**

1. **IP mismatch:** The authoritative server sees the resolver's IP, not the user's. Mitigation: EDNS0 client subnet extension (RFC draft) — resolver includes client subnet in the query. Major resolvers (OpenDNS, Google Public DNS) already support this.

2. **Nondeterministic paths:** A single ISP nameserver may serve users across an entire continent, yet connect to only one datacenter. Replies optimized for the resolver, not users.

3. **Caching complications:** TTL controls propagation speed. Low TTL = faster propagation = more load on authoritative servers. Authoritative nameservers can't flush resolver caches. Google tracks resolver user-base size and geographic distribution to manage impact.

### DNS Limitations

- 512-byte limit per DNS reply (RFC 1035) caps the number of addresses returned
- TTL creates propagation delays — sets lower bound on how quickly load balancing decisions take effect
- DNS alone is insufficient; must be followed by VIP-level balancing

## Layer 2: VIP Load Balancing

**Virtual IP (VIP):** An IP address not assigned to any specific network interface, shared across many backend machines. From the user's perspective, it's a single regular IP.

The **network load balancer** receives packets and forwards them to backends behind the VIP.

### Backend Selection Approaches

**Connection ID hashing (stateless):**

```
id(packet) mod N
```

All packets of a connection go to the same backend. But if a backend is removed, N→N-1 remaps nearly all connections — catastrophic disruption.

**Consistent hashing:** Proposed 1997. Provides a mapping that remains stable when backends are added/removed. Minimizes connection disruption when the pool changes. Google uses simple connection tracking as default, falling back to consistent hashing under pressure (e.g., DDoS).

### Packet Forwarding Mechanisms

**NAT:** Modify destination IP. Requires full connection state in tracking table — precludes stateless fallback.

**Direct Server Response (DSR):** Modify destination MAC address (layer 2). Backend receives original source/destination IPs and replies directly to the client — only small requests traverse the load balancer. Problem: all LBs and backends must be in the same broadcast domain. Google outgrew this.

**Packet encapsulation (GRE):** Google's current approach. Wrap the forwarded packet in another IP+GRE packet addressed to the backend. Backend strips outer layer and processes the inner packet. LB and backend can be on separate continents.

**GRE overhead:** 24 bytes per packet for IPv4+GRE. May cause packets to exceed MTU → fragmentation. Mitigated within datacenter by using larger MTU (requires network support for large PDUs).

## Key Principles

- Load balance early, load balance often
- DNS handles geographic distribution but can't replace per-connection routing
- VIPs hide backend pool size and simplify maintenance
- Consistent hashing minimizes disruption when backends change
- Encapsulation provides flexibility at the cost of packet overhead

## See Also

- [Load Balancing](../concepts/load-balancing.md)
- [SRE Book — Chapter 20: Load Balancing in the Datacenter](sre-load-balancing-datacenter.md)
- [SRE Book — Chapter 21: Handling Overload](sre-handling-overload.md)
