---
title: "OWASP Logging Cheat Sheet"
tags: [owasp, logging, security, monitoring, audit, siem, log-injection]
sources: [owasp-logging.md]
updated: 2026-04-16
---

# OWASP Logging Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html

## Key Takeaways

Application logging is frequently missing, disabled, or poorly configured even when infrastructure logging is enabled. **Insufficient Logging & Monitoring is OWASP Top 10 2021 A09**. Application logs provide context unavailable to infrastructure: user identity, roles, permissions, business action context.

## Purpose

### Operational Uses

General debugging, performance monitoring, business process monitoring, baselining.

### Security Uses

Incident detection, policy violation monitoring, audit trails, non-repudiation, compliance, litigation support, attack detection.

## Design Principles

### What to Log (Always)

- Input validation failures (protocol violations, invalid encodings, invalid param names/values)
- Output validation failures
- Authentication successes and failures
- Authorization failures
- Session management failures (suspicious session ID modification, JWT failures)
- Application errors (syntax, runtime, connectivity, performance)
- Application startup/shutdown
- High-risk functionality: user admin actions, admin privilege use, break-glass accounts, sensitive data access, key rotation, deserialization failures
- Legal opt-ins and consent actions
- Suspicious business logic (out-of-order flow, attempts to exceed limits)

### What to Exclude from Logs

Never log directly (must be removed, masked, hashed, or encrypted):

- Application source code
- Session identification values (use hashed equivalent if needed)
- Access tokens
- Sensitive PII (health data, government IDs)
- Authentication passwords
- Database connection strings
- Encryption keys and primary secrets
- Payment card / bank account data
- Data a user has opted out of collection

### Event Attributes — "When, Where, Who, What"

**When:** log timestamp, event timestamp (may differ for offline devices), interaction identifier (links all events in a single user interaction)

**Where:** application name/version, server address/port, service, geolocation, URL/form/page, code location

**Who:** source IP/device identifier, user identity (if authenticated)

**What:** event type, severity, security-relevant flag, description

### Interaction Identifier

Links all events for a single user interaction (e.g., a form submission that triggers multiple validation failures). Critical for reconstructing attack sequences.

## Storage and Architecture

- Prefer a **separate filesystem partition** for logs (not the OS or application partition)
- Apply strict file permissions on log directories and files
- Web-accessible log paths are a vulnerability
- Use a **separate, restricted database account** for database logs
- Use standard formats over secure protocols (CEF, CLFS, syslog)
- **Centralized log collection** (SIEM/SEM) is the recommended architecture: business app segments → log collector → log storage (separate segment) → log UI

## Event Collection

- Input validate event data from untrusted zones
- Sanitize all event data to prevent **log injection** (CR, LF, delimiter characters)
- Encode correctly for the output format
- Synchronize time across all servers
- Failures in logging must not prevent the application from running
- Logging cannot be used to deplete system resources (disk exhaustion = DoS)

## Protection

**At rest:**

- Build in tamper detection
- Write to read-only media as soon as possible
- Restrict and audit all access to log data

**In transit:**

- Use secure transmission protocols for log data sent over untrusted networks
- Due diligence before sending event data to third parties

## Monitoring and Alerting

- Integrate with existing log management infrastructure
- Enable alerting for serious events
- Share relevant events with other detection systems and threat intelligence feeds
- Processes to detect whether logging has stopped

## Disposal

Log data must not be destroyed before required retention period and not kept beyond it. Legal/regulatory obligations apply.

## Attacks on Logs

| Attack          | Threat                                                                                  |
| --------------- | --------------------------------------------------------------------------------------- |
| Confidentiality | Unauthorized read of logs containing PII or secrets                                     |
| Integrity       | Modification/deletion to cover tracks; exploitable platform vulnerabilities (log4shell) |
| Availability    | Disk exhaustion via log flooding; performance degradation                               |
| Accountability  | Preventing writes or logging wrong identity to conceal attacker                         |

## Related Pages

- [Security Logging](../concepts/security-logging.md)
- [CI/CD Security](../concepts/cicd-security.md)
- [OWASP](../entities/owasp.md)
