---
title: "OpenBao — Raft Storage Config"
tags:
  [openbao, configuration, storage, raft, integrated-storage, high-availability]
sources: [openbao-config-storage-raft.md]
updated: 2026-07-03
---

# OpenBao — Raft Storage Config

The `storage "raft"` stanza — configuring [Integrated Storage](../concepts/openbao-integrated-storage.md) for [OpenBao](../entities/openbao.md). The recommended production backend.

## Key Takeaways

- Every node keeps a **replicated copy** of data via the [Raft](../concepts/openbao-integrated-storage.md) algorithm; HA and production-ready (paginated lists, transactional storage).
- **Required:** `path` (data dir, `VAULT_RAFT_PATH`) and `node_id` (`VAULT_RAFT_NODE_ID`); plus `cluster_addr` for inter-node communication. A separate `ha_storage` **cannot** be declared with raft.
- **Tuning:** `performance_multiplier` (1 = highest performance, recommended for prod; default ~5), `trailing_logs`, `snapshot_threshold`, `snapshot_interval` (120s), `max_entry_size` (1 MiB), `max_transaction_size` (8 MiB), `autopilot_reconcile_interval`/`autopilot_update_interval`.
- **`retry_join` stanza** (one or more) auto-locates the leader so nodes self-join: either a `leader_api_addr` + TLS cert params, or a cloud `auto_join` (go-discover, e.g. `provider=aws region=... tag_key=...`). With Shamir seal, joined nodes still need manual unseal.
- `retry_join_as_non_voter` (or `-non-voter`) adds read-scaling replicas that don't count toward quorum.

```hcl
storage "raft" {
  path    = "/openbao/data"
  node_id = "node1"
  retry_join { leader_api_addr = "https://10.0.0.2:8200" }
}
cluster_addr = "https://10.0.0.1:8201"
```

## Related

- [Integrated Storage (Raft)](../concepts/openbao-integrated-storage.md)
- [Integrated Storage (internals)](openbao-internals-integrated-storage.md)
- [PostgreSQL storage](openbao-config-storage-postgresql.md)
- [High Availability](../concepts/openbao-high-availability.md)
