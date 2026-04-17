---
title: "Infrastructure as Code Security"
tags: [iac, terraform, security, devops, shift-left]
sources: [owasp-iac-security.md]
updated: 2026-04-15
---

# Infrastructure as Code Security

Security practices for managing infrastructure defined as code (Terraform, Ansible, Helm, CloudFormation, etc.).

## Core Principle: Shift Left

Detect and fix security issues as early as possible in the development cycle. Cost of fixing a misconfiguration increases exponentially from dev to production.

## SDLC Phases

### Develop

- **IDE plugins**: Checkov, TFLint — catch misconfigs before commit
- **Threat modelling**: Identify high-risk assets early
- **Secret detection**: Never commit secrets to SCM; use truffleHog, git-secrets, GitGuardian
- **Static analysis**: kubescan, Snyk, Coverity for policy-as-code violations
- **Dependency scanning**: BlackDuck, Snyk for OS packages and libraries
- **Artifact signing**: TUF — sign at build time, verify before deploy

### CI/CD

- Container image scanning: Trivy, Anchore, Clair
- Gate merges on scan results
- Consolidated reporting: DefectDojo + OWASP Glue
- Version all infra changes alongside the feature code they support

### Deploy

- **Tagging**: Every resource must be tagged — untagged = ghost resource (billing waste, security blind spot)
- **Inventory management**: Log commissioning and decommissioning events
- **Dynamic analysis**: ZAP, Burp for runtime interoperability risks

### Runtime

- **[Immutable infrastructure](immutable-infrastructure.md)**: Replace, don't patch
- **Logging + Monitoring**: ELK, Prometheus, Grafana
- **Runtime threat detection**: Falco, Contrast

## Principle of Least Privilege

Two dimensions:

1. **Operator permissions**: Who can create/modify/delete IaC scripts
2. **Resource permissions**: What permissions the provisioned resources themselves have

## Sources

- [OWASP IaC Security Cheat Sheet](../sources/owasp-iac-security.md)
