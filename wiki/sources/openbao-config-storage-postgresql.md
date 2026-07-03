---
title: "OpenBao — PostgreSQL Storage Config"
tags: [openbao, configuration, storage, postgresql, high-availability]
sources: [openbao-config-storage-postgresql.md]
updated: 2026-07-03
---

# OpenBao — PostgreSQL Storage Config

The `storage "postgresql"` stanza — persisting [OpenBao](../entities/openbao.md) data in PostgreSQL. The main external-storage alternative to [Raft](openbao-config-storage-raft.md).

## Key Takeaways

- Stores data in a PostgreSQL server/cluster (**min version 9.5**; legacy upsert dropped in v2.4.0). **HA-capable** and production-ready (paginated lists, transactional storage).
- **Required:** `connection_url` (or `BAO_PG_CONNECTION_URL`; standard `PG*` env vars supported). **SSL is attempted by default** — must set `?sslmode=disable` to turn off (recommend `sslmode=verify-full`).
- **Params:** `table` (`openbao_kv_store`), `ha_enabled`, `ha_table` (`openbao_ha_locks`), `max_parallel` (128), `max_idle_connections`, `skip_create_table` (set true when the DB user lacks DDL rights — then create tables manually), `max_connect_retries`.
- OpenBao auto-creates the `openbao_kv_store` (+ index) and `openbao_ha_locks` tables unless `skip_create_table=true`; manual schemas are documented.
- Trade-off vs Raft: an extra network hop and a separately-operated, separately-monitored datastore.

## Related

- [Raft storage](openbao-config-storage-raft.md)
- [Server config](openbao-config.md)
- [High Availability](../concepts/openbao-high-availability.md)
- [OpenBao](../entities/openbao.md)
