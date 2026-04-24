---
title: "CI/CD Pipeline Security Best Practices 2026 (Wiz)"
tags:
  [cicd-security, devops, sast, dast, secrets-management, rbac, supply-chain]
sources: [wiz-cicd-security-best-practices.md]
updated: 2026-04-23
---

# CI/CD Pipeline Security Best Practices 2026 (Wiz)

Comprehensive guide covering CI/CD attack surface, security controls per pipeline stage, pipeline types, and security KPIs. Data point: 35% of enterprises use self-hosted runners with weaker configurations (Wiz State of Code Security Report 2025).

## Attack Surface

Components most at risk:

- **Source code repositories** — access controls, branch protection
- **Build servers/runners** — often over-privileged, under-monitored
- **Artifact repositories** — tamper protection, signing
- **Deployment environments** — production access, config validation
- **CI runners** (GitHub-hosted, self-hosted) — lateral movement vector
- **Orchestration tools** (ArgoCD, Spinnaker) — exploit for lateral movement

## Security Controls by Stage

| Stage      | Key Security Controls                                                                           |
| ---------- | ----------------------------------------------------------------------------------------------- |
| **Source** | SAST, branch protection, mandatory code review, repo access controls                            |
| **Build**  | Dependency scanning (SCA), build artifact signing, build script validation, supply chain checks |
| **Test**   | DAST, IAST, env mirrors production, security-gated progression                                  |
| **Deploy** | IaC validation, approval gates, RBAC, post-deploy runtime monitoring                            |

## Six Best Practices

### 1. Automate Security Scans

Integrate SAST (SonarQube, Checkmarx) and SCA tools triggered on every commit. Alert via Slack/Teams/email. DAST catches runtime issues static analysis misses.

### 2. Runtime Monitoring

- SIEM/SOAR (Splunk, IBM QRadar) for pipeline event analysis
- ML-based anomaly detection (off-hours commits, unusual pipeline config, resource spikes)
- CI/CD-specific incident response playbooks
- Automated build quarantine for anomalous behavior

### 3. Secrets Management

- Use HashiCorp Vault or AWS Secrets Manager (dynamic secrets, audit logs, revocation)
- Pre-commit hooks + secret scanning tools prevent hardcoded credentials
- Automated secret rotation policies

### 4. Immutable Infrastructure

- Docker + Kubernetes for uniform deployments
- IaC (Terraform/CloudFormation) for consistent environments
- GitOps with drift detection; all changes have audit trails
- Rollback = recreate from IaC definitions

### 5. RBAC + Least Privilege

- Tiered permission structures; no single person controls full release process
- Four-eyed principle for critical operations
- Automation service accounts with strict privilege boundaries
- Centralized audit logging; scheduled access reviews; dormant account detection

### 6. Team Education

- Security champions embedded in development teams
- Security training integrated into dev workflow, not a separate phase
- Collaborative penetration tests with dev teams present
- Clear security guidelines / inline PR feedback

## Pipeline Types and Their Security Concerns

| Type                                           | Key Security Risk                                             |
| ---------------------------------------------- | ------------------------------------------------------------- |
| **Traditional** (Jenkins/Bamboo)               | Build env tampering, artifact integrity                       |
| **GitOps** (ArgoCD/Flux)                       | Secrets in Git YAML, over-permissive GitOps agents            |
| **Container-based**                            | Image vulnerabilities, registry access, runtime threats       |
| **Serverless** (GitHub Actions, AWS CodeBuild) | Fine-grained IAM, shared responsibility, privilege escalation |
| **Hybrid**                                     | Cross-toolchain visibility, consistent policy enforcement     |

## Security Tool Types

| Tool Category          | Purpose                                                     |
| ---------------------- | ----------------------------------------------------------- |
| **SAST**               | Source code analysis; SQL injection, XSS, insecure patterns |
| **SCA**                | Dependency vulnerability scanning and license compliance    |
| **DAST**               | Runtime vulnerability detection in running applications     |
| **IaC scanning**       | Terraform/CloudFormation misconfiguration detection         |
| **Container scanning** | Image vulnerability, malware, misconfiguration checks       |
| **Secrets management** | Secure credential storage, rotation, audit                  |

## Security KPIs

- **Vulnerability detection rate** — detected vs. total present (baseline via pentest)
- **Mean time to remediate (MTTR)** — tracked per severity level
- **Pipeline security policy compliance %** — machine-readable policies + dashboards
- **Security test coverage** — mapped against application threat model
- **Failed build rate due to security** — security vs. functional failures tracked separately

## Key Takeaways

- Pipeline = high-value target; one compromised component can affect all users
- Shared responsibility: CSP handles physical infra; you own code, access, and sensitive data
- Shift-left: catch issues in source/build stages, not after production deploy
- Self-hosted runners are a particular risk (35% of enterprises, often weaker config)

## See Also

- [CI/CD Security](../concepts/cicd-security.md)
- [Continuous Integration](../concepts/continuous-integration.md)
- [Secrets Management](../concepts/secrets-management.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [Immutable Infrastructure](../concepts/immutable-infrastructure.md)
- [RBAC](../concepts/rbac.md)
