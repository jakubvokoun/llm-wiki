---
title: "Database Security"
tags: [database, sql, hardening, least-privilege, tls, credentials]
sources: [owasp-database-security.md]
updated: 2026-04-16
---

# Database Security

Database security covers the configuration, access control, network isolation, and hardening of database systems to protect data from unauthorized access, tampering, and exfiltration.

## Threat Landscape

- Direct network access to exposed database port.
- Credentials in source code or config files.
- Overprivileged application accounts.
- Unencrypted connections interceptable by MITM.
- Dangerous built-in stored procedures enabling OS command execution.
- Default accounts and sample databases left active.

## Network Isolation

- Bind database to `localhost` only; disable TCP access where possible.
- Firewall: restrict database port to specific application server IPs.
- DMZ separation: database server behind application server.
- Protect admin web UIs (phpMyAdmin, pgAdmin) with auth + HTTPS + network restrictions.
- **No direct thick-client → database connections** — always use an API layer.

## Transport Layer Protection

- Force TLS 1.2+ for all connections.
- Install trusted TLS certificate on the server.
- Client must verify the certificate — no certificate bypass.
- Enforce strong ciphers (AES-GCM, ChaCha20).

## Authentication & Credential Management

- Every database account must have a strong, unique password.
- One account per service/application.
- Regularly audit and rotate credentials.
- Remove accounts when services are decommissioned.
- Store credentials outside web root, outside version control, with restricted permissions.
- Use platform-level encryption for credential config files.
- Prefer OS-integrated auth (Windows Auth for MSSQL) where available — eliminates stored credentials.

## Least Privilege

- Never use `root`/`sa`/`SYS` accounts for applications.
- Grant minimum permissions: usually `SELECT`, `UPDATE`, `DELETE` only.
- Application account must NOT own the database (prevents privilege escalation).
- Separate databases and accounts per environment (dev / UAT / prod).
- Advanced: table-level, column-level, row-level permissions; restrict via views.

## OS and Database Hardening

- Baseline OS with CIS Benchmarks or Microsoft Security Baselines.
- Apply all patches promptly.
- Run database service under a low-privileged dedicated account.
- Remove default accounts and sample databases.
- Store transaction logs on a separate disk.
- Regular encrypted backups with access controls.

**MSSQL:** disable `xp_cmdshell`, `xp_dirtree`, CLR, SQL Browser; remove Northwind/AdventureWorks.\
**MySQL/MariaDB:** `mysql_secure_installation`; disable FILE privilege.

## Relationship to Other Controls

- **SQL Injection Prevention:** application-layer defense (parameterized queries). Database security is infrastructure-layer.
- **Secrets Management:** vault-based storage of DB credentials.
- **RBAC:** role-based permissions at the database and schema level.
- **Zero Trust:** database accounts and network access treated as untrusted by default.

## Related Pages

- [Secrets Management](secrets-management.md)
- [RBAC](rbac.md)
- [Zero Trust Architecture](zero-trust.md)
- [OWASP Database Security source](../sources/owasp-database-security.md)
