---
title: "OpenBao — Storage (concept)"
tags: [openbao, storage, backups, snapshots, disaster-recovery]
sources: [openbao-concept-storage.md]
updated: 2026-07-03
---

# OpenBao — Storage (concept)

The storage backend holds [OpenBao](../entities/openbao.md)'s **encrypted** (untrusted) data. Backend choice: see [Integrated Storage (Raft)](../concepts/openbao-integrated-storage.md) vs PostgreSQL. This page focuses on backups.

## Key Takeaways

- **Two things to back up:** the encrypted data in the storage backend, and the server config files / management scripts / plugins.
- **Take backups before (not during) major changes** — especially before upgrades (downgrades aren't always possible) and before writes to most `/sys` endpoints.
- Backups are **not** a substitute for [HA](../concepts/openbao-high-availability.md): use HA (multi-AZ) against machine/AZ failure; use backups against data-center loss and accidental deletion.
- Prefer **offline** backups, or a backend with **atomic snapshots** (Integrated Storage `bao operator raft snapshot`). No built-in automation — the [openbao-snapshot-agent](https://github.com/openbao/openbao-snapshot-agent) repo provides VM systemd/cron and a Kubernetes CronJob (deployable via Helm).
- Config backups may contain sensitive data (Transit autoseal token, TLS private key) — protect them.

## Related

- [Integrated Storage (Raft)](../concepts/openbao-integrated-storage.md)
- [High Availability](../concepts/openbao-high-availability.md)
- [Raft storage config](openbao-config-storage-raft.md)
- [OpenBao](../entities/openbao.md)
