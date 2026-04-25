---
title: "SRE Book — Chapter 23: Managing Critical State: Distributed Consensus for Reliability"
tags: [sre, distributed-systems, consensus, reliability, paxos, zookeeper]
sources: [sre-managing-critical-state.md]
updated: 2026-04-25
---

# SRE Book — Chapter 23: Managing Critical State

Written by Laura Nolan.

This chapter argues that **distributed consensus is the correct solution to any problem involving leader election, critical shared state, or distributed locking**. Ad hoc approaches using heartbeats and gossip protocols will always have reliability problems in practice.

## Key Takeaways

### The Core Problem

Many distributed systems problems are reformulations of distributed consensus:

- Leader election
- Group membership
- Distributed locking and leasing
- Reliable distributed queuing and messaging
- Maintaining critical shared state visible consistently across processes

### Why Ad Hoc Solutions Fail

Three case studies of real-world failures:

1. **Split-brain via heartbeats:** STONITH heartbeat failover. Network slowdown causes both nodes to issue STONITH commands → both may become active (corruption) or both may go down (unavailability). Cannot solve consensus with timeouts.

2. **Human-mediated failover:** Primary makes itself unavailable when it can't determine secondary health, escalates to a human. Poor availability, scales poorly, humans are already overloaded during the infrastructure problems that cause this.

3. **Faulty gossip-based group membership:** Cluster uses gossip for discovery and leader election. Network partition → each side elects a master → split-brain → data corruption.

### CAP Theorem

A distributed system cannot simultaneously guarantee: **Consistency**, **Availability**, and **Partition tolerance**. Because network partitions are inevitable, every system must choose a trade-off between consistency and availability.

**ACID** (traditional SQL): strong guarantees, costly. **BASE** (eventually consistent): higher availability, softer consistency—can lead to surprising results from clock drift or network partitions.

### How Distributed Consensus Works

- **FLP impossibility:** No asynchronous consensus algorithm can guarantee progress in an unreliable network. In practice: ensure sufficient healthy replicas + network connectivity + randomized backoff delays.
- **Crash-recover** algorithms (vs crash-fail) are more useful for real systems since most problems are transient.
- **Protocols:** Paxos, Raft, Zab, Mencius.

### Paxos

Operates as a sequence of proposals with strict sequence numbers. Phase 1: proposer sends sequence number to acceptors (acceptors agree only if they haven't seen higher). Phase 2: majority agreement → proposer commits a value. Any two majorities overlap in at least one node, so two different values cannot be committed for the same proposal.

**Multi-Paxos:** Uses a stable leader, requiring only one round-trip in steady state. Changing the proposer risks **dueling proposers** (livelock)—prevented by randomized backoff.

### System Architecture Patterns

Use consensus via high-level services rather than raw algorithms: **Zookeeper**, **etcd**, **Consul** (open source); **Chubby** (Google internal).

- **Replicated State Machine (RSM):** Execute same operations in same order on multiple processes. Foundation for datastores, queues, leader election. Any deterministic program can become a highly available service this way.
- **Leader Election:** Replicate the process; use consensus to ensure only one leader is active. Pattern used in GFS and Bigtable.
- **Barriers:** Block processes from proceeding until a condition is met (e.g., all Map tasks complete before Reduce starts in MapReduce).
- **Distributed Locking:** Use renewable leases with timeouts, not indefinite locks. Most applications should use higher-level distributed transactions, not raw locks.
- **Atomic Broadcast:** Messages received reliably and in the same order by all participants—equivalent to consensus.

### Performance

Conventional wisdom that consensus is too slow is simply not true. Google uses it at the core of many critical systems.

Key factors:

- **Stable leader** (Multi-Paxos, Raft, Zab): reduces round-trips but all state-changing ops must go via leader (latency for distant clients; leader bandwidth bottleneck)
- **Rotating leadership** (Mencius, Egalitarian Paxos): pre-assigns slots per process; better geographic distribution
- **Batching + Pipelining:** Amortizes fixed costs; keeps pipeline full
- **Quorum leases:** Grant read lease on subset of data to a quorum of replicas; allows strongly consistent local reads at cost of some write performance
- **Disk writes:** ~1–10ms; limit of ~100 operations/second when disk dominates; combine consensus log with RSM transaction log to avoid alternating physical disk locations
- **Fast Paxos:** Clients send directly to all acceptors—counterintuitively _slower_ than Classic Paxos when clients have high RTT to acceptors

### Deploying Consensus Systems

**Number of replicas:**

- 3 replicas: minimum; tolerates 1 failure; allows maintenance with one down but no safety margin
- 5 replicas: recommended; tolerates 2 failures; if unplanned failure occurs during maintenance, system stays up
- Adding a 6th replica to a 5-replica system _reduces_ availability (quorum now requires 4/6 vs 3/5)

**Replica location:** Maximize failure domain diversity vs. minimize RTT. For global deployments, leaderless protocols (Mencius, Egalitarian Paxos) give better geographic distribution. Hierarchical quorums (9 replicas in 3 groups of 3) reduce reliance on a single "linchpin" replica.

**Load balancing leaders:** In sharded systems, balance leader processes across datacenters to prevent outgoing bandwidth bottleneck and dramatic traffic shifts when a datacenter hosting many leaders fails.

### Monitoring

- Members running per group and their health status
- Persistently lagging replicas
- Whether a leader exists (no leader = total unavailability)
- Number of leader changes (rapid changes = leader flapping; decreasing view number = serious bug)
- Consensus transaction number (must increase if healthy)
- Proposals seen vs. agreed upon
- Throughput and latency distributions

## Related Concepts

- [Distributed Consensus](../concepts/distributed-consensus.md) — full concept page
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
