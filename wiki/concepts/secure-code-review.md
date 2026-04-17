---
title: "Secure Code Review"
tags: [security, code-review, sast, sdlc, methodology]
sources: [owasp-secure-code-review.md]
updated: 2026-04-16
---

# Secure Code Review

The process of manually examining source code to identify security vulnerabilities that automated tools miss, focusing on business logic, data flow, and context-specific security flaws.

## Why Manual Review is Necessary

Automated SAST/DAST tools cannot effectively identify:

- **Business logic flaws** — require domain understanding of what the code is supposed to do.
- **Context-specific vulnerabilities** — depend on application-specific business rules.
- **Complex authorization logic** — permission models and access control flows.
- **Race conditions (TOCTOU)** — timing-based vulnerabilities in concurrent operations.
- **Cryptographic misuse** — correct vs. incorrect usage of cryptographic primitives.
- **Architecture security anti-patterns** — high-level design flaws.

Manual review **complements** automated tools — it doesn't replace them.

## Review Types

| Type           | Scope             | When to Use                                                             |
| -------------- | ----------------- | ----------------------------------------------------------------------- |
| **Baseline**   | Entire codebase   | New apps, major releases, legacy onboarding, compliance, post-incidents |
| **Diff-Based** | Changed code only | PRs, daily development, feature completion, CI pipeline                 |

**Hybrid approach**: Baseline for high-risk components, diff-based for routine changes. Escalate from diff to baseline when significant concerns are found.

## Preparation

For all reviews:

1. Understand application architecture and business requirements.
2. Gather existing threat models and prior security findings.
3. Identify critical assets and high-risk functions.
4. Review security requirements and documentation.

For baseline reviews: also audit all third-party libraries, map full application boundaries.

For diff-based reviews: also identify affected components, assess impact on existing security controls.

## Review Process

**Baseline steps:**

1. Architecture review for security anti-patterns
2. Entry point analysis + input validation
3. Authentication + authorization verification
4. Data flow tracing
5. Business logic analysis
6. Cryptographic implementation review
7. Error handling verification
8. Configuration and deployment review

**Diff-based steps:**

1. Analyze impact on existing security controls
2. Identify new attack vectors
3. Verify security at modified trust boundaries
4. Check new integrations
5. No security regression

## Key Review Techniques

### Data Flow Analysis

Trace data from source to sink:

1. **Sources**: user inputs, file uploads, API calls, DB reads, env vars
2. **Processing**: validation, transformation, business logic, caching
3. **Sinks**: DB queries, file writes, output rendering, logs, external APIs
4. **Trust boundaries**: verify security controls at each crossing

### Threat-Based Review

Map code against known attack patterns:

- OWASP Top 10
- STRIDE model (Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation of Privilege)
- Attack trees
- Abuse cases

### Business Logic Review

- State transitions and their validation
- Race conditions in concurrent operations
- Transaction integrity and rollback
- Resource/quota enforcement
- Workflow bypass opportunities

## Common Vulnerability Patterns

| Category                 | What to Look For                                |
| ------------------------ | ----------------------------------------------- |
| SQL Injection            | String concatenation in queries                 |
| XSS                      | Missing output encoding, raw DOM manipulation   |
| Path Traversal           | Unsafe file path construction                   |
| Command Injection        | User input passed to system calls               |
| Auth flaws               | Weak hashing, missing session invalidation      |
| IDOR                     | Missing authorization checks on resource access |
| Insecure Deserialization | Untrusted data deserialized without validation  |
| Crypto flaws             | Weak algorithms, predictable IVs, key misuse    |

## Review Checklists

Seven domains to verify (abbreviated):

1. **Input Validation** — server-side, allowlist, output encoding, SQL parameterization, file upload safety, length limits, no sensitive data in errors.
2. **Auth & Session** — strong password hashing, lockout, 128-bit+ entropy tokens, session lifecycle, re-auth, MFA.
3. **Authorization** — server-side, default deny, IDOR prevention, function-level access, privilege escalation.
4. **Cryptography** — AES-256/RSA-2048+, proper key management, CSPRNG, unique IVs, current libraries.
5. **Business Logic** — state validation, race condition prevention, rollback, rate limits.
6. **Config & Deployment** — no hardcoded secrets, environment separation, security headers, TLS, dep updates.
7. **Security Monitoring** — auth failure logging, anomaly detection, audit trails, alert thresholds.

## SAST Tool Integration

- **Before manual review**: run SAST to identify obvious issues and guide prioritization.
- **During manual review**: investigate areas flagged by SAST more deeply.
- **After manual review**: apply human judgment to filter false positives.
- **Gap filling**: focus manual effort on areas SAST cannot cover (business logic, architecture).

## SDLC Integration

- **Pre-commit hooks**: lightweight automated checks.
- **Pull requests**: security-focused review as standard PR process.
- **Sprint/feature reviews**: security implications of sprint deliverables.
- **Periodic baseline reviews**: compliance cycles, major releases, post-incidents.

## Finding Documentation

Each finding should include: Title, Severity, CWE, Location (file:line), Description, Impact, Reproduction steps, Recommendation with code examples, References, Status, Assignee, Due Date.

## Related Pages

- [Input Validation](input-validation.md)
- [Authentication](authentication.md)
- [Authorization](authorization.md)
- [CI/CD Security](cicd-security.md)
- [Key Management](key-management.md)
- [OWASP Secure Code Review Cheat Sheet](../sources/owasp-secure-code-review.md)
