---
title: "CI/CD Security"
tags: [cicd, devops, security, supply-chain, pipeline]
sources: [owasp-cicd-security.md]
updated: 2026-04-15
---

# CI/CD Security

Security practices for Continuous Integration and Continuous Delivery/Deployment pipelines.

## Why It Matters

CI/CD pipelines are high-value attack targets — they use privileged identities, have broad access to source code and deployment infrastructure, and often run automatically with little human oversight. Compromising a pipeline can enable supply chain attacks affecting all downstream users (see: SolarWinds, Codecov breaches).

## OWASP Top 10 CI/CD Risks

1.  Insufficient Flow Control Mechanisms
2.  Inadequate Identity and Access Management
3.  **Dependency Chain Abuse** — exploitation of package resolution to run malicious code
4.  **Poisoned Pipeline Execution (PPE)** — injecting malicious code into pipeline via SCM
5.  Insufficient PBAC (Pipeline-Based Access Controls)
6.  Insufficient Credential Hygiene
7.  Insecure System Configuration
8.  Ungoverned Usage of Third-Party Services
9.  Improper Artifact Integrity Validation
10. Insufficient Logging and Visibility

## Key Control Areas

### SCM Hardening

- Protected branches; no auto-merge
- Require signed commits and PR reviews
- MFA everywhere; no default permissions
- Audit SCM config with tools like Legitify

### Pipeline Configuration

- Isolated build nodes (Jenkins controller isolation)
- TLS 1.2+ for all CI/CD communications
- CI config file outside the repo when possible
- No `--privileged` Docker flag in pipeline steps
- Manual approval gate before production

### Secrets Management

- Never hardcode secrets in code or config
- Use dedicated secrets managers (Vault, AWS Secrets Manager)
- Detect secrets with git-leaks, git-secrets
- Never log secrets; prefer temporary credentials

### Dependency Chain Abuse Prevention

- Pin versions with lock files; enforce in CI
- Verify package hashes/checksums
- Use private package registries with single feed
- Scoped npm packages / NuGet ID prefixes

### Integrity

- Code signing (Sigstore/Signserver)
- in-toto framework for supply chain integrity
- SLSA provenance levels

## Related Concepts

- [supply-chain-security](supply-chain-security.md)
- [secrets-management](secrets-management.md)
- [iac-security](iac-security.md)

## Sources

- [OWASP CI/CD Security Cheat Sheet](../sources/owasp-cicd-security.md)
