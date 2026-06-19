---
title: "Debugging GitLab CI/CD Pipelines"
tags: [gitlab, ci-cd, debugging, troubleshooting]
sources: [gitlab-ci-debugging.md]
updated: 2026-04-23
---

# Debugging GitLab CI/CD Pipelines

Official GitLab debugging guide covering syntax verification, variable inspection, dependency pinning, artifact-based debugging, and common pipeline issues.

## Debugging techniques

### 1. Verify syntax

- **Pipeline editor**: recommended; has code completion, syntax highlighting, config visualization.
- **Local**: use SchemaStore-aware editor (auto-loads GitLab CI/CD schema).
- **CI Lint tool**: paste full `.gitlab-ci.yml` or individual jobs; can simulate a full pipeline.

### 2. Use pipeline names

Name pipelines via `workflow:name` for fast identification in the pipelines list:

```yaml
variables:
  PIPELINE_NAME: "Default pipeline name"

workflow:
  name: "$PIPELINE_NAME"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      variables:
        PIPELINE_NAME: "Merge request pipeline"
    - if: "$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH"
      variables:
        PIPELINE_NAME: "Default branch pipeline"
```

### 3. Verify variables

Export all variables in a debug job:

```yaml
debug-vars:
  script:
    - export
```

Use optional debug-flag variables for on-demand verbosity:

```yaml
my-job:
  variables:
    DEBUG_VARS: ""
  script:
    - my-tool $DEBUG_VARS /test-dirs
```

Trigger manually with `DEBUG_VARS=--verbose` to enable verbose output.

### 4. Verify dependency versions

```yaml
job:
  before_script:
    - node --version
    - yarn --version
  script:
    - my-tests.sh
```

Pin versions to avoid surprise breaks:

```yaml
variables:
  ALPINE_VERSION: "3.18.6"

job1:
  image: alpine:$ALPINE_VERSION
```

### 5. Make output verbose, save artifacts

Use `--verbose` instead of `--silent`. Save generated files as artifacts for post-run inspection:

```yaml
job1:
  script:
    - my-tool --json-output my-output.json
  artifacts:
    paths:
      - my-output.json
```

### 6. Run commands locally

Use Rancher Desktop (or similar) to run the job's container image locally, then execute the job's `script` commands in that container.

### 7. GitLab Duo Root Cause Analysis

Use GitLab Duo Chat to troubleshoot failed CI/CD jobs with AI-powered root cause analysis.

## Common job configuration issues

### Jobs/pipelines don't run when expected

Cause: `rules` or `only/except` misconfiguration.

- Check `CI_PIPELINE_SOURCE`, `CI_MERGE_REQUEST_ID`, and other predefined variables.
- Don't mix `rules` and `only/except` in the same pipeline.
- `only/except` and `rules` have different semantics — check carefully when migrating.

### `changes` keyword runs unexpectedly

`changes` always evaluates to `true` in scheduled pipelines and tag pipelines. Only use `changes` with `if` conditions that restrict to branch or MR pipelines.

### Two pipelines run simultaneously

Caused by pushing to a branch that has an open MR. Use `workflow: rules` or restructure `rules` to prevent duplicate pipelines.

### `.gitlab-ci.yml` with BOM causes silent failures

A UTF-8 Byte Order Mark (BOM) in the YAML file causes silent config failures — jobs missing, variables with wrong values. The pipeline editor can't display BOM characters; use an external tool.

### Pipeline with many jobs fails to start

Exceeds the instance's CI/CD job limits. Split into parent-child pipelines.

### No pipeline runs (`.pre`/`.post` only)

A pipeline with only `.pre` or `.post` stage jobs does not run. At least one job must be in a different stage.

## Pipeline errors reference

| Error                                      | Cause                                               | Fix                                           |
| ------------------------------------------ | --------------------------------------------------- | --------------------------------------------- |
| `yaml invalid`                             | Syntax error                                        | Use pipeline editor or CI Lint                |
| `Identity verification required`           | GitLab.com free plan abuse prevention               | Verify email/phone/payment                    |
| `A CI/CD pipeline must run before merge`   | **Pipelines must succeed** enabled                  | Disable setting or fix pipeline               |
| `Project not found or access denied`       | `include` references inaccessible project           | Fix path; grant CI/CD permissions             |
| `The parsed YAML is too big`               | YAML too large (~200 KB+)                           | Use parent-child pipelines; remove duplicates |
| `Failed to pull image`                     | `CI_JOB_TOKEN` not in project's allowlist           | Add project to job token allowlist            |
| `config contains unknown keys`             | Typo or wrong indentation                           | Check keyword spelling and YAML indentation   |
| `config should be an array of hashes`      | Multiple `!reference` tags in non-supported keyword | Use YAML anchors instead                      |
| `content not found` (component `@~latest`) | No catalog release exists                           | Create and publish a release                  |

## Warning: `Job may allow multiple pipelines to run`

When `rules` has a `when` clause without an `if` clause, multiple pipelines can run. Add `if` conditions or use `workflow: rules`.

## Related

- [GitLab CI/CD Variables](../concepts/gitlab-ci-variables.md)
- [GitLab entity](../entities/gitlab.md)
- [GitLab CI Pipeline Security](gitlab-ci-pipeline-security.md)
