---
title: "Distributed Consensus"
tags: [distributed-systems, reliability, consensus, paxos, raft, zookeeper]
sources: [sre-managing-critical-state.md]
updated: 2026-04-25
---

# Distributed Consensus

Distributed consensus is the problem of reaching agreement among a group of processes connected by an unreliable communications network. It is one of the most fundamental concepts in distributed computing.

## When to Use Consensus

**Whenever you see leader election, critical shared state, or distributed locking—use distributed consensus.** Any lesser approach is a ticking bomb.

Many distributed systems problems are reformulations of consensus:

- Leader election
- Group membership
- Distributed locking and leasing
- Reliable distributed queuing and messaging
- Any critical shared state that must be viewed consistently

Ad hoc alternatives (heartbeats, gossip protocols) always have reliability problems in practice:

- STONITH heartbeat failover fails under network slowness or packet loss → split-brain or total unavailability
- Gossip-based leader election fails under network partitions → multiple leaders → data corruption

## Theoretical Foundation

**FLP impossibility:** No asynchronous distributed consensus algorithm can guarantee progress in the presence of an unreliable network (Dijkstra Prize-winning result). In practice: sufficient healthy replicas + network connectivity + randomized backoffs allow reliable progress most of the time.

**CAP theorem:** A distributed system cannot simultaneously guarantee Consistency, Availability, and Partition tolerance. Since partitions are inevitable, systems must choose a trade-off.

## Protocols

| Protocol              | Notes                                                                                     |
| --------------------- | ----------------------------------------------------------------------------------------- |
| **Paxos**             | Original; many variants for performance                                                   |
| **Multi-Paxos**       | Stable leader; one round-trip in steady state                                             |
| **Raft**              | Explicit log management; well-specified leader election                                   |
| **Zab**               | Used in Zookeeper                                                                         |
| **Mencius**           | Rotating leadership; better geographic distribution                                       |
| **Egalitarian Paxos** | Rotating leadership; optimal for WAN                                                      |
| **Fast Paxos**        | Clients propose directly to acceptors; slower than Multi-Paxos when clients have high RTT |

## Paxos in Brief

Proposals with strict sequence numbers. Phase 1: proposer sends sequence number to acceptors; acceptors agree only if they haven't seen a higher number. Phase 2: majority agreement → proposer commits. Any two majorities overlap in at least one node → two different values cannot be committed for the same proposal.

Acceptors must write to persistent storage before sending agreement, so crashed-and-restarted nodes honor prior commitments.

## System Architecture Patterns

Use consensus via high-level services (Zookeeper, etcd, Consul, Chubby) rather than raw algorithms—frees application teams from deploying and managing consensus infrastructure.

### Replicated State Machine (RSM)

Execute same operations in same order on multiple processes. The consensus algorithm orders operations; the RSM executes them. Any deterministic program can become a highly available replicated service as an RSM. Foundation for datastores, queues, leader election.

### Leader Election

Replicate the process; consensus ensures only one leader active at a time. Used in GFS and Bigtable. Consensus is not in the critical request path, so throughput is usually not a concern.

### Distributed Locking

Use renewable leases with timeouts, not indefinite locks. Most applications should use higher-level systems providing distributed transactions rather than raw locks.

### Reliable Queuing and Messaging

Implement queue as RSM to minimize risk of queue loss. **Atomic broadcast** (messages received reliably in same order by all participants) is equivalent to consensus.

## Performance

Consensus is not inherently too slow—Google uses it at the core of many critical systems.

**Two physical limits:**

1. **Network RTT:** Within datacenter ~1ms; cross-continental ~45ms; transatlantic ~70ms
2. **Disk writes:** 1–10ms; limits to ~100 operations/second when disk dominates

**Optimizations:**

- **Stable leader:** Reduces round-trips (Multi-Paxos, Raft, Zab). Drawback: leader outgoing bandwidth is a bottleneck; leader performance affects entire system.
- **Batching:** Multiple client operations in one transaction; amortizes disk write and network latency.
- **Pipelining:** Multiple proposals in-flight simultaneously; eliminates idle replicas.
- **Quorum leases:** Grant read lease to a quorum of replicas; enables strongly consistent local reads at cost of write performance—ideal for read-heavy, geographically concentrated workloads.
- **Combined log:** Merge consensus log with RSM transaction log to avoid alternating physical disk locations.

## Deployment

### Number of Replicas

- **3 replicas:** Minimum; tolerates 1 failure; cannot tolerate unplanned failure during planned maintenance
- **5 replicas:** Recommended; tolerates 2 failures; can lose one to maintenance with safety margin remaining
- Adding more replicas: adding a 6th to a 5-replica group increases required quorum from 3/5 (60%) to 4/6 (67%) → _decreases_ availability if failure domains are not carefully considered

If a system loses so many replicas it cannot form a quorum, it is theoretically unrecoverable—administrators may attempt forced group membership changes but data loss risk remains.

### Replica Location

Trade-off between failure domain diversity and RTT:

- Wider geographic spread = larger tolerable failures but higher latency
- **Hierarchical quorums** (e.g., 9 replicas in 3 groups of 3) reduce reliance on a single "linchpin" replica
- Balance leader processes across datacenters in sharded systems to avoid outgoing bandwidth concentration
- For read-heavy, geographically distributed workloads, leaderless protocols (Mencius, Egalitarian Paxos) may give better perceived latency

## Monitoring

Essential metrics:

- Number of members running and health status per group
- Persistently lagging replicas
- Whether a leader exists (no leader = total unavailability for leader-based protocols)
- Rate of leader changes (rapid = flapping; decreasing view number = serious bug)
- Consensus transaction number (must increase if healthy)
- Proposals seen vs. agreed upon

## Sources

- [SRE Book Ch. 23: Managing Critical State](../sources/sre-managing-critical-state.md)
