---
title: "OWASP Authorization Cheat Sheet"
tags:
  [
    owasp,
    authorization,
    access-control,
    rbac,
    abac,
    rebac,
    idor,
    least-privilege,
  ]
sources: [owasp-authorization.md]
updated: 2026-04-16
---

# OWASP Authorization Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html

## Key Takeaways

Authorization — "the process of verifying that a requested action or service is approved for a specific entity" (NIST) — is distinct from authentication (verifying identity). **Broken Access Control** was OWASP Top 10 #1 in 2021.

## Core Recommendations

### 1. Enforce Least Privileges

- Define trust boundaries and enumerate user types, resources, and operations during design
- Create tests validating permissions from design phase
- Periodically review for "privilege creep" after deployment
- Easier to grant than revoke — plan carefully upfront

### 2. Deny by Default

- Application must always make an explicit access decision; default = deny
- Explicit configuration preferred over framework/library defaults
- Justify why a specific permission was granted, not why it was denied

### 3. Validate Permissions on Every Request

- Every request — AJAX, server-side, API — must be checked
- Use global, application-wide mechanisms (filters/middleware), not per-method checks
- Frameworks: Spring Security filters, Django middleware, .NET Core filters, Laravel middleware

### 4. Thoroughly Review Third-Party Authorization Logic

- Keep processes to detect/respond to vulnerable components
- Use Dependency Check; subscribe to NVD/vendor feeds
- Defense in depth: no single control should be the only authorization enforcement
- Test configuration; don't trust defaults or documentation without verification

### 5. Prefer ABAC / ReBAC over RBAC

| Model | Description                                          | Strengths                                       |
| ----- | ---------------------------------------------------- | ----------------------------------------------- |
| RBAC  | Access via roles assigned to users                   | Simple setup; poor for complex logic            |
| ABAC  | Access via attributes (subject, object, environment) | Fine-grained; handles dynamic context           |
| ReBAC | Access via relationships between resources           | Fine-grained; ideal for social/ownership models |

ABAC/ReBAC advantages over RBAC:

- Support complex Boolean logic (time of day, device type, geography)
- More robust — RBAC "role explosion" creates audit/maintenance complexity
- Better for multi-tenancy and cross-organizational access
- Easier to manage at scale

### 6. Protect Against IDOR (Insecure Direct Object Reference)

Exposing internal object IDs (e.g., `?acct_id=901`) in query params or path variables enables horizontal privilege escalation (CWE-639).

Mitigations:

- Avoid exposing identifiers where possible (derive from session/JWT claims)
- Use user/session-specific indirect references (e.g., OWASP ESAPI)
- Perform access control check on every request for the specific object, not just object type

### 7. Enforce Authorization Checks on Static Resources

- Include static resources (files, S3 buckets, CDN assets) in access control policies
- Secure cloud storage with vendor config (AWS S3 policies, GCS best practices, Azure recommendations)
- Use the same access control mechanisms as other application resources

### 8. Perform Checks Server-Side

- Never rely on client-side access control checks (easily bypassed)
- Checks must be performed server-side, at the gateway, or in serverless functions

### 9. Exit Safely on Authorization Failure

- Handle all exception and failed access control checks
- Centralize failure-handling logic
- Never expose system logs or debug output in error messages (CWE-209)

### 10. Implement Appropriate Logging

- Log authorization failures (part of OWASP Top 10 2021 A09)
- Consistent format, parseable for analysis
- Centralize into SIEM; synchronize clocks

### 11. Unit and Integration Test Authorization Logic

- Tests catch "low-hanging fruit" — systematic role/permission logic errors
- Not a substitute for penetration testing, but catches regressions

## Related Pages

- [Authorization](../concepts/authorization.md)
- [RBAC](../concepts/rbac.md)
- [ABAC](../concepts/abac.md)
- [IDOR](../concepts/idor.md)
- [Zero Trust Architecture](../concepts/zero-trust.md)
- [OWASP](../entities/owasp.md)
