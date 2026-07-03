---
title: "OpenBao — High Availability (internals)"
tags: [openbao, high-availability, internals]
sources: [openbao-internals-high-availability.md]
updated: 2026-07-03
---

# OpenBao — High Availability (internals)

The internals design of [OpenBao](../entities/openbao.md)'s [High Availability](../concepts/openbao-high-availability.md) mode.

## Key Takeaways

- HA runs multiple OpenBao servers to minimize downtime without hurting horizontal scalability. OpenBao is bound by the storage backend's **IO limits**, not compute — which keeps the HA approach simple.
- HA requires a storage backend that provides **coordination** (e.g. Integrated Storage). With such a backend, HA runs automatically without extra configuration.
- **Two states:** exactly one **active** node processes all requests; **standby** nodes hot-standby and redirect requests to the active node.
- On active-node seal/failure/network loss, a standby is promoted to active.
- Only **unsealed** servers can act as standby; a sealed server cannot serve or take over.

## Related

- [High Availability](../concepts/openbao-high-availability.md)
- [Integrated Storage (Raft)](../concepts/openbao-integrated-storage.md)
- [OpenBao](../entities/openbao.md)
