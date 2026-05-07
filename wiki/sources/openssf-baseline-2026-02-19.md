---
title: "OpenSSF OSPS Baseline v2026-02-19"
tags: [openssf, supply-chain-security, open-source-security]
sources: [openssf-baseline-2026-02-19.md]
updated: 2026-05-07
---

# OpenSSF Open Source Project Security Baseline

The OSPS Baseline is a set of security controls that open source projects should meet to demonstrate a strong security posture. Maintained by the OpenSSF Security Baseline SIG. Version: 2026-02-19.

## Structure

Controls are organized by **maturity level** and **control category**:

| Level       | Target                                                             |
| ----------- | ------------------------------------------------------------------ |
| **Level 1** | Any project with any number of maintainers or users                |
| **Level 2** | Code projects with 2+ maintainers and a small consistent user base |
| **Level 3** | Code projects with a large consistent user base                    |

## Control categories (OSPS codes)

| Code | Category                 |
| ---- | ------------------------ |
| AC   | Access Control           |
| BR   | Build and Release        |
| DO   | Documentation            |
| GV   | Governance               |
| LE   | Legal                    |
| QA   | Quality Assurance        |
| SA   | Security Assessment      |
| VM   | Vulnerability Management |

## Key Level 1 controls

- **AC-01.01** — MFA required for sensitive resource access
- **AC-02.01** — New collaborators get lowest privileges by default
- **AC-03.01** — Direct commits to primary branch blocked
- **BR-01.01** — CI/CD pipelines sanitize untrusted metadata
- **BR-01.03** — Untrusted code builds have no access to privileged credentials
- **BR-07.01** — No unencrypted secrets in VCS
- **QA-01.01** — Source code publicly readable at static URL
- **QA-01.02** — VCS contains public record of all changes with authorship
- **VM-02.01** — Documentation includes security contacts

## Key Level 2 controls

- **AC-04.01** — CI/CD tasks default to minimum permissions
- **BR-02.01** — Releases assigned unique version identifiers
- **BR-04.01** — Releases include changelog of functional and security changes
- **BR-06.01** — Releases signed or in signed manifest with cryptographic hashes
- **QA-03.01** — Automated status checks pass before commits merge to primary branch
- **QA-06.01** — CI/CD runs automated test suite before accepting commits
- **VM-01.01** — Documented coordinated vulnerability disclosure policy
- **VM-03.01** — Private vulnerability reporting mechanism available
- **VM-04.01** — Discovered vulnerabilities publicly published

## Key Level 3 controls

- **AC-04.02** — Jobs in CI/CD pipelines assigned minimum necessary permissions
- **BR-07.02** — Secrets management policy defined
- **DO-03.01/02** — Documentation explains how to verify release integrity and authorship
- **GV-04.01** — Collaborator review required before escalated permission grants
- **QA-02.02** — All compiled releases ship with SBOM
- **QA-07.01** — At least one non-author human approval required before merging to primary branch
- **SA-03.02** — Threat modeling and attack surface analysis performed
- **VM-04.02** — VEX documents account for non-exploitable vulnerabilities
- **VM-05.01/02** — SCA policy defines remediation thresholds; violations resolved before release

## External framework mappings

The Baseline maps controls to external frameworks (as approximate references, not functional connections):

- NIST SSDF
- CIS Controls
- OWASP SAMM
- ISO/IEC 27001
- OpenSSF Scorecard

## Related pages

- Entity: [OpenSSF](../entities/openssf.md)
- Concept: [OpenSSF Baseline](../concepts/openssf-baseline.md)
- Concept: [Supply Chain Security](../concepts/supply-chain-security.md)
- Concept: [Vulnerability Disclosure](../concepts/vulnerability-disclosure.md)
