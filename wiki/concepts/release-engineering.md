---
title: "Release Engineering"
tags:
  [
    sre,
    release-engineering,
    builds,
    deployment,
    configuration-management,
    devops,
  ]
sources: [sre-book-release-engineering.md]
updated: 2026-04-24
---

# Release Engineering

Release engineering is the discipline of building and delivering software reliably and repeatably. Reliable services require reliable release processes — releases must be reproducible, not "unique snowflakes."

## Core Principles

### Self-Service Model

Teams control their own release processes via shared tooling and best practices. Release engineers enable teams rather than being gatekeepers. Releases can be fully automated; engineers are only involved when problems arise.

### High Velocity

Frequent releases = fewer changes per release = easier testing and debugging. Common patterns:

- **Hourly builds** with human selection of which build to deploy
- **Push on Green** — automatically deploy every build that passes all tests

### Hermetic Builds

A build is hermetic when the same source revision + same build tool version always produces the exact same binary, regardless of the build machine or its installed libraries.

- Build environment is self-contained; no external service dependencies at build time
- Build tools themselves are versioned alongside the project
- Enables reproducible cherry-pick rebuilds: rebuild at original revision + specific additional commits

### Policy and Procedure Enforcement

Gated operations requiring approval:

- Source code change approval (code review)
- Release creation
- Cherry-pick approval
- Canary and production deployment
- Build configuration changes

Automated audit trail of all changes in every release.

## Release Pipeline

```
Source → Build → Branch → Test → Package → Deploy
```

| Stage   | What happens                                                                |
| ------- | --------------------------------------------------------------------------- |
| Build   | Declarative targets with explicit dependencies; build ID embedded in binary |
| Branch  | Branch from mainline at specific revision; bug fixes cherry-picked in       |
| Test    | Continuous tests on mainline + re-run on release branch                     |
| Package | Hash-versioned, signed packages with environment labels (dev/canary/prod)   |
| Deploy  | Simple: automated update; complex: progressive rollout over hours/days      |

**Cherry picking:** Bug fixes committed to mainline then selectively applied to the release branch. The release branch may contain code that never existed on mainline — so tests must be re-run on the branch itself.

## Configuration Management

Configuration changes are a major source of instability. Key patterns:

| Pattern                    | Best for                                         | Trade-off                                    |
| -------------------------- | ------------------------------------------------ | -------------------------------------------- |
| Mainline config            | Config decoupled from binary release             | Running config can drift from source         |
| Config bundled with binary | Config changes each release or rarely            | Tight coupling; simpler single package       |
| Config as separate package | Hermetic snapshot; change config without rebuild | Two packages; use labels to keep them paired |
| External store             | Dynamic config changes while service is running  | Runtime dependency; needs HA store           |

All approaches: store config in source control, enforce code review.

## Deployment Risk Profiles

Match rollout pace to risk:

- **Dev/pre-prod**: hourly builds, auto-push on green
- **Large user-facing services**: 1 cluster → exponential expansion → all clusters
- **Sensitive infrastructure**: multi-day rollout, interleaved across geographic regions

## When to Start

Release engineering is cheapest at the **beginning** of a project. Retrofitting reliable release processes onto a mature system is expensive. Teams should explicitly budget for release engineering from the start of the development cycle.

## Related Pages

- [Continuous Integration](continuous-integration.md)
- [Progressive Delivery](progressive-delivery.md)
- [Automation Hierarchy](automation-hierarchy.md)
- [Supply Chain Security](supply-chain-security.md)
- [Site Reliability Engineering](site-reliability-engineering.md)
- [DORA Metrics](dora-metrics.md)
- [Google SRE: Release Engineering (source)](../sources/sre-book-release-engineering.md)
