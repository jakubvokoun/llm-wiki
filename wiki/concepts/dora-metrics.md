---
title: "DORA Metrics"
tags: [devops, ci-cd, metrics, dora, deployment, lead-time, mttr]
sources: [harness-cicd-best-practices.md, launchdarkly-cicd-best-practices.md]
updated: 2026-04-23
---

# DORA Metrics

The four DORA (DevOps Research and Assessment) metrics are the industry-standard measure of software delivery performance. Developed by DORA (now part of Google Cloud) through research on thousands of development teams.

## The Four Metrics

| Metric                           | What It Measures                             | High Performer Benchmark |
| -------------------------------- | -------------------------------------------- | ------------------------ |
| **Deployment Frequency**         | How often code reaches production            | Multiple times per day   |
| **Lead Time for Changes**        | Commit → production deployment               | Less than 1 hour         |
| **Change Failure Rate**          | % of deployments causing incidents/rollbacks | Less than 5%             |
| **Mean Time to Recovery (MTTR)** | Time to restore service after failure        | Less than 1 hour         |

## Performance Bands

DORA research classifies teams into four bands:

| Band       | Deploy Freq    | Lead Time      | Change Failure Rate | MTTR         |
| ---------- | -------------- | -------------- | ------------------- | ------------ |
| **Elite**  | Multiple/day   | <1 hour        | 0–5%                | <1 hour      |
| **High**   | Weekly–daily   | 1 day–1 week   | 5–10%               | <1 day       |
| **Medium** | Monthly–weekly | 1 week–1 month | 10–15%              | 1 day–1 week |
| **Low**    | < monthly      | 1–6 months     | 15–64%              | >1 week      |

## What Each Metric Tells You

**Deployment Frequency** — proxy for batch size and automation maturity. Low frequency often signals large, risky releases, manual steps, or fear of deploying.

**Lead Time for Changes** — measures the feedback loop from idea to production. Long lead times indicate queuing, approval bottlenecks, slow test suites, or environment provisioning delays.

**Change Failure Rate** — quality signal. High rates indicate insufficient testing, poor rollout practices, or insufficient environment parity between staging and production.

**MTTR** — resilience signal. Slow recovery indicates poor observability, manual rollback processes, or lack of on-call tooling.

## Using DORA Metrics

### Starting Out

Track all four, but focus first on what's worst:

- Slow lead time → improve build/test speed, parallelize
- High failure rate → add testing layers, improve staging parity
- Slow MTTR → improve monitoring, add canary/rollback automation
- Low frequency → identify the fear/friction preventing more deploys

### Advanced Additions

Once DORA baselines are stable, add:

- **Build time** — leading indicator for lead time
- **Test flakiness rate** — erodes confidence in CI results
- **CI queue time** — measures runner capacity issues
- **Time waiting for approvals** — approval process bottleneck

### Making Metrics Visible

- Dashboard visible to entire team
- Review in sprint retrospectives
- Connect process changes to metric movement (before/after)

## Relationship to CI/CD Practices

| DORA Metric          | CI/CD Practices That Move It                                   |
| -------------------- | -------------------------------------------------------------- |
| Deployment Frequency | Trunk-based dev, feature flags, automated pipeline             |
| Lead Time            | Fast builds, intelligent test selection, automated deploys     |
| Change Failure Rate  | Testing pyramid, environment parity, progressive delivery      |
| MTTR                 | Canary rollback, feature flag kill switch, monitoring/alerting |

## Common Pitfalls

- **Gaming metrics** — deploying trivial changes just to boost frequency
- **Ignoring MTTR** — teams focus on speed but neglect recovery capability
- **Aggregate only** — average MTTR hides bimodal distribution (most fast, some catastrophic)
- **No baseline** — improving without measuring initial state makes progress invisible

## Related Concepts

- [Continuous Integration](continuous-integration.md)
- [Progressive Delivery](progressive-delivery.md)
- [CI/CD Security](cicd-security.md)
- [GitOps](gitops.md)
