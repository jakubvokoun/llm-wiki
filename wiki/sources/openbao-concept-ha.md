---
title: "OpenBao — High Availability (concept)"
tags: [openbao, high-availability, clustering, request-forwarding]
sources: [openbao-concept-ha.md]
updated: 2026-07-03
---

# OpenBao — High Availability (concept)

Source summary. Full synthesis: [High Availability](../concepts/openbao-high-availability.md).

## Key Takeaways

- Auto-enabled with an HA-capable data store ("(HA available)" at startup). One node holds a **lock** → active; others are standby. HA is for availability, **not** scalability.
- Standbys either **forward requests** (default; mutually-authenticated TLS 1.2 to the active node) or **redirect** the client (`307` to `api_addr`).
- Requires `api_addr` (client redirect URL) and `cluster_addr` (server-to-server, always `https`, default port `8201`).
- Officially HA-supporting storage: [Integrated Storage (Raft)](../concepts/openbao-integrated-storage.md) and PostgreSQL; split `storage`/`ha_storage` allowed except with raft.

## Related

- [High Availability](../concepts/openbao-high-availability.md)
- [Integrated Storage](../concepts/openbao-integrated-storage.md)
- [OpenBao](../entities/openbao.md)
