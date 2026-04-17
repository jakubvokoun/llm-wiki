---
title: "OWASP Secure Code Review Cheat Sheet"
tags: [owasp, security, code-review, sast, sdlc]
sources: [owasp-secure-code-review.md]
updated: 2026-04-16
---

# OWASP Secure Code Review Cheat Sheet

## Summary

Methodology for manual security code review: baseline vs. diff-based review types, preparation steps, common vulnerability patterns (injection, auth, authz, deserialization, crypto), review techniques (data flow analysis, threat-based, business logic), checklists across 7 domains, SAST tool integration strategy, and SDLC integration guidance.

## Key Takeaways

### Review Types

- **Baseline Review** — entire codebase; used for new apps, major releases, legacy onboarding, compliance, post-incidents.
- **Diff-Based Review** — code changes only; used in PRs, daily workflow, feature completion, CI.
- **Hybrid**: baseline for high-risk components, diff-based for routine changes; escalate to baseline on significant concerns.

### Why Manual Review Matters

Automated SAST/DAST tools miss:

- Business logic flaws (require domain understanding)
- Context-specific vulnerabilities (application-specific business rules)
- Complex authorization logic
- Race conditions (TOCTOU)
- Cryptographic misuse (proper primitive usage)
- Architecture-level security anti-patterns

### Core Review Techniques

**Code Pattern Analysis** — focus on input processing, DB query construction, file operations, auth/session logic, crypto operations, error handling, config loading.

**Data Flow Analysis**:

1. Sources: user inputs, file uploads, API calls, DB reads, env vars
2. Processing: validation, transformation, business logic
3. Sinks: DB queries, file writes, output rendering, logs, external APIs
4. Trust boundaries: verify controls at every crossing

**Threat-Based Review**: OWASP Top 10, STRIDE model, attack trees, abuse cases.

**Business Logic Review**: state transitions, race conditions, transaction integrity, quota enforcement, workflow bypass.

### Common Vulnerability Patterns

- **Injection**: SQL (string concatenation), XSS (output encoding), Path Traversal (file path construction), Command Injection (system calls), NoSQL injection.
- **Auth/Session**: weak hashing, weak session tokens, missing session invalidation.
- **Access Control**: missing server-side checks, IDOR, privilege escalation.
- **Deserialization**: unsafe deserialization, XXE.
- **Crypto**: weak algorithms, improper key management, predictable IVs.

### Review Checklists (7 Domains)

1. **Input Validation**: server-side, allowlist, output encoding, SQL parameterization, file upload safety.
2. **Auth & Session**: strong hashing, lockout, 128-bit+ entropy tokens, session lifecycle, re-auth, MFA.
3. **Authorization**: server-side enforcement, default deny, IDOR, function-level controls.
4. **Cryptography**: AES-256/RSA-2048+, proper key management, CSPRNG, unique IVs.
5. **Business Logic**: state validation, race conditions, rollback, rate limits.
6. **Config & Deployment**: no hardcoded secrets, environment separation, security headers, TLS config, dep management.
7. **Security Monitoring**: auth failure logging, anomaly detection, audit trails, alert thresholds.

### Tool Integration Strategy

- Run SAST before manual review to identify obvious issues.
- Use SAST findings to prioritize manual review areas.
- Manual review validates false positives from automated tools.
- Manual review fills gaps automated tools cannot cover (business logic, architecture).

### Documentation Templates

Include for each finding: Title, Severity, CWE, Location (file:line), Description, Impact, Reproduction steps, Recommendation with code examples, References, Status, Assignee, Due Date.

### SDLC Integration

- Pre-commit hooks for lightweight checks.
- PR review as standard process.
- Sprint/feature reviews for security implications.
- Periodic baseline reviews for compliance/major releases.

## Related Pages

- [Secure Code Review](../concepts/secure-code-review.md)
- [Input Validation](../concepts/input-validation.md)
- [Authentication](../concepts/authentication.md)
- [Authorization](../concepts/authorization.md)
- [CI/CD Security](../concepts/cicd-security.md)
- [OWASP](../entities/owasp.md)
