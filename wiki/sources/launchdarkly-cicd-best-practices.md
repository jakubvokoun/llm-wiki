---
title: "Ultimate Guide to CI/CD Best Practices (LaunchDarkly)"
tags: [ci, cd, devops, progressive-delivery, feature-flags, testing, monitoring]
sources: [launchdarkly-cicd-best-practices.md]
updated: 2026-04-23
---

# Ultimate Guide to CI/CD Best Practices (LaunchDarkly)

13-practice guide from LaunchDarkly (Jesse Sumrak, Jul 2024) with practitioner quotes from Senior Software Engineer Darrin Eden. Emphasis on progressive delivery and feature flags as CI/CD accelerators.

## 13 Practices

### 1. Commit Frequently

Small, incremental commits reduce merge complexity and narrow the blast radius of issues. "Think big, act small" — deploy a single change at a time; build adaptive capacity for incident response.

### 2. Optimize Pipeline Stages

Profile stages for bottlenecks using monitoring tools. Parallelize independent tasks (unit tests + integration tests + static analysis simultaneously). Cache dependencies and build artifacts.

### 3. Build Code Artifacts Once

One build → same artifact across all environments (dev → test → staging → production). Immutable artifacts; new code = new artifact version. Centralized artifact storage (JFrog Artifactory, Nexus).

### 4. Automate Tests

Run unit tests first (fast feedback), then integration, then E2E. Clear dashboards for test results. Use IaC (Terraform/Ansible) to automate test environment setup. Security scanning in pipeline from the start.

### 5. Keep Builds Fast and Simple

Match workload to right-sized runner cluster (vertical + horizontal). Minimize dependencies; containerize workflows; monitor build velocity with alerts on performance drops. Avoid complex branching strategies.

### 6. Use Shared Pipelines (DRY)

Reuse pipeline configurations across projects. Tools:

- Jenkins Shared Libraries
- GitLab CI templates
- YAML anchors in AWS CodePipeline

Reduces duplication, enforces standards consistently.

### 7. Security-First Approach

Automated security tests on every commit. Security plugins/tools integrated with CI/CD platform. Regular audits. Developer education on secure coding. Decouple deployment from release via feature flags for production-like security testing.

### 8. Create Test Environments on Demand

Containerized on-demand environments that mirror production (configs, software versions, networking, datasets). Spin up and tear down per test run. Inconsistent environments cause knowledge gaps between dev and production.

### 9. Monitor and Measure the Pipeline

Key metrics (DORA + pipeline health):

| Metric                   | Description                                 |
| ------------------------ | ------------------------------------------- |
| **Build time**           | Start to finish per build                   |
| **Deployment frequency** | How often code reaches production           |
| **Lead time**            | Commit → production deployment              |
| **MTTR**                 | Mean time to recover from failed deployment |
| **Test pass rate**       | % of tests passing                          |

Tools: Prometheus, Grafana, Datadog, Elastic Stack.

### 10. Involve the Whole Team

Shared ownership across developers, ops, QA. Regular retrospectives and post-incident reviews. Feedback loops drive incremental pipeline improvements.

### 11. Implement Progressive Delivery

Extend CI/CD with controlled rollout mechanisms:

- **Canary deployment** — small % of users first; monitor; expand gradually
- **Geographic rollout** — West US → East US → global
- **Feature flags** — decouple deployment from release; enable/disable without redeploy

See [Progressive Delivery](../concepts/progressive-delivery.md).

### 12. Choose CI/CD Tools with Care

Evaluate for: scalability (grows with org), integration (existing toolchain), community support. Prefer SaaS to reduce operational burden; be ready to insource complex components. Open-source tools provide community resources.

### 13. Culture of Continuous Improvement

Psychological safety for feedback sharing. Regular pipeline reviews driven by metrics. Automate repetitive tasks iteratively. Retrospectives + post-incident reviews surfacing both successes and failures.

## Key Takeaways

- Artifact immutability: build once, promote the same artifact — eliminates environment-specific build divergence
- Progressive delivery bridges CI/CD and production safety: feature flags + canary = controlled risk
- Monitor DORA metrics (lead time, deploy frequency, MTTR, change failure rate) as pipeline health indicators
- DRY pipelines via templates/shared libraries reduce configuration drift across teams

## See Also

- [Continuous Integration](../concepts/continuous-integration.md)
- [Progressive Delivery](../concepts/progressive-delivery.md)
- [CI/CD Security](../concepts/cicd-security.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [Immutable Infrastructure](../concepts/immutable-infrastructure.md)
