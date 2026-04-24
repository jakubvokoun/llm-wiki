---
title: "GitLab CI: 10+ Best Practices to Avoid Anti-Patterns (Zenika)"
tags: [gitlab-ci, ci-cd, devops, yaml, docker, anti-patterns]
sources: [zenika-gitlab-ci-best-practices.md]
updated: 2026-04-23
---

# GitLab CI: 10+ Best Practices to Avoid Anti-Patterns (Zenika)

Practitioner guide from Zenika targeting common GitLab CI anti-patterns found in real projects. Companion article to [GitLab CI Optimization: 15+ Tips for Faster Pipelines](https://dev.to/zenika/gitlab-ci-optimization-15-tips-for-faster-pipelines-55al).

## 10 Practices

### 1. Versioned Public Docker Images, Not `latest`

Use well-maintained public images at pinned versions (e.g., `node:18.10-alpine`). Avoid `latest` — silent breaking changes cause mysterious failures. Prefer installing missing tools at runtime (`before_script: apk add git`) over building custom CI images upfront.

Custom CI images create maintenance cycles: someone must own the Dockerfile, upgrades are risky, and changes to one image can break other projects. Use the GitLab Dependency Proxy (`${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}/image:tag`) to avoid Docker Hub rate limits on autoscaling runners.

### 2. Start New Products in a Mono-Repo

| Aspect             | Multi-Repo              | Mono-Repo      |
| ------------------ | ----------------------- | -------------- |
| MR per feature     | Multiple                | One            |
| CI testing         | Advanced tooling needed | Works natively |
| Common code (libs) | Complex versioning      | Simple         |
| Cache sharing      | No                      | Yes            |
| Setup complexity   | Low                     | Medium–High    |

Mono-repos enable real continuous integration and avoid downstream pipeline dependencies. Common-code versioning in multi-repos is frequently underestimated.

### 3. Local GitLab CI YAML First

Start with local `.gitlab-ci.yml` files per project. Centralize to shared templates only after the third identical use case. Centralization adds: cross-repo commit/push cycle, risk of side effects on other projects, and version management overhead. Understand your CI/CD needs locally before abstracting.

### 4. Raw Commands in `script:`, Not Shell Wrappers

Prefer inline commands over Makefiles or shell scripts in CI jobs. Rationale: raw commands show exactly where failures occur; wrapping in scripts creates a black box that CI maintainers must debug for other developers. Use `gitlab-ci-local` for local job testing instead of Makefile shortcuts.

Exception: if a job script exceeds a few lines, a suitable CLI tool likely already exists — use it.

### 5. Use `workflow:rules` and `rules` (Not `only/except`)

`only/except` keywords are deprecated and no longer maintained. Use:

- `workflow:rules` — controls when a pipeline runs at all
- `rules` — fine-grained per-job trigger conditions

`rules` supports composition via `!reference` for reuse across job templates. Superior functionality and lower cognitive load for readers.

### 6. Abstract with `extends`, Not YAML Anchors

GitLab CI abstraction tools in order of preference:

1. `extends` — inherits from hidden job templates (`.job-template`)
2. `!reference` — composes specific fields from templates
3. YAML anchors (`&anchor`, `*anchor`) — file-scoped only, hard to follow

**Anti-pattern:** Duplicated `rules:` blocks across every job. **Fix:** Extract shared rules into a hidden job (`.dev:`) and `extends` it.

YAML anchors leak complexity and are limited to a single file. Nearly always, `extends` is the better choice.

### 7. Artifacts vs. Cache — Use Each as Intended

|                              | Artifacts                       | Cache                             |
| ---------------------------- | ------------------------------- | --------------------------------- |
| **Purpose**                  | Transmit data between jobs      | Speed up pipeline via reuse       |
| **Scope**                    | Within pipeline                 | Cross-pipeline                    |
| **Guaranteed delivery**      | Yes                             | No                                |
| **Stored on GitLab server**  | Yes                             | No                                |
| **Suitable for large files** | No                              | Yes                               |
| **Examples**                 | `dist/`, compiled jars, reports | `node_modules/`, `.m2/repository` |

Using cache where artifacts are needed (or vice versa) causes data loss or unnecessary re-downloads.

### 8. Split Jobs Wisely

**Too few jobs (monolithic job) problems:**

- Progress tracking difficult
- Custom image required (see #1)
- Risk of log limit hits
- Full restart on flaky failure
- Hinders runner resource optimization

**Too many jobs (over-splitting) problems:**

- Artifact/cache management overhead
- Caching takes wall-clock time
- Risk of duplicating steps (especially Maven)
- More stages → slower pipeline

Multi-stage Docker builds in CI are an anti-pattern when Docker runners already provide isolation — package in a job, pass artifact to image build job instead.

### 9. Use `needs` Keyword Wisely

`needs:` starts a job as soon as its dependencies finish, enabling parallel chains. Key rule: **stop `needs` chains before resource-consuming or critical steps** (container push, deployment). Without a stop, some modules may deploy at new version while others are still at old version — unstable application state.

Use synchronization jobs (a job with multiple `needs:`) to rejoin parallel chains before critical steps. **Avoid stageless pipelines** (all jobs in a single stage via `needs`): limited GitLab support, no real advantage over partial `needs` use.

### 10. Avoid Downstream Pipelines

**Child pipelines** (same project, triggered from parent): clunky UI, parent can't access child reports or artifacts, no auto-stop on sibling failure.

**Multi-project pipelines** (cross-project trigger): parent has limited control, can't access artifacts from triggered projects.

Need for downstream pipelines usually signals a repository architecture problem. **Fix:** switch to mono-repo — a single pipeline handles full CI/CD, simpler and faster.

## Key Anti-Patterns Summary

| Anti-Pattern                   | Recommended Alternative                      |
| ------------------------------ | -------------------------------------------- |
| `image: node:latest`           | `image: node:18.10-alpine`                   |
| Custom CI Docker image         | Install tools at runtime in `before_script:` |
| `only: / except:` keywords     | `workflow:rules:` and `rules:`               |
| YAML anchors for abstraction   | `extends:` and `!reference`                  |
| Cache for build output         | Artifacts for intra-pipeline data            |
| Multi-stage Docker build in CI | Job → artifact → image build job             |
| Downstream/child pipelines     | Mono-repo with single pipeline               |

## See Also

- [GitLab](../entities/gitlab.md)
- [GitLab CI/CD Components](../concepts/gitlab-ci-components.md)
- [GitLab CI Pipeline Security](../concepts/gitlab-ci-pipeline-security.md)
- [GitLab CI/CD Variables](../concepts/gitlab-ci-variables.md)
- [Continuous Integration](../concepts/continuous-integration.md)
