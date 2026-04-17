---
title: "OWASP Database Security Cheat Sheet"
tags: [owasp, database, sql, least-privilege, hardening]
sources: [owasp-database-security.md]
updated: 2026-04-16
---

# OWASP Database Security Cheat Sheet

Source: OWASP Cheat Sheet Series — Database Security

## Key Takeaways

Covers secure configuration of relational databases (MySQL, PostgreSQL, MariaDB, MSSQL). Complements SQL Injection Prevention (application-layer) and NoSQL Security cheat sheets.

## Network Isolation

- Disable TCP access; use local socket/named pipe only where possible.
- Bind database to localhost only.
- Firewall-restrict the database port to specific hosts.
- Place database in separate DMZ from application server.
- Protect management tools (phpMyAdmin, pgAdmin) with auth + HTTPS + network restrictions.
- **Never** connect a thick client directly to the database — always via an API.

## Transport Layer Protection

Databases default to unencrypted connections. Require:

- Encrypted connections only (server and client config).
- Trusted TLS certificate on the server.
- Client uses TLSv1.2+ with modern ciphers (AES-GCM, ChaCha20).
- Client verifies the server certificate.

## Authentication

- Always require authentication, including from localhost.
- One account per application/service — strong, unique passwords.
- Regularly review accounts and permissions; remove decommissioned accounts.
- Rotate credentials when staff leave or compromise suspected.
- MSSQL: prefer Windows/Integrated Authentication (no stored credentials).

## Credential Storage

- Never in source code.
- Store in config file: outside web root, restricted permissions, not version-controlled.
- Encrypt using platform mechanisms (ASP.NET protected config, etc.).

## Least Privilege

- No `root`/`sa`/`SYS` accounts for applications.
- No admin rights on the database instance.
- Restrict connection source to `localhost` or app server IP.
- Separate databases + accounts per environment (dev / UAT / prod).
- Grant only `SELECT`, `UPDATE`, `DELETE` as needed — account should NOT own the database.
- For high-security: table-level, column-level, row-level permissions; restrict via views.

## OS and DB Hardening

OS baseline: CIS Benchmarks or Microsoft Security Baselines.

General:

- Apply all security patches.
- Run DB service under low-privileged account.
- Remove default accounts and sample databases.
- Store transaction logs on a separate disk.
- Regular encrypted backups with access controls.

### MSSQL Specifics

- Disable `xp_cmdshell`, `xp_dirtree`, unneeded stored procs.
- Disable CLR execution.
- Disable SQL Browser service.
- Disable Mixed Mode Auth unless needed.
- Remove Northwind / AdventureWorks sample DBs.

### MySQL / MariaDB Specifics

- Run `mysql_secure_installation`.
- Disable FILE privilege for all users.

### PostgreSQL

- Follow official Server Setup and Operation docs.

## Related Pages

- [Database Security concept](../concepts/database-security.md)
- [Secrets Management](../concepts/secrets-management.md)
- [RBAC](../concepts/rbac.md)
- [Zero Trust Architecture](../concepts/zero-trust.md)
