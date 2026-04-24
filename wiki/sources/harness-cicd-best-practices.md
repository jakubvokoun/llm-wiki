---
title: "CI/CD Best Practices (Harness)"
tags:
  [
    ci-cd,
    devops,
    dora-metrics,
    trunk-based-development,
    test-intelligence,
    progressive-delivery,
  ]
sources: [harness-cicd-best-practices.md]
updated: 2026-04-23
---

# CI/CD Best Practices (Harness)

Harness guide (Chinmay Gaikwad, March 2026) covering 12 CI/CD practices. Distinguishes itself with trunk-based development, intelligent test selection, DORA metrics, and artifact immutability as named practices.

## 12 Practices

### 1. Commit Early, Commit Often (Trunk-Based Development)

- Merge into main at least once per developer per day
- Short-lived branches; avoid long feature branches
- Run fast local checks before push to avoid trivial CI failures
- **Trunk-based development:** main branch is always releasable; feature branches live < 1 day
- Intelligent pipelines run only affected tests per commit
- Use CI analytics to track build/test performance trends

### 2. Get Back to Green Quickly

Broken build = top priority to fix. A build that never turns red isn't tested well enough. Occasional broken builds are acceptable; teams prioritize restoring green. Use Test Intelligence (run only affected tests) to keep feedback fast.

### 3. Build Only Once (Artifact Immutability)

**Artifact immutability:** build once, promote the exact same artifact through dev → staging → production. Multiple builds of the same source introduce subtle environment drift. Centralize artifacts in a single repository (JFrog Artifactory, Nexus, OCI registry).

### 4. Standardize Pipelines with Templates and DRY

Platform teams define golden-path pipeline templates encoding required stages (build, unit tests, security scans, deploy). Product teams extend without copy-paste. Changes to the template propagate everywhere. Tools: Jenkins Shared Libraries, GitLab CI templates, Harness pipeline templates.

### 5. Streamline Tests

- **Layers:** unit (fast, run every commit) → integration → minimal E2E
- **Intelligent test selection:** Test Impact Analysis runs only tests affected by each change
- **Parallelize:** split across workers; total time = infrastructure, not codebase size
- **Prune:** remove duplicates, isolate/fix flaky tests
- **Metrics:** track duration, failure rate, flakiness trends via CI analytics

### 6. Secure the Pipeline (DevSecOps)

- Secrets out of source control; use a secrets manager
- RBAC + SSO + MFA for pipeline and environment access
- Embed SAST, DAST, container scanning, SBOM generation, and policy-as-code
- Audit trails for every deployment (who, what, when, where)

### 7. Clean Environments

- IaC-defined environments (Terraform, CloudFormation, K8s manifests)
- Versioned, reproducible, disposable environments
- Automatic cleanup after each deployment to prevent configuration drift

### 8. Pipeline as the Only Path to Production

No manual deployments or ad-hoc production changes. All changes flow through the pipeline. Provides standardized process, auditable trail, and consistent rollback capability.

### 9. Release Progressively

Canary deployments (small traffic %, monitor, expand) and feature flags (decouple code deploy from feature release). See [Progressive Delivery](../concepts/progressive-delivery.md).

### 10. Monitor and Measure

Track pipeline basics: duration, failure hotspots, deployment success/rollback rate. Iterative feedback loop: measure → identify bottleneck → improve → measure.

### 11. DORA Metrics

The four DORA metrics quantify delivery health:

| Metric                           | Measures                            |
| -------------------------------- | ----------------------------------- |
| **Deployment Frequency**         | How often changes reach production  |
| **Lead Time for Changes**        | Commit → production deployment time |
| **Change Failure Rate**          | % of deployments causing incidents  |
| **Mean Time to Recovery (MTTR)** | Time to restore after failure       |

High performers: daily+ deployments, <1h lead time, <5% failure rate, <1h MTTR. Advanced additions: build time, test flakiness, approval wait time.

### 12. Make It a Team Effort

Shared ownership across dev, test, ops. RBAC for appropriate access levels. Retrospectives and cross-functional collaboration. CI/CD as culture, not just tooling.

## Summary Matrix

| Practice                   | Why It Matters                | Outcome                |
| -------------------------- | ----------------------------- | ---------------------- |
| Small frequent commits     | Reduces merge conflicts       | Faster feedback cycles |
| Build once, promote        | Prevents artifact drift       | Reliable releases      |
| Intelligent test selection | Reduces pipeline time         | Faster CI              |
| Progressive delivery       | Limits blast radius           | Safer deployments      |
| DORA metrics tracking      | Measures delivery performance | Continuous improvement |

## Key Takeaways

- **Trunk-based development** is the gold standard: main always deployable, branches < 1 day
- **Artifact immutability** prevents "it worked in staging" failures by promoting identical binaries
- **Test Impact Analysis** makes frequent commits feasible even in large codebases
- DORA metrics are the standard health check for CI/CD maturity

## See Also

- [Continuous Integration](../concepts/continuous-integration.md)
- [Progressive Delivery](../concepts/progressive-delivery.md)
- [DORA Metrics](../concepts/dora-metrics.md)
- [CI/CD Security](../concepts/cicd-security.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
