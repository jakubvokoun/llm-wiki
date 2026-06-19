---
title: "Predefined CI/CD Variables Reference (GitLab)"
tags: [gitlab, ci-cd, variables, reference]
sources: [gitlab-ci-predefined-variables.md]
updated: 2026-04-23
---

# Predefined CI/CD Variables Reference (GitLab)

GitLab provides 100+ predefined CI/CD variables available in every pipeline. Avoid overriding them as it causes unpredictable behavior.

## Variable availability phases

Variables are available at one of three phases:

| Phase            | When available                    | Can use in                                |
| ---------------- | --------------------------------- | ----------------------------------------- |
| **Pre-pipeline** | Before pipeline is created        | `include:rules`, `rules`, `workflow`      |
| **Pipeline**     | While GitLab creates the pipeline | `rules`, job config                       |
| **Job-only**     | When runner picks up the job      | `script`, `before_script`, `after_script` |

Job-only variables **cannot** be used in `workflow`, `include`, or `rules`. Pre-pipeline variables are the **only** ones usable in `include:rules`.

## Key variable groups

### Commit info (pre-pipeline)

- `CI_COMMIT_SHA` — full commit revision
- `CI_COMMIT_SHORT_SHA` — first 8 characters
- `CI_COMMIT_REF_NAME` — branch or tag name
- `CI_COMMIT_REF_SLUG` — URL-safe slug (63 bytes, lowercase, non-alphanumeric → `-`)
- `CI_COMMIT_BRANCH` — branch name (not available in MR or tag pipelines)
- `CI_COMMIT_TAG` — tag name (only in tag pipelines)
- `CI_COMMIT_TITLE`, `CI_COMMIT_MESSAGE`, `CI_COMMIT_AUTHOR`

### Pipeline info

- `CI_PIPELINE_ID` (job-only) — instance-unique pipeline ID
- `CI_PIPELINE_IID` (pipeline) — project-level pipeline ID
- `CI_PIPELINE_SOURCE` (pre-pipeline) — trigger source: `push`, `merge_request_event`, `schedule`, `api`, `trigger`, etc.
- `CI_PIPELINE_NAME` (pre-pipeline) — name from `workflow:name`

### Job info

- `CI_JOB_ID` (job-only) — instance-unique job ID
- `CI_JOB_NAME`, `CI_JOB_STAGE` (pipeline)
- `CI_JOB_TOKEN` (job-only) — auth token valid only while job runs
- `CI_JOB_URL` (job-only) — job details URL

### Project info (pre-pipeline)

- `CI_PROJECT_ID`, `CI_PROJECT_PATH`, `CI_PROJECT_NAME`, `CI_PROJECT_URL`
- `CI_PROJECT_NAMESPACE`, `CI_PROJECT_ROOT_NAMESPACE`
- `CI_PROJECT_VISIBILITY` — `public`, `internal`, `private`

### Registry (pre-pipeline / job-only)

- `CI_REGISTRY` — container registry host
- `CI_REGISTRY_IMAGE` — base address for this project's images
- `CI_REGISTRY_USER`, `CI_REGISTRY_PASSWORD` (job-only) — tied to `CI_JOB_TOKEN`
- `CI_DEPENDENCY_PROXY_*` — Dependency Proxy addresses and credentials

### Server info (pre-pipeline)

- `CI_SERVER_URL`, `CI_SERVER_HOST`, `CI_SERVER_PORT`, `CI_SERVER_FQDN`
- `CI_SERVER_VERSION_MAJOR`, `CI_SERVER_VERSION_MINOR`, `CI_SERVER_VERSION_PATCH`
- `CI_API_V4_URL`, `CI_API_GRAPHQL_URL`
- `CI_TEMPLATE_REGISTRY_HOST` — defaults to `registry.gitlab.com`

### Runner info (job-only)

- `CI_RUNNER_ID`, `CI_RUNNER_VERSION`, `CI_RUNNER_TAGS`
- `CI_RUNNER_EXECUTABLE_ARCH`
- `CI_PROJECT_DIR` — clone path

### Merge request pipelines

Available as pre-pipeline variables when in an MR pipeline:

- `CI_MERGE_REQUEST_IID`, `CI_MERGE_REQUEST_ID`
- `CI_MERGE_REQUEST_SOURCE_BRANCH_NAME`, `CI_MERGE_REQUEST_TARGET_BRANCH_NAME`
- `CI_MERGE_REQUEST_EVENT_TYPE` — `detached`, `merged_result`, `merge_train`
- `CI_MERGE_REQUEST_APPROVED` — `true` if approved
- `CI_MERGE_REQUEST_LABELS`, `CI_MERGE_REQUEST_MILESTONE`, `CI_MERGE_REQUEST_ASSIGNEES`
- `CI_MERGE_REQUEST_DRAFT` — `true` if draft

### Upstream pipelines (pre-pipeline)

New in recent versions:

- `CI_UPSTREAM_PIPELINE_ID`, `CI_UPSTREAM_JOB_ID`, `CI_UPSTREAM_PROJECT_ID`

## Special variables

- `CI_OPEN_MERGE_REQUESTS` — up to 4 MRs associated with the current branch
- `CI_DEPLOY_FREEZE` — `true` if inside a deploy freeze window
- `CI_KUBERNETES_ACTIVE` — `true` if a Kubernetes cluster is available
- `KUBECONFIG` — path to kubeconfig when GitLab agent is authorized
- `TRIGGER_PAYLOAD` — webhook payload for webhook-triggered pipelines

## Auto DevOps variables

When Auto DevOps is enabled:

- `AUTO_DEVOPS_EXPLICITLY_ENABLED: 1`
- `STAGING_ENABLED`, `INCREMENTAL_ROLLOUT_MODE`

## Integration variables (job-only)

- Harbor: `HARBOR_URL`, `HARBOR_HOST`, `HARBOR_PROJECT`, `HARBOR_USERNAME`, `HARBOR_PASSWORD`
- Apple App Store Connect: `APP_STORE_CONNECT_API_KEY_*`
- Google Play: `SUPPLY_PACKAGE_NAME`, `SUPPLY_JSON_KEY_DATA`
- Diffblue Cover: `DIFFBLUE_LICENSE_KEY`, `DIFFBLUE_ACCESS_TOKEN*`

## Related

- [GitLab entity](../entities/gitlab.md)
- [GitLab CI/CD Variables concept](../concepts/gitlab-ci-variables.md)
