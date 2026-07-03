---
title: "OpenBao — Audit Config (declarative audit devices)"
tags: [openbao, configuration, audit, logging]
sources: [openbao-config-audit.md]
updated: 2026-07-03
---

# OpenBao — Audit Config (declarative audit devices)

Defining [audit devices](https://openbao.org/docs/audit/) from the [OpenBao](../entities/openbao.md) [server config file](openbao-config.md).

## Key Takeaways

- The `audit` stanza declares audit devices in config; they're created/removed on the **active node** during restarts and `SIGHUP`.
- Config-declared devices **cannot be modified via API** and cannot duplicate an existing API-created device. Removing the stanza removes the device — keep config identical across all servers.
- Two keyword parameters: `type` (device type, e.g. `file`) and `path` (device path in the root namespace); plus top-level `description` and an `options` string→string map (same params as the API).
- Multiple `audit` stanzas run in file order; no two may share a `path`.

```hcl
audit "file" "to-stdout" {
  description = "This audit device should never fail."
  options {
    file_path = "/dev/stdout"
    log_raw   = "true"
  }
}
```

## Related

- [Server config](openbao-config.md)
- [Self-initialization](openbao-config-self-init.md)
- [Security model](openbao-internals-security.md)
- [OpenBao](../entities/openbao.md)
