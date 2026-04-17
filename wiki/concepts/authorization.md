---
title: "Authorization"
tags: [authorization, access-control, least-privilege, abac, rbac, rebac, idor]
sources: [owasp-authorization.md]
updated: 2026-04-16
---

# Authorization

Authorization (AuthZ) is "the process of verifying that a requested action or service is approved for a specific entity" (NIST). It is distinct from authentication (verifying identity) — a user can be authenticated but not authorized to access a particular resource.

**Broken Access Control** has been the #1 vulnerability in OWASP Top 10 since 2021.

## Core Principles

### Least Privilege

Grant users only the minimum permissions necessary to complete their job. Apply both horizontally (different roles at same level → different resources) and vertically (hierarchy of access levels).

### Deny by Default

When no explicit access rule matches, default to deny. Never make access the default state. Explicit configuration is preferred over framework defaults.

### Validate on Every Request

Every request — AJAX, server-side, API — must be individually authorized. Do not trust that previous checks cover subsequent requests. Use global, application-wide mechanisms (middleware/filters), not per-method checks.

### Server-Side Enforcement

Never rely on client-side access control. Client-side checks are for UX only. All enforcement must be server-side, at the gateway, or in serverless functions.

## Access Control Models

See [RBAC](rbac.md) and [ABAC](abac.md) for detailed pages.

| Model | Description                                          | Best For                                       |
| ----- | ---------------------------------------------------- | ---------------------------------------------- |
| RBAC  | Access via roles assigned to users                   | Simple systems; few user/resource types        |
| ABAC  | Access via attributes (subject, object, environment) | Complex, fine-grained, dynamic requirements    |
| ReBAC | Access via relationships between resources           | Social graphs, ownership models, multi-tenancy |

**ABAC/ReBAC are preferred** over RBAC for application development because they:

- Support Boolean logic with environmental attributes (time, device, location)
- Scale better (no "role explosion")
- Handle multi-tenancy natively
- Are easier to audit at scale

## IDOR (Insecure Direct Object Reference)

Exposing internal object IDs (e.g., `?acct_id=901`) without access checks is one of the most common authorization flaws (CWE-639). An authenticated user can enumerate/access other users' resources by guessing IDs.

Mitigations:

- Derive object identity from session/JWT claims when possible
- Use indirect references (user-session-scoped mapping)
- Always perform access check on the specific object being requested

## Static Resource Authorization

Static files (images, documents, S3 objects) must be included in access control policies. "Publicly accessible URL" is not a substitute for proper access control. Cloud storage misconfigurations (open S3 buckets) are a frequent source of data breaches.

## Authorization Failure Handling

- Handle all authorization failures gracefully — do not leave application in undefined state
- Centralize failure-handling logic
- Return minimal information in error responses (no stack traces, no system internals)
- Log all authorization failures for monitoring

## Testing Authorization

- Create unit and integration tests for all access control logic
- Test both positive (allowed) and negative (denied) cases
- Test privilege escalation (horizontal: access another user's data; vertical: escalate to admin)
- Supplement with penetration testing — automated tests catch systematic errors, pentest catches subtle logic flaws

## Related Pages

- [RBAC](rbac.md)
- [ABAC](abac.md)
- [IDOR](idor.md)
- [Authentication](authentication.md)
- [Zero Trust Architecture](zero-trust.md)
- [OWASP Authorization Cheat Sheet](../sources/owasp-authorization.md)
