---
title: "Progressive Delivery"
tags: [ci-cd, devops, feature-flags, canary, deployment, rollout]
sources: [launchdarkly-cicd-best-practices.md]
updated: 2026-04-23
---

# Progressive Delivery

Progressive delivery extends Continuous Delivery (CD) by adding control mechanisms that reduce deployment risk. Instead of all-at-once releases, changes reach users gradually and can be halted or reversed based on observed behavior.

## Core Idea

**Decouple deployment from release.** Code is deployed to production but features are gated behind feature flags or traffic-routing rules. This separates the act of shipping code from the act of exposing functionality to users.

## Techniques

### Canary Deployment

Route a small percentage of traffic (e.g., 1–5%) to the new version. Monitor error rates, latency, and business metrics. Expand traffic incrementally if healthy; roll back instantly if not.

```
100% → old version
  5% → new version  ← monitor here
```

### Blue-Green Deployment

Two identical production environments (blue = current, green = new). Switch routing when green is validated. Instant rollback = switch back to blue.

### Feature Flags

Toggle features at runtime without redeploying. Enables:

- **Dark launches** — deploy code with feature off; turn on for select users
- **Percentage rollouts** — 1% → 10% → 50% → 100%
- **Cohort targeting** — beta users, internal employees, specific regions
- **Kill switches** — instant disable of problematic features

Tools: LaunchDarkly, Unleash, Flagsmith, OpenFeature.

### Geographic / Cohort Rollout

Sequence: internal users → beta users → West US → East US → EMEA → global. Each stage is a checkpoint where metrics are reviewed.

## Benefits

| Benefit                  | Mechanism                                                    |
| ------------------------ | ------------------------------------------------------------ |
| **Reduced blast radius** | Only a fraction of users hit new code initially              |
| **Production testing**   | Real traffic validates behavior that staging can't reproduce |
| **Instant rollback**     | Feature flag off or traffic re-route; no redeploy needed     |
| **Confidence**           | Teams ship more frequently when risk per release is lower    |

## Relationship to CI/CD

```
CI/CD pipeline → artifact deployed to production
Feature flag → controls user exposure
```

CI/CD ensures code is always deployable; progressive delivery controls when it is experienced.

## DORA Metrics Connection

Progressive delivery directly improves DORA metrics:

- **Deployment Frequency** ↑ — lower risk per deploy encourages more frequent releases
- **Lead Time for Changes** ↓ — code ships without waiting for a safe release window
- **Change Failure Rate** ↓ — early signals from canary/flag targeting catch issues before full rollout
- **MTTR** ↓ — instant flag disable vs. full rollback and redeploy

## Related Concepts

- [Continuous Integration](continuous-integration.md)
- [CI/CD Security](cicd-security.md)
- [Immutable Infrastructure](immutable-infrastructure.md)
- [GitOps](gitops.md)
