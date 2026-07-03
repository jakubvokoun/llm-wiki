---
title: "OpenBao — Integrated Storage (internals)"
tags: [openbao, integrated-storage, raft, consensus, internals]
sources: [openbao-internals-integrated-storage.md]
updated: 2026-07-03
---

# OpenBao — Integrated Storage (internals)

The Raft-based [Integrated Storage](../concepts/openbao-integrated-storage.md) backend of [OpenBao](../entities/openbao.md).

## Key Takeaways

- **Native, dependency-free** storage backend implementing HA and backup/restore; uses the **Raft** consensus protocol for CAP-consistency.
- **Terminology:** Leader (the active node, ingests + replicates log entries), Log (ordered replicated entries), FSM (deterministic state machine — OpenBao uses **BoltDB**), Peer set, **Quorum** (majority; `(n+1)/2`), Committed entry (durably stored on a quorum).
- **Node states:** follower → candidate → leader (election on vote quorum).
- **Log compaction** via snapshots; BoltDB makes snapshots lightweight (data already persisted, so snapshotting just truncates the raft log). All raft data is still encrypted by the barrier.
- **Join** uses an encrypted challenge/answer; all nodes must share the **same seal config** (auto-unseal answers automatically; Shamir requires unseal keys before joining).
- **Quorum/failure tolerance:** 3 nodes tolerate 1 failure, 5 tolerate 2. **Recommended production = 5 nodes**; single-node is strongly discouraged. Scale in **pairs** and keep an **odd** voter count.
- **Autopilot** (enabled by default) manages voter eligibility, stabilization of new nodes (non-voter until synced), and dead-server cleanup.

## Deployment table

| Servers | Quorum | Failure tolerance |
| ------- | ------ | ----------------- |
| 3       | 2      | 1                 |
| 5       | 3      | 2                 |
| 7       | 4      | 3                 |

## Related

- [Integrated Storage (Raft)](../concepts/openbao-integrated-storage.md)
- [High Availability](../concepts/openbao-high-availability.md)
- [raft storage config](openbao-config-storage-raft.md)
- [OpenBao](../entities/openbao.md)
