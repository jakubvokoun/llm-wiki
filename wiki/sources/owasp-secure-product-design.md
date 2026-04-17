---
title: "OWASP Secure Product Design Cheat Sheet"
tags:
  [
    owasp,
    secure-design,
    least-privilege,
    defense-in-depth,
    zero-trust,
    threat-modeling,
  ]
sources: [owasp-secure-product-design.md]
updated: 2026-04-16
---

# OWASP Secure Product Design Cheat Sheet

Source: `raw/owasp-secure-product-design.md`

## Summary

Secure Product Design ensures all security decisions are explicit, intentional choices made throughout the development lifecycle. The goal: correct level of security per product, not under- or over-engineered.

## Two Design Phases

| Phase                 | When                            | Nature                                                                         |
| --------------------- | ------------------------------- | ------------------------------------------------------------------------------ |
| **Product Inception** | Product conceived or reinvented | Strategic; sets Product Security Levels, chooses connections/external services |
| **Product Design**    | Ongoing, agile                  | Tactical; continuous threat modeling, secure coding, per-iteration stories     |

## Four Security Principles

### 1. Least Privilege + Separation of Duties

- Users get minimum access to perform their role
- No single individual controls all aspects of a transaction — different tasks to different people
- Reduces fraud risk and unauthorized access

### 2. Defense-in-Depth

- Multiple independent layers of controls: physical → network → application → data
- If one layer fails, others protect the asset
- See: [defense-in-depth](../concepts/defense-in-depth.md)

### 3. Zero Trust

- All users, devices, networks untrusted by default
- Every access request authenticated and authorized
- Continuous monitoring of user activity
- See: [zero-trust](../concepts/zero-trust.md)

### 4. Security-in-the-Open

- Security awareness in open source development
- Use secure coding practices, test for vulnerabilities, collaborate with security experts
- Don't rely on obscurity — expose security properties to scrutiny

## Five Security Focus Areas (5 Cs)

### 1. Context

- Where does the app fit in the org ecosystem?
- What data? What risk profile?
- Tools: Threat Modeling, Business Impact Assessment → sets Product Security Levels
- **Warning**: over-engineering security costs as much as under-engineering — size it correctly

### 2. Components

- Libraries, frameworks, external services
- Use Golden Path / Paved Road approved components
- Evaluate: licensing, maintenance, usage limits
- Analyze choices via Threat Modeling

### 3. Connections

- How users/services interact with the application
- Data storage and access paths
- Intentional _lack_ of connections also matters (tier segregation, tenant isolation)
- Adding/removing connections signals Product Inception is happening

### 4. Code

10 secure coding basics:

1.  Input validation — type, format, length
2.  Secure error handling — log securely, no sensitive info leakage
3.  Authentication + Authorization — strong mechanisms
4.  Cryptography — HTTPS, encryption at rest and in transit
5.  Least privilege in code — min access rights
6.  Secure memory management — prevent buffer overflows, use-after-free
7.  No hardcoded secrets — use secure secret storage
8.  Security testing — before and just before deployment
9.  Code audits — automated tools + third-party reviews
10. Keep up-to-date — latest patches and best practices

Write unit/integration tests covering Threat Modeling-discovered threats. Compile use-cases and abuse-cases per tier.

### 5. Configuration

Secure configuration checklist:

1. Apply Least Privilege to system components
2. Defense-in-Depth — multiple control layers
3. Secure by Default — minimal manual setup required
4. Encrypt sensitive data at rest and in transit; correct backup + retention
5. Fail Securely — design failures to leave system in safe state
6. Secure Communications — HTTPS everywhere
7. Regular updates — software, Docker images, OS patches
8. Incident Response Plan — practiced, part of Product Support Model

See: [IaC Security](../concepts/iac-security.md) for precise configuration guidance.

## Key Insight: Context-Driven Security

Security investment must match the Product Security Level. Over-engineering has real cost; under-engineering has catastrophic consequences. Threat Modeling and Business Impact Assessment calibrate the correct level.

## Related Concepts

- [defense-in-depth](../concepts/defense-in-depth.md)
- [zero-trust](../concepts/zero-trust.md)
- [secure-by-default](../concepts/secure-by-default.md)
- [authorization](../concepts/authorization.md)
- [input-validation](../concepts/input-validation.md)
- [secrets-management](../concepts/secrets-management.md)
- [iac-security](../concepts/iac-security.md)
