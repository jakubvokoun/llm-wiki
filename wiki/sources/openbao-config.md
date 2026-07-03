---
title: "OpenBao — Server Configuration (overview)"
tags: [openbao, configuration, hcl, server]
sources: [openbao-config.md]
updated: 2026-07-03
---

# OpenBao — Server Configuration (overview)

The top-level server configuration file for [OpenBao](../entities/openbao.md) (outside dev mode). See upstream [configuration docs](https://openbao.org/docs/configuration/).

## Key Takeaways

- **Format:** [HCL](https://github.com/hashicorp/hcl) or JSON; may be a **directory** of `.hcl`/`.json` files loaded alphabetically. List types (e.g. multiple `listener`s) are appended; non-list duplicates → last wins. Start with `bao server -config=<path>`.
- **Required stanzas:** [`storage`](openbao-config-storage-raft.md) (backend) and [`listener`](openbao-config-listener-tcp.md). Optional: [`seal`](openbao-config-seal.md), [`service_registration`](openbao-config-service-registration-kubernetes.md), [`telemetry`](openbao-config-telemetry.md), [`audit`](openbao-config-audit.md), [`initialize`](openbao-config-self-init.md), [`plugin`](openbao-config-plugins.md), [`user_lockout`](https://openbao.org/docs/configuration/user-lockout/).
- **HA parameters:** `api_addr` (client-redirect URL), `cluster_addr` (request-forwarding URL, always TLS), `disable_clustering` (cannot be true with raft storage).
- **Common params:** `ui` (enable web UI at `/ui`), `default_lease_ttl`/`max_lease_ttl` (`768h`), `default_max_request_duration` (`90s`), `cache_size`, `disable_cache`, `log_level`/`log_format`/`log_file`, `plugin_directory`, `pid_file`.
- **Security-sensitive toggles (default off):** `raw_storage_endpoint`, `introspection_endpoint`, `unsafe_allow_api_audit_creation`. `VAULT_ENABLE_FILE_PERMISSIONS_CHECK` verifies config/plugin ownership & permissions.
- `SIGHUP` reloads config; a valid `log_level` in the file overrides CLI/env on reload.

## Related

- [OpenBao](../entities/openbao.md)
- [listener/tcp](openbao-config-listener-tcp.md)
- [storage/raft](openbao-config-storage-raft.md)
- [seal](openbao-config-seal.md)
- [High Availability](../concepts/openbao-high-availability.md)
