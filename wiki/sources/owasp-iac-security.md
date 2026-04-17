---
title: "OWASP Infrastructure as Code Security Cheat Sheet"
tags: [iac, terraform, security, owasp, devops, ci-cd]
sources: [owasp-iac-security.md]
updated: 2026-04-15
---

# OWASP Infrastructure as Code Security Cheat Sheet

Summary of security best practices for IaC across the full SDLC.

## Key Takeaways

IaC security is most effective when integrated across three phases: **Develop & Distribute**, **Deploy**, and **Runtime**. The core principle is shift-left — detect and fix security issues as early as possible.

## Phase: Develop & Distribute

| Practice                      | Tools                                                       |
| ----------------------------- | ----------------------------------------------------------- |
| IDE security plugins          | TFLint, Checkov, Docker Linter                              |
| Threat modelling              | Early in dev cycle; focus on high-risk areas                |
| Secrets management            | truffleHog, git-secrets, GitGuardian — never commit secrets |
| Version control               | Git; infra changes co-committed with feature code           |
| Principle of least privilege  | Restrict IaC operator and resource permissions              |
| Static analysis               | kubescan, Snyk, Coverity                                    |
| Open source dependency check  | BlackDuck, Snyk, WhiteSource Bolt                           |
| Container image scanning      | Dagda, Clair, Trivy, Anchore                                |
| CI/CD integration + reporting | Jenkins; DefectDojo + OWASP Glue for dashboards             |
| Artifact signing              | TUF — sign at build, verify before use                      |

## Phase: Deploy

| Practice             | Notes                                                      |
| -------------------- | ---------------------------------------------------------- |
| Inventory management | Tag and track every resource; untagged = ghost resources   |
| Commissioning        | Label + log on deployment                                  |
| Decommissioning      | Erase configs, securely delete data, remove from inventory |
| Dynamic analysis     | ZAP, Burp, GVM — check interoperability risks              |

## Phase: Runtime

| Practice                                                            | Tools                                                       |
| ------------------------------------------------------------------- | ----------------------------------------------------------- |
| [Immutable infrastructure](../concepts/immutable-infrastructure.md) | No in-place changes; replace entire environment for updates |
| Logging                                                             | Security + audit logs; ELK stack                            |
| Monitoring                                                          | Prometheus, Grafana                                         |
| Runtime threat detection                                            | Falco, Contrast (also blocks OWASP Top 10 attacks)          |

## Concepts Referenced

- [IaC Security](../concepts/iac-security.md)
- [Secrets Management](../concepts/secrets-management.md)
- [Immutable Infrastructure](../concepts/immutable-infrastructure.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)

## Related Entities

- [OWASP](../entities/owasp.md)
