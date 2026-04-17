# Database Security Cheat Sheet

## Introduction

Guidance for securely configuring SQL databases such as MySQL, PostgreSQL, MariaDB, and Microsoft SQL Server. Primarily for application developers and system administrators.

For application-layer injection defenses, see the SQL Injection Prevention Cheat Sheet.
For non-relational systems (MongoDB, Redis, Cassandra, DynamoDB), see the NoSQL Security Cheat Sheet.

## Protecting the Backend Database

Isolate the database from other servers and connect with as few hosts as possible:

* Disable network (TCP) access; require local socket file or named pipe access only.
* Configure database to bind on localhost only.
* Restrict network port access to specific hosts with firewall rules.
* Place database server in a separate DMZ isolated from the application server.
* Protect web-based management tools (phpMyAdmin, pgAdmin) with authentication, HTTPS, and network restrictions.

**Never connect from a thick client directly to a backend database** — always connect through an API that enforces access control.

## Implementing Transport Layer Protection

Most database default configs use unencrypted connections. Steps to prevent unencrypted traffic:

* Configure database to only allow encrypted connections.
* Install a trusted digital certificate on the server.
* Client application connects using TLSv1.2+ with modern ciphers (AES-GCM or ChaCha20).
* Client application verifies the digital certificate.

## Configuring Secure Authentication

Database should always require authentication, including connections from localhost. Accounts should be:

* Protected with strong, unique passwords.
* Used by a single application or service.
* Configured with minimum required permissions.

Account management processes:
* Regular reviews of accounts and permissions.
* Remove accounts when applications are decommissioned.
* Change passwords when staff leave or credentials may be compromised.

For MSSQL: consider Windows/Integrated Authentication. For MySQL: Windows Native Authentication Plugins.

## Storing Database Credentials Securely

Never store credentials in application source code. Store in a config file that:

* Is outside of the web root.
* Has appropriate permissions (read only by required user(s)).
* Is not checked into source code repositories.

Encrypt credentials using built-in functionality (e.g., ASP.NET `web.config` encryption).

## Creating Secure Permissions (Least Privilege)

* Do not use built-in `root`, `sa`, or `SYS` accounts.
* Do not grant administrative rights over the database instance.
* Restrict connections to allowed hosts (typically `localhost` or app server address).
* Use separate databases and accounts for dev, UAT, and production.
* Grant only required permissions — most apps need only `SELECT`, `UPDATE`, `DELETE`.
* Account should NOT be the database owner (prevents privilege escalation).
* Avoid database links/linked servers; if required, grant minimum needed access.

For high-security applications, apply table-level, column-level, row-level permissions, and restrict access via views.

## Database Configuration and Hardening

OS should be hardened using CIS Benchmarks or Microsoft Security Baselines.

General hardening for any database:
* Install all security updates and patches.
* Run database services under a low-privileged user account.
* Remove default accounts and databases.
* Store transaction logs on a separate disk from main database files.
* Configure regular encrypted backups with appropriate permissions.

### Microsoft SQL Server

* Disable `xp_cmdshell`, `xp_dirtree`, and other unneeded stored procedures.
* Disable Common Language Runtime (CLR) execution.
* Disable the SQL Browser service.
* Disable Mixed Mode Authentication unless required.
* Remove sample Northwind and AdventureWorks databases.

### MySQL / MariaDB

* Run `mysql_secure_installation` to remove default databases and accounts.
* Disable the FILE privilege for all users.

### PostgreSQL

* Follow PostgreSQL Server Setup and Operation documentation.

### MongoDB

* See NoSQL Security Cheat Sheet and MongoDB security checklist.

### Redis

* See Redis security guide.
