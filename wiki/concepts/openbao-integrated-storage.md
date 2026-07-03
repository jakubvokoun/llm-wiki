---
title: "OpenBao — Integrated Storage (Raft)"
tags: [openbao, integrated-storage, raft, consensus, storage, high-availability]
sources:
  [
    openbao-concept-integrated-storage.md,
    openbao-internals-integrated-storage.md,
    openbao-config-storage-raft.md,
  ]
updated: 2026-07-03
---

# OpenBao — Integrated Storage (Raft)

[OpenBao](../entities/openbao.md)'s native, dependency-free storage backend — the recommended default. Every node keeps a replicated copy of the data on its local filesystem, kept consistent by the **Raft** consensus algorithm. Also see the [internals summary](../sources/openbao-internals-integrated-storage.md) and [raft config](../sources/openbao-config-storage-raft.md).

## Consensus & quorum

Raft elects a **leader** (= the active [HA](openbao-high-availability.md) node); followers are standbys. Writes must be **committed** to a **quorum** (majority, `(n+1)/2`) before being applied to the FSM (BoltDB). Failure tolerance: **3 nodes → 1**, **5 → 2**, **7 → 3**. Production recommendation: **5 nodes**; scale in **pairs**, keep an **odd** voter count. **Autopilot** (on by default) handles voter promotion after a stabilization period and dead-server cleanup.

## Cluster membership

- Bootstraps to a cluster of size 1 on init; other nodes **join** via an encrypted challenge/answer that requires the **same seal config**. Auto-unseal answers automatically; Shamir requires unseal keys before the join completes. A joined node can't later join a different cluster.
- **`retry_join`** (config) lists candidate leaders (`leader_api_addr` + TLS, or a cloud `auto_join` via go-discover) and retries until one becomes active. CLI alternative: `bao operator raft join <leader-api-addr>`.
- **Non-voter** nodes replicate data for read-scaling without counting toward quorum.
- Manage peers with `list-peers` / `remove-peer`.

## Networking & TLS

Requires `cluster_addr`. Inter-node traffic uses **mTLS on the cluster port (8201)**, with certs exchanged at join and rotated. Chicken-and-egg: before the raft cluster exists there's no shared storage, so the join **challenge uses the API port** — the only time OpenBao does this. Auto-join + TLS pitfalls (go-discover returns IPs not in cert SANs) are solved via `leader_tls_servername` matching a DNS SAN, listing subnet IPs in the cert, or using a load balancer as the `retry_join` target.

## Outage recovery

- **Quorum maintained:** recover the failed node with the same address, or `remove-peer` it.
- **Quorum lost:** partial recovery from surviving nodes via a hand-written `raft/peers.json` (implicitly commits outstanding log entries → possible data loss) placed identically on all remaining nodes, then restart. Snapshots via `bao operator raft snapshot`.

## Related

- [High Availability](openbao-high-availability.md)
- [Raft storage config](../sources/openbao-config-storage-raft.md)
- [Internals](../sources/openbao-internals-integrated-storage.md)
- [Seal / Unseal](openbao-seal-unseal.md)
- [OpenBao](../entities/openbao.md)
- [source summary](../sources/openbao-concept-integrated-storage.md)
