---
title: "GitLab CI/CD Variables"
tags: [gitlab, ci-cd, variables, configuration]
sources: [gitlab-ci-predefined-variables.md, gitlab-ci-pipeline-security.md]
updated: 2026-04-23
---

# GitLab CI/CD Variables

GitLab CI/CD variables are key-value pairs used to configure pipeline behavior and pass data between jobs. Two categories exist: predefined (built-in) and user-defined.

## Predefined variables

100+ built-in variables available in every pipeline. See [Predefined CI/CD Variables Reference](../sources/gitlab-ci-predefined-variables.md) for the full table.

### Availability phases

Variables become available at different pipeline phases, determining where they can be used:

| Phase        | Examples                                                 | Usable in                                     |
| ------------ | -------------------------------------------------------- | --------------------------------------------- |
| Pre-pipeline | `CI_COMMIT_SHA`, `CI_PROJECT_ID`, `CI_PIPELINE_SOURCE`   | `include:rules`, `rules`, `workflow`, scripts |
| Pipeline     | `CI_JOB_NAME`, `CI_PIPELINE_IID`, `GITLAB_USER_EMAIL`    | `rules`, scripts                              |
| Job-only     | `CI_JOB_TOKEN`, `CI_PROJECT_DIR`, `CI_REGISTRY_PASSWORD` | scripts only                                  |

**Critical rule**: Job-only variables cannot be used in `workflow`, `include`, or `rules`. Pre-pipeline variables are the only ones usable in `include:rules`.

## User-defined variables

Can be defined at project, group, or instance level. Security levels:

- **Masked**: value hidden in job logs
- **Hidden**: value not visible in settings UI
- **Protected**: only available in protected branches/tags

### Security considerations

Variables are stored in GitLab settings and users with access to settings can read them. They can be overridden via pipeline variables, making auditability harder.

**Guidance**: Store non-sensitive configuration in variables. Store secrets in a secrets manager (HashiCorp Vault, Azure Key Vault, Google Cloud Secret Manager). If using variables for secrets, always mask + hide + protect.

## CI/CD inputs vs variables

Prefer [`inputs`](./gitlab-ci-components.md) over CI/CD variables for parameterizing components and pipelines:

|                      | Inputs               | Variables                   |
| -------------------- | -------------------- | --------------------------- |
| Type validation      | Yes                  | No                          |
| Required enforcement | Yes (pipeline error) | No (empty string, no error) |
| Explicit contract    | Yes (`spec:inputs`)  | No                          |
| Scope                | Component/pipeline   | Project/group/instance      |

Consider disabling pipeline variables (`restrict pipeline variables` setting) when using inputs to prevent variable-based overrides that bypass type safety.

## Common patterns

### Debug flag variable

```yaml
my-flaky-job:
  variables:
    DEBUG_VARS: ""
  script:
    - my-test-command $DEBUG_VARS /test-dirs
```

Set `DEBUG_VARS=--verbose` when manually triggering a pipeline to enable verbose output.

### CI_PIPELINE_SOURCE values

`push`, `merge_request_event`, `schedule`, `api`, `trigger`, `pipeline`, `web`, `chat`, `parent_pipeline`

## Related

- [GitLab entity](../entities/gitlab.md)
- [GitLab CI/CD Components](./gitlab-ci-components.md)
- [GitLab CI Pipeline Security](./gitlab-ci-pipeline-security.md)
- [Predefined variables reference](../sources/gitlab-ci-predefined-variables.md)
