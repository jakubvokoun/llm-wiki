---
title: "OpenBao — High Availability"
tags: [openbao, high-availability, clustering, request-forwarding, storage]
sources:
  [
    openbao-concept-ha.md,
    openbao-internals-high-availability.md,
    openbao-config-storage-raft.md,
    openbao-config-storage-postgresql.md,
  ]
updated: 2026-07-03
---

# OpenBao — High Availability

Running multiple [OpenBao](../entities/openbao.md) servers to survive outages. HA is enabled automatically when the storage backend supports it (look for "(HA available)" at startup). See the [internals summary](../sources/openbao-internals-high-availability.md).

## Active / standby model

Nodes grab a **lock** in the data store; the winner becomes **active** and processes all requests, the rest are **standby** (hot). HA does **not** add scalability — the bottleneck is the data store, not OpenBao core. Only unsealed nodes can stand by; only active nodes run cluster listeners. On active-node failure a standby takes over.

## How standbys handle requests

- **Request forwarding** (default): the active node advertises (via encrypted storage) a generated ECDSA-P521 key + self-signed cert; standbys open a **mutually-authenticated TLS 1.2** channel over the cluster address and forward serialized client requests to the active node.
- **Client redirection** (fallback, or `X-Vault-No-Request-Forwarding` header): standbys return a `307` to the active node's redirect address. A redirect address is therefore always required.

## Required addresses

- **`api_addr`** — full URL a client is redirected to. Direct access: each node advertises its own address. Behind an LB with only-LB access: all nodes share the LB address (can cause redirect loops — avoid when possible).
- **`cluster_addr`** — host/port a standby uses to reach the active node's cluster listener (always forced to `https`). Per-listener `cluster_address` defaults to `address` port + 1 (`8201`).

## Storage support

Officially HA-capable backends: [Integrated Storage (Raft)](openbao-integrated-storage.md) (recommended default) and [PostgreSQL](../sources/openbao-config-storage-postgresql.md). Split mode is possible via separate `storage` + `ha_storage` stanzas (e.g. Consul for the lock, S3 for data) — but **not** with raft, which cannot declare a separate `ha_storage`.

## Related

- [Integrated Storage (Raft)](openbao-integrated-storage.md)
- [Internals: HA](../sources/openbao-internals-high-availability.md)
- [PostgreSQL storage](../sources/openbao-config-storage-postgresql.md)
- [K8s service registration](../sources/openbao-config-service-registration-kubernetes.md)
- [OpenBao](../entities/openbao.md)
- [source summary](../sources/openbao-concept-ha.md)
