---
title: "OpenSSF OSPS Baseline"
tags: [openssf, supply-chain-security, open-source-security]
sources: [openssf-baseline-2026-02-19.md]
updated: 2026-05-07
---

# OpenSSF Open Source Project Security Baseline

The OSPS Baseline is a structured set of security controls for open source projects, published by the Open Source Security Foundation (OpenSSF). It provides a tiered, auditable way to demonstrate project security posture.

## Three maturity levels

| Level       | Target                         | Key theme                                                                |
| ----------- | ------------------------------ | ------------------------------------------------------------------------ |
| **Level 1** | Any project                    | Basic hygiene: MFA, access control, public history, security contacts    |
| **Level 2** | 2+ maintainers, small userbase | Process: CI tests, signed releases, changelogs, vulnerability disclosure |
| **Level 3** | Large userbase                 | Policy depth: SBOMs, threat modeling, VEX, SCA policy, code review       |

## Eight control categories

### AC — Access Control

- L1: MFA for sensitive resources; new collaborators start with least privilege; no direct commits to primary branch
- L2: CI/CD tasks default to lowest permissions
- L3: Jobs assigned only minimum necessary permissions; contributor review before permission escalation

### BR — Build and Release

- L1: CI/CD sanitizes untrusted input; official channels use TLS; no secrets in VCS
- L2: Unique version IDs; changelogs; standardized tooling for dependencies; signed releases
- L3: All release assets associated with release ID; secrets management policy defined

### DO — Documentation

- L1: User guides; defect reporting guide
- L2: Dependency tracking docs; build instructions
- L3: Release verification instructions; support lifecycle statements

### GV — Governance

- L1: Public discussion mechanism; documented contribution process
- L2: Member list with access; roles and responsibilities documented; contributor requirements
- L3: Contributor review before permission escalation

### LE — Legal

- L1: OSI/FSF-compliant license; license in LICENSE file
- (No L2/L3 additions)

### QA — Quality Assurance

- L1: Public VCS at static URL; public change record; no generated executables or binary blobs in VCS
- L2: Automated status checks pass before merge; CI runs automated test suite
- L3: Code review by non-author before merge; test documentation; test update policy; multi-repo subproject enforcement; SBOMs for compiled releases

### SA — Security Assessment

- L2: Design documentation; external interface descriptions; security assessment
- L3: Threat modeling and attack surface analysis for critical code paths

### VM — Vulnerability Management

- L1: Security contacts documented
- L2: CVD policy; private reporting; public vulnerability disclosure
- L3: VEX for non-exploitable vulnerabilities; SCA remediation policy

## Framework mappings

Controls are mapped (approximately) to: NIST SSDF, CIS Controls, OWASP SAMM, ISO/IEC 27001, OpenSSF Scorecard.

## Relationship to SLSA

OSPS Baseline and SLSA are complementary:

- SLSA focuses on build/source integrity through cryptographic attestations
- OSPS Baseline addresses broader project security posture (governance, documentation, disclosure)
- OSPS BR controls (signed releases, CI sanitization) align with SLSA Build Track requirements

## Related pages

- [OpenSSF OSPS Baseline v2026-02-19](../sources/openssf-baseline-2026-02-19.md)
- Entity: [OpenSSF](../entities/openssf.md)
- Concept: [Supply Chain Security](supply-chain-security.md)
- Concept: [Vulnerability Disclosure](vulnerability-disclosure.md)
