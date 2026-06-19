---
title: "GitLab"
tags: [entity, org, product, devops, ci-cd]
sources:
  [
    gitlab-ci-predefined-variables.md,
    gitlab-ci-components.md,
    gitlab-ci-pipeline-security.md,
    gitlab-ci-debugging.md,
  ]
updated: 2026-04-23
---

# GitLab

GitLab is a DevSecOps platform providing source code management, CI/CD pipelines, container registry, security scanning, and more in a single application. Available as GitLab.com (SaaS), GitLab Self-Managed, and GitLab Dedicated.

## CI/CD

GitLab CI/CD is configured via `.gitlab-ci.yml`. Pipelines run on GitLab Runner (self-managed or GitLab-hosted). Key concepts:

- **Jobs**: units of work with `script`, `rules`, `artifacts`, etc.
- **Stages**: sequential groups of jobs
- **Pipelines**: triggered by push, merge request, schedule, API, webhook, ChatOps
- **Variables**: predefined (built-in) and user-defined; available at different phases

## CI/CD Catalog

A public/private registry of reusable [CI/CD components](../concepts/gitlab-ci-components.md) published as semantic-versioned releases. Available at `gitlab.com/explore/catalog` (GitLab.com) or the local instance's Explore > CI/CD Catalog.

## Tiers

- **Free**: All basic CI/CD features
- **Premium**: Advanced CI/CD, audit events, merge request approvals
- **Ultimate**: Security scanning, compliance, advanced governance

## Sources

- [GitLab CI Debugging](../sources/gitlab-ci-debugging.md)
