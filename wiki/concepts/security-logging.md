---
title: "Security Logging"
tags: [logging, security, monitoring, siem, audit, log-injection, observability]
sources: [owasp-logging.md]
updated: 2026-04-16
---

# Security Logging

Security logging is the practice of recording security-relevant events in applications and infrastructure to enable detection, investigation, and response to security incidents. **Insufficient Logging & Monitoring is OWASP Top 10 2021 A09.**

Application logging provides context unavailable to infrastructure-level logging: user identity, roles, permissions, business action context.

## Purpose

**Operational:** debugging, performance monitoring, business process monitoring, baselining.

**Security:** incident detection, policy violation monitoring, audit trails, non-repudiation support, compliance, litigation support, attack detection.

## What to Log

### Always Log

- Input and output validation failures
- Authentication successes and failures
- Authorization (access control) failures
- Session management failures
- Application errors and system events (startup/shutdown, connectivity)
- High-risk operations:
  - User admin actions (add/delete users, privilege changes)
  - Administrative access
  - Break-glass account usage
  - Sensitive data access (PII, payment data)
  - Cryptographic key use / rotation
  - Deserialization failures
- Consent and legal opt-ins/opt-outs
- Suspicious business logic (out-of-order flows, limit bypass attempts)

### Never Log Directly (mask/hash/encrypt)

- Passwords and authentication credentials
- Session tokens and access tokens
- Encryption keys
- PII beyond what is necessary (health data, government IDs)
- Payment card data
- Database connection strings
- Application source code

## Event Attributes

Every log entry must capture **"When, Where, Who, What"**:

| Dimension | Fields                                                             |
| --------- | ------------------------------------------------------------------ |
| **When**  | Log timestamp, event timestamp, interaction ID                     |
| **Where** | App name/version, server address, service, URL/page, code location |
| **Who**   | Source IP/device, user identity (if authenticated)                 |
| **What**  | Event type, severity, security flag, description                   |

**Interaction Identifier:** A correlating ID linking all events within a single user interaction (e.g., all validation failures from one form submission). Critical for reconstructing attack sequences.

**Severity levels:** `{emergency, alert, critical, error, warning, notice, info, debug}` or equivalent. Standardize and document.

## Log Injection Prevention

User-supplied data written to logs can contain newlines (CR/LF) or delimiter characters that cause log forging. Mitigations:

- Sanitize all user-controlled data before logging (strip/encode CR, LF, delimiters)
- Use structured logging formats (JSON) rather than concatenated strings
- Validate and encode for the output format

## Storage Architecture

Centralized logging is the recommended architecture:

- Business app segments write to a **log collector** (separate network segment)
- Log collector persists to **log storage** (separate segment, restricted access)
- Log viewer/UI in a separate segment
- Logs flow one-way: app → collector → storage → viewer

Storage security:

- Separate filesystem partition from OS and application data
- Strict file permissions (not web-accessible)
- Separate DB account with write-only permissions for DB-backed logging
- Standard formats (CEF, CLFS) over syslog for inter-system transport

## Protection

**At rest:** tamper detection, write to read-only media promptly, restrict and audit all access.

**In transit:** secure transmission protocol (TLS) for log data sent over untrusted networks.

## Attacks on Logs

| Attack Type         | Threat                                                                                  |
| ------------------- | --------------------------------------------------------------------------------------- |
| **Confidentiality** | Unauthorized read of PII, secrets, or sensitive business data                           |
| **Integrity**       | Modification/deletion to cover tracks; exploitable platform vulnerabilities (Log4Shell) |
| **Availability**    | Log flooding to exhaust disk space or degrade application performance                   |
| **Accountability**  | Preventing writes or logging wrong identity to conceal attacker                         |

## Compliance and Retention

Log retention must satisfy legal, regulatory, and contractual obligations:

- PCI DSS requires 12 months (3 months immediately available)
- SOC 2 and other frameworks have their own requirements
- Logs must not be destroyed before the required period or kept beyond it

## Related Pages

- [CI/CD Security](cicd-security.md)
- [Microservices Security](microservices-security.md)
- [Authorization](authorization.md)
- [OWASP Logging Cheat Sheet](../sources/owasp-logging.md)
