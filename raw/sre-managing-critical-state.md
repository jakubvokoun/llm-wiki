# Managing Critical State: Distributed Consensus for Reliability

Written by Laura Nolan. Edited by Tim Harvey.

Processes crash or may need to be restarted. Hard drives fail. Natural disasters can take out several datacenters in a region. SREs need to develop strategies to keep systems running in spite of them. These strategies usually entail running such systems across multiple sites. Geographically distributing a system is relatively straightforward, but also introduces the need to maintain a consistent view of system state.

Groups of processes may want to reliably agree on questions such as:
- Which process is the leader of a group of processes?
- What is the set of processes in a group?
- Has a message been successfully committed to a distributed queue?
- Does a process hold a lease or not?
- What is a value in a datastore for a given key?

Distributed consensus is effective in building reliable and highly available systems that require a consistent view of some system state. **Whenever you see leader election, critical shared state, or distributed locking, use distributed consensus systems that have been formally proven and tested thoroughly.** Informal approaches lead to outages and subtle, hard-to-fix data consistency problems.

## CAP Theorem

The CAP theorem holds that a distributed system cannot simultaneously have all three properties:
- Consistent views of the data at each node
- Availability of the data at each node
- Tolerance to network partitions

Because network partitions are inevitable, understanding distributed consensus amounts to understanding how consistency and availability work for your particular application.

**ACID vs BASE:** Traditional ACID datastores (Atomicity, Consistency, Isolation, Durability) provide strong guarantees. BASE (Basically Available, Soft state, Eventual consistency) datastores handle larger volumes at the cost of consistency. BASE systems rely on multimaster replication with conflict resolution (often "latest timestamp wins"), which can lead to surprising results due to clock drift or network partitioning.

## Motivating the Use of Consensus: Failure Case Studies

### Case Study 1: The Split-Brain Problem

A content repository uses pairs of replicated file servers with STONITH (Shoot The Other Node in the Head) heartbeat-based failover. If the network becomes slow or starts dropping packets, file servers exceed heartbeat timeouts and send STONITH commands—but some may not be delivered due to the compromised network. Both nodes may become active for the same resource (corruption), or both may be down (unavailability).

**Root cause:** The system tries to solve a leader election problem using simple timeouts. Leader election is a reformulation of the distributed asynchronous consensus problem, which cannot be solved correctly using heartbeats.

### Case Study 2: Failover Requires Human Intervention

A sharded database system promotes secondary to primary when the primary is unhealthy. If the primary can't determine the health of its secondary, it makes itself unavailable and escalates to a human to avoid split-brain. This negatively impacts availability and scales poorly. Human operators are likely to be overloaded during the same large infrastructure problems that cause primary-secondary communication issues.

### Case Study 3: Faulty Group-Membership Algorithms

A system uses a gossip protocol for cluster discovery and leader election. In a network partition, each side incorrectly elects a master and accepts writes, leading to split-brain and data corruption.

**Key insight:** Master election, group membership, distributed locking and leasing, reliable distributed queuing, and maintenance of any critical shared state are all versions of distributed consensus. All must be solved using formally proven distributed consensus algorithms.

## How Distributed Consensus Works

The relevant variant for software systems is **asynchronous distributed consensus**, which applies to environments with potentially unbounded delays in message passing.

Algorithms may be:
- **Crash-fail** (crashed nodes never return) or **crash-recover** (more useful, as most real-world problems are transient)
- Byzantine or non-Byzantine (Byzantine failures occur when processes pass incorrect messages due to bugs or malicious activity; comparatively costly to handle)

The **FLP impossibility result** proves that no asynchronous distributed consensus algorithm can guarantee progress in the presence of an unreliable network. In practice, we approach the problem in bounded time by ensuring sufficient healthy replicas and network connectivity, plus backoffs with randomized delays to prevent retry cascade effects and avoid dueling proposers.

**Protocols:** Paxos (original solution), Raft, Zab, Mencius.

## Paxos Overview

Paxos operates as a sequence of proposals. Each proposal has a sequence number imposing strict ordering on all operations.

Phase 1: Proposer sends a sequence number to acceptors. Each acceptor agrees only if it hasn't seen a higher sequence number.

Phase 2: If a proposer receives agreement from a majority, it commits the proposal by sending a commit message with a value.

The requirement for a majority to commit means two different values cannot be committed for the same proposal (any two majorities overlap in at least one node). Acceptors must write a journal on persistent storage whenever they agree.

## System Architecture Patterns for Distributed Consensus

Distributed consensus algorithms are low-level primitives. Higher-level components (datastores, configuration stores, queues, locking, leader election) make them useful. Many systems use consensus as clients of services that implement those algorithms: **Zookeeper, Consul, etcd** (open source); **Chubby** (Google internal).

### Reliable Replicated State Machines (RSM)

An RSM executes the same set of operations, in the same order, on several processes. The consensus algorithm deals with agreement on the sequence of operations; the RSM executes the operations in that order. RSMs are the fundamental building block of distributed systems components. Any deterministic program can be implemented as a highly available replicated service by being implemented as an RSM.

### Leader Election

Leader election is equivalent to distributed consensus. Design a highly available service by replicating the process and using leader election to ensure only one leader is working at any point. This pattern was used in GFS and Bigtable. Unlike replicated datastores, the consensus algorithm is not in the critical path of the main work, so throughput is usually not a major concern.

### Distributed Coordination and Locking

**Barriers:** Block a group of processes from proceeding until a condition is met (e.g., all parts of one phase of a MapReduce complete). Can be implemented as an RSM.

**Locks:** Prevent multiple workers from processing the same input file. Use renewable leases with timeouts instead of indefinite locks—prevents locks being held indefinitely by crashed processes. Most applications should use higher-level systems providing distributed transactions, not raw distributed locks.

### Reliable Distributed Queuing and Messaging

Queue as RSM minimizes the risk of queue loss. Implementing the queue as an RSM makes the entire system far more robust.

**Atomic broadcast:** Messages are received reliably and in the same order by all participants. Equivalent to consensus (proven by Chandra and Toueg).

## Distributed Consensus Performance

Conventional wisdom held that consensus algorithms are too slow for high-throughput/low-latency systems. This is simply not true—while implementations can be slow, there are many tricks to improve performance.

### Multi-Paxos Message Flow

Multi-Paxos uses a **strong leader process**: in steady state, only one round trip from proposer to a quorum of acceptors is needed. Changing the proposer has a performance cost and may cause a **dueling proposers** situation (a form of livelock) where proposals repeatedly interrupt each other indefinitely.

Solutions: elect a proposer that makes all proposals, or use a rotating proposer allocating specific slots per process. Leader election must be carefully tuned with appropriate timeouts, backoff strategies, and randomness.

### Scaling Read-Heavy Workloads

If strong consistency isn't required for all reads, data can be read from any replica. **Quorum leases** grant a read lease on a subset of data to a quorum of replicas for a brief time. Any state change to that data must be acknowledged by all replicas in the read quorum. Particularly useful for read-heavy workloads concentrated in a single region.

### Performance Constraints

1. **Network round-trip time:** Within a single datacenter: ~1ms. Cross-continental (US): ~45ms. Transatlantic: ~70ms.

2. **Disk writes:** Required so crashed-and-restarted nodes honor previous commitments. Typically 1–several milliseconds. If disk write time dominates, latency = one disk write on proposer + parallel messages to acceptors + parallel disk writes at acceptors + return messages.

At 10ms per disk write, rate is limited to ~100 consensus operations/second. Combining consensus and RSM transaction logs into a single log avoids alternating between two physical disk locations, improving throughput.

**Batching + pipelining:** Batching amortizes fixed costs over more operations. Pipelining keeps multiple proposals in-flight, solving idle replica problem.

### Fast Paxos

Clients send Propose messages directly to all acceptors (skipping leader). Despite intuition, Fast Paxos can be slower than Classic Paxos when clients have high RTT to acceptors but acceptors have fast connections to each other—due to the latency tail effect.

### Stable Leaders

Used in Multi-Paxos, Zab, Raft for performance. Drawbacks: all state-changing operations must go via leader (adds latency for distant clients), leader's outgoing bandwidth is a system bottleneck, leader performance problems affect entire system throughput.

## Deploying Distributed Consensus-Based Systems

### Number of Replicas

Majority quorum systems: 2f+1 replicas tolerate f failures. Byzantine fault tolerance: 3f+1 replicas tolerate f failures.

- **3 replicas:** Minimum for any failure tolerance; allows maintenance with one down.
- **5 replicas:** Recommended—allows system to operate with up to two failures. No intervention required with 4/5 healthy; if 3 remain, add replicas.

If a consensus system loses so many replicas it cannot form a quorum, it is theoretically in an unrecoverable state. Administrators may be able to force group membership changes, but possibility of data loss remains.

The **replicated log** is critical in production: replicas that miss consensus decisions due to failure must catch up. Raft explicitly defines how log gaps are filled.

Decision factors for number of replicas: reliability needs, planned maintenance frequency, risk tolerance, performance requirements, cost.

### Location of Replicas

**Failure domain:** The set of components that can become unavailable due to a single failure (machine, rack, datacenter, geographic region).

As distance between replicas increases, round-trip time increases and the system can tolerate larger failures—but operations incur higher latency.

Key considerations:
- Client perception is the most important performance measure; minimize RTT from clients to consensus replicas.
- Disaster recovery: back up regular snapshots even for solid consensus-based systems deployed in diverse failure domains (software bugs and human error can never be escaped).
- Over wide area networks, leaderless protocols like Mencius or Egalitarian Paxos may have a performance edge.

**Quorum composition over geographic regions:** Simple majority quorums can have a "linchpin" replica acting as a link between regions. Loss of the linchpin dramatically increases RTT for any quorum. **Hierarchical quorums** (e.g., 9 replicas in 3 groups of 3) reduce reliance on any single replica.

### Capacity and Load Balancing

- Sharded deployments: adjust capacity by adjusting shard count.
- Read-heavy workloads: add more replicas to increase read capacity (but in leader-based algorithms, adds load on the leader).
- **Adding a replica in a majority quorum can decrease availability:** 6th replica reduces tolerance from 40% unavailability to 33%. Consider failure domain effects carefully before adding replicas.
- Balance leader processes across datacenters in highly sharded systems to avoid bandwidth bottlenecks and to prevent dramatic network utilization changes when a datacenter hosting many leaders fails.

## Monitoring Distributed Consensus Systems

Critical monitoring items:
- **Number of members and health status** per consensus group
- **Persistently lagging replicas** (recovering state, lagging behind quorum)
- **Whether a leader exists** (Multi-Paxos without a leader is totally unavailable)
- **Number of leader changes** (rapid changes impair performance; flapping signals network issues; decreasing view number signals a serious bug)
- **Consensus transaction number** (must be increasing if healthy)
- **Proposals seen vs. agreed upon**
- **Throughput and latency**

Additional performance monitoring:
- Latency distributions for proposal acceptance
- Network latency distributions between system parts
- Time acceptors spend on durable logging
- Overall bytes accepted per second

## Conclusion

Many distributed systems problems turn out to be different versions of distributed consensus: master election, group membership, distributed locking/leasing, reliable distributed queuing, maintenance of critical shared state. All must be solved using formally proven distributed consensus algorithms.

**The key takeaway:** Whenever you see leader election, critical shared state, or distributed locking—think about distributed consensus. Any lesser approach (heartbeats, gossip protocols) is a ticking bomb waiting to explode in your systems.
