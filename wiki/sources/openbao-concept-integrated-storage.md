---
title: "OpenBao — Integrated Storage (concept)"
tags: [openbao, integrated-storage, raft, clustering, tls]
sources: [openbao-concept-integrated-storage.md]
updated: 2026-07-03
---

# OpenBao — Integrated Storage (concept)

Operating a Raft cluster — source summary. Full synthesis: [Integrated Storage (Raft)](../concepts/openbao-integrated-storage.md).

## Key Takeaways

- Native, no third-party deps; replicates data to every node; requires `cluster_addr`. Inter-node **mTLS on cluster port 8201**, certs exchanged at join and rotated.
- **Join** an uninitialized node with the same seal config: `retry_join` config (leader addr or cloud `auto_join`) or `bao operator raft join`. Auto-unseal joins automatically; Shamir needs manual unseal. **Non-voter** nodes add read-scaling.
- Manage peers: `list-peers`, `remove-peer`. A joined node can't re-join a different cluster.
- **Join challenge uses the API port** (chicken-and-egg before the cluster exists) — the only such case. Auto-join+TLS caveat (IPs not in cert SANs) → use `leader_tls_servername`, subnet IP SANs, or an LB target.
- **Outage recovery:** quorum kept → recover/`remove-peer`; quorum lost → hand-written `raft/peers.json` on survivors (may implicitly commit entries → possible data loss).

## Related

- [Integrated Storage (Raft)](../concepts/openbao-integrated-storage.md)
- [High Availability](../concepts/openbao-high-availability.md)
- [Raft storage config](openbao-config-storage-raft.md)
- [OpenBao](../entities/openbao.md)
