---
title: "OWASP CI/CD Security Cheat Sheet"
tags: [owasp, cicd, devops, security, supply-chain]
sources: [owasp-cicd-security.md]
updated: 2026-04-15
---

# OWASP CI/CD Security Cheat Sheet

Practical guidelines for reducing risk in CI/CD pipelines, covering the [OWASP Top 10 CI/CD Security Risks](https://owasp.org/www-project-top-10-ci-cd-security-risks/).

## Key Takeaways

CI/CD pipelines occupy critical roles in the SDLC and are high-value attack targets. The Codecov and SolarWinds breaches demonstrate the potential impact. High-privileged pipeline identities mean successful attacks have high damage potential.

### Top 10 CI/CD Risks

| #           | Risk                                               |
| ----------- | -------------------------------------------------- |
| CICD-SEC-1  | Insufficient Flow Control Mechanisms               |
| CICD-SEC-2  | Inadequate Identity and Access Management          |
| CICD-SEC-3  | Dependency Chain Abuse                             |
| CICD-SEC-4  | Poisoned Pipeline Execution (PPE)                  |
| CICD-SEC-5  | Insufficient PBAC (Pipeline-Based Access Controls) |
| CICD-SEC-6  | Insufficient Credential Hygiene                    |
| CICD-SEC-7  | Insecure System Configuration                      |
| CICD-SEC-8  | Ungoverned Usage of Third-Party Services           |
| CICD-SEC-9  | Improper Artifact Integrity Validation             |
| CICD-SEC-10 | Insufficient Logging and Visibility                |

## Controls Summary

### SCM Hardening

- No auto-merge rules; require PR reviews
- Protected branches + signed commits + MFA
- Restrict fork and visibility changes
- Use [Legitify](https://github.com/Legit-Labs/legitify) to audit SCM config

### Pipeline Configuration

- Isolated build nodes
- TLS 1.2+ for SCM↔CI communication
- Restrict CI access by IP
- CI config file stored outside source repo if possible
- No `--privileged` flag in Docker steps
- Manual approval gate before production deployment

### Secrets

- Never hardcode secrets; use git-leaks/git-secrets to detect them
- Use dedicated secrets managers (Vault, AWS Secrets Manager)
- Never log secrets; use temporary credentials where possible

### Least Privilege / IAM

- Deny-by-default for all pipeline identities
- No credential sharing across pipelines of different sensitivity
- Pipeline OS accounts must not be root
- Maintain identity inventory (owner, IdP, last used, permissions used)

### Dependency Chain Abuse Mitigation

- Pin versions in lock files; verify hashes
- Enforce lockfiles in CI (`npm ci` not `npm install`)
- Use private registries; configure single feed
- Scoped npm packages / NuGet ID prefixes

### Integrity

- Code signing (Sigstore, Signserver)
- in-toto framework for end-to-end supply chain integrity

## Related Pages

- [concepts/cicd-security](../concepts/cicd-security.md)
- [concepts/secrets-management](../concepts/secrets-management.md)
- [concepts/supply-chain-security](../concepts/supply-chain-security.md)
- [concepts/iac-security](../concepts/iac-security.md)
