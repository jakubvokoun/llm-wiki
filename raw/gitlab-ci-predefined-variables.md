# Predefined CI/CD variables reference

* Tier: Free, Premium, Ultimate
* Offering: GitLab.com, GitLab Self-Managed, GitLab Dedicated

Predefined CI/CD variables are available in every GitLab CI/CD pipeline.

Avoid overriding predefined variables, as it can cause the pipeline to behave unexpectedly.

## Variable availability

Predefined variables become available at three different phases of pipeline execution:

* **Pre-pipeline**: Available before the pipeline is created. These are the only variables that can be used with `include:rules` to control which configuration files to use when creating the pipeline.
* **Pipeline**: Become available when GitLab is creating the pipeline. Can be used to configure `rules` defined in jobs.
* **Job-only**: Only made available to each job when a runner picks up the job and runs it.
  + Can be used in job scripts.
  + Cannot be used with trigger jobs.
  + Cannot be used with `workflow`, `include`, or `rules`.

## Predefined variables

| Variable | Availability | Description |
| --- | --- | --- |
| `CHAT_CHANNEL` | Pipeline | The Source chat channel that triggered the ChatOps command. |
| `CHAT_INPUT` | Pipeline | The additional arguments passed with the ChatOps command. |
| `CHAT_USER_ID` | Pipeline | The chat service's user ID of the user who triggered the ChatOps command. |
| `CI` | Pre-pipeline | Available for all jobs executed in CI/CD. `true` when available. |
| `CI_API_V4_URL` | Pre-pipeline | The GitLab API v4 root URL. |
| `CI_API_GRAPHQL_URL` | Pre-pipeline | The GitLab API GraphQL root URL. |
| `CI_BUILDS_DIR` | Job-only | The top-level directory where builds are executed. |
| `CI_COMMIT_AUTHOR` | Pre-pipeline | The author of the commit in `Name <email>` format. |
| `CI_COMMIT_BEFORE_SHA` | Pre-pipeline | The previous latest commit present on a branch or tag. |
| `CI_COMMIT_BRANCH` | Pre-pipeline | The commit branch name. Not available in merge request pipelines or tag pipelines. |
| `CI_COMMIT_DESCRIPTION` | Pre-pipeline | The description of the commit. |
| `CI_COMMIT_MESSAGE` | Pre-pipeline | The full commit message. |
| `CI_COMMIT_MESSAGE_IS_TRUNCATED` | Pre-pipeline | `true` if `CI_COMMIT_MESSAGE` is truncated. |
| `CI_COMMIT_REF_NAME` | Pre-pipeline | The branch or tag name for which project is built. |
| `CI_COMMIT_REF_PROTECTED` | Pre-pipeline | `true` if the job is running for a protected reference. |
| `CI_COMMIT_REF_SLUG` | Pre-pipeline | `CI_COMMIT_REF_NAME` in lowercase, shortened to 63 bytes, non-alphanumeric replaced with `-`. |
| `CI_COMMIT_SHA` | Pre-pipeline | The commit revision the project is built for. |
| `CI_COMMIT_SHORT_SHA` | Pre-pipeline | The first eight characters of `CI_COMMIT_SHA`. |
| `CI_COMMIT_TAG` | Pre-pipeline | The commit tag name. Available only in pipelines for tags. |
| `CI_COMMIT_TAG_MESSAGE` | Pre-pipeline | The commit tag message. Available only in pipelines for tags. |
| `CI_COMMIT_TIMESTAMP` | Pre-pipeline | The timestamp of the commit in ISO 8601 format. |
| `CI_COMMIT_TITLE` | Pre-pipeline | The title of the commit. The full first line of the message. |
| `CI_COMMIT_USER_LOGIN` | Pre-pipeline | The GitLab username of the commit author if profile and email are public. |
| `CI_CONCURRENT_ID` | Job-only | The unique ID of build execution in a single executor. |
| `CI_CONCURRENT_PROJECT_ID` | Job-only | The unique ID of build execution in a single executor and project. |
| `CI_CONFIG_PATH` | Pre-pipeline | The path to the CI/CD configuration file. Defaults to `.gitlab-ci.yml`. |
| `CI_CONFIG_REF_URI` | Pipeline | The fully qualified ref path to the top-level pipeline definition. |
| `CI_DEBUG_TRACE` | Pipeline | `true` if debug logging (tracing) is enabled. |
| `CI_DEBUG_SERVICES` | Pipeline | `true` if service container logging is enabled. |
| `CI_DEFAULT_BRANCH` | Pre-pipeline | The name of the project's default branch. |
| `CI_DEFAULT_BRANCH_SLUG` | Pre-pipeline | `CI_DEFAULT_BRANCH` in lowercase, shortened to 63 bytes. |
| `CI_DEPENDENCY_PROXY_DIRECT_GROUP_IMAGE_PREFIX` | Pre-pipeline | The direct group image prefix for pulling images through the Dependency Proxy. |
| `CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX` | Pre-pipeline | The top-level group image prefix for pulling images through the Dependency Proxy. |
| `CI_DEPENDENCY_PROXY_PASSWORD` | Pipeline | The password to pull images through the Dependency Proxy. |
| `CI_DEPENDENCY_PROXY_SERVER` | Pre-pipeline | The server for logging in to the Dependency Proxy. |
| `CI_DEPENDENCY_PROXY_USER` | Pipeline | The username to pull images through the Dependency Proxy. |
| `CI_DEPLOY_FREEZE` | Pre-pipeline | Only available if the pipeline runs during a deploy freeze window. `true` when available. |
| `CI_DEPLOY_PASSWORD` | Job-only | The authentication password of the GitLab Deploy Token. |
| `CI_DEPLOY_USER` | Job-only | The authentication username of the GitLab Deploy Token. |
| `CI_DISPOSABLE_ENVIRONMENT` | Pipeline | Only available if the job is executed in a disposable environment. `true` when available. |
| `CI_ENVIRONMENT_ID` | Pipeline | The ID of the environment for this job. |
| `CI_ENVIRONMENT_NAME` | Pipeline | The name of the environment for this job. |
| `CI_ENVIRONMENT_SLUG` | Pipeline | The simplified version of the environment name, suitable for DNS/URLs/Kubernetes labels. |
| `CI_ENVIRONMENT_URL` | Pipeline | The URL of the environment for this job. |
| `CI_ENVIRONMENT_ACTION` | Pipeline | The action annotation: `start`, `prepare`, or `stop`. |
| `CI_ENVIRONMENT_TIER` | Pipeline | The deployment tier of the environment for this job. |
| `CI_GITLAB_FIPS_MODE` | Pre-pipeline | Only available if FIPS mode is enabled. `true` when available. |
| `CI_HAS_OPEN_REQUIREMENTS` | Pipeline | Only available if the pipeline's project has an open requirement. `true` when available. |
| `CI_JOB_GROUP_NAME` | Pipeline | The shared name of a group of jobs when using `parallel` or manually grouped jobs. |
| `CI_JOB_ID` | Job-only | The internal ID of the job, unique across all jobs in the GitLab instance. |
| `CI_JOB_IMAGE` | Job-only | The name of the Docker image running the job. |
| `CI_JOB_MANUAL` | Pipeline | Only available if the job was started manually. `true` when available. |
| `CI_JOB_NAME` | Pipeline | The name of the job. |
| `CI_JOB_NAME_SLUG` | Pipeline | `CI_JOB_NAME` in lowercase, shortened to 63 bytes. |
| `CI_JOB_STAGE` | Pipeline | The name of the job's stage. |
| `CI_JOB_STATUS` | Job-only | The status of the job: `success`, `failed`, or `canceled`. |
| `CI_JOB_TIMEOUT` | Job-only | The job timeout, in seconds. |
| `CI_JOB_TOKEN` | Job-only | A token to authenticate with certain API endpoints. Valid only while the job is running. |
| `CI_JOB_URL` | Job-only | The job details URL. |
| `CI_JOB_STARTED_AT` | Job-only | The date and time when a job started, in ISO 8601 format. |
| `CI_JOB_STARTED_AT_SLUG` | Job-only | `CI_JOB_STARTED_AT` in lowercase, shortened to 63 bytes. Suitable for Docker image tags. |
| `CI_KUBERNETES_ACTIVE` | Pre-pipeline | Only available if the pipeline has a Kubernetes cluster available for deployments. |
| `CI_NODE_INDEX` | Pipeline | The index of the job in the job set. Only available if the job uses `parallel`. |
| `CI_NODE_TOTAL` | Pipeline | The total number of instances of this job running in parallel. |
| `CI_OPEN_MERGE_REQUESTS` | Pre-pipeline | A comma-separated list of up to four merge requests that use the current branch. |
| `CI_PAGES_DOMAIN` | Pre-pipeline | The instance's domain that hosts GitLab Pages (not including namespace subdomain). |
| `CI_PAGES_HOSTNAME` | Job-only | The full hostname of the Pages deployment. |
| `CI_PAGES_URL` | Job-only | The URL for a GitLab Pages site. |
| `CI_PIPELINE_ID` | Job-only | The instance-level ID of the current pipeline. Unique across all projects. |
| `CI_PIPELINE_IID` | Pipeline | The project-level IID of the current pipeline. Unique only in the current project. |
| `CI_PIPELINE_SOURCE` | Pre-pipeline | How the pipeline was triggered. |
| `CI_PIPELINE_TRIGGERED` | Pipeline | `true` for pipelines triggered with a trigger token. |
| `CI_PIPELINE_URL` | Job-only | The URL for the pipeline details. |
| `CI_PIPELINE_CREATED_AT` | Job-only | The date and time when the pipeline was created, in ISO 8601 format. |
| `CI_PIPELINE_NAME` | Pre-pipeline | The pipeline name defined in `workflow:name`. |
| `CI_PIPELINE_SCHEDULE_DESCRIPTION` | Pre-pipeline | The description of the pipeline schedule. Only available in scheduled pipelines. |
| `CI_PROJECT_DIR` | Job-only | The full path the repository is cloned to, and where the job runs from. |
| `CI_PROJECT_ID` | Pre-pipeline | The ID of the current project. Unique across all projects on the GitLab instance. |
| `CI_PROJECT_NAME` | Pre-pipeline | The name of the directory for the project. |
| `CI_PROJECT_NAMESPACE` | Pre-pipeline | The project namespace (username or group name) of the job. |
| `CI_PROJECT_NAMESPACE_ID` | Pre-pipeline | The project namespace ID of the job. |
| `CI_PROJECT_NAMESPACE_SLUG` | Pre-pipeline | `$CI_PROJECT_NAMESPACE` in lowercase with non-alphanumeric characters replaced with `-`. |
| `CI_PROJECT_PATH_SLUG` | Pre-pipeline | `$CI_PROJECT_PATH` in lowercase with non-alphanumeric characters replaced with `-`. |
| `CI_PROJECT_PATH` | Pre-pipeline | The project namespace with the project name included. |
| `CI_PROJECT_REPOSITORY_LANGUAGES` | Pre-pipeline | A comma-separated, lowercase list of the languages used in the repository (max 5). |
| `CI_PROJECT_ROOT_NAMESPACE` | Pre-pipeline | The root project namespace (username or group name) of the job. |
| `CI_PROJECT_TITLE` | Pre-pipeline | The human-readable project name as displayed in the GitLab web interface. |
| `CI_PROJECT_DESCRIPTION` | Pre-pipeline | The project description as displayed in the GitLab web interface. |
| `CI_PROJECT_TOPICS` | Pre-pipeline | A comma-separated, lowercase list of topics (limited to first 20) assigned to the project. |
| `CI_PROJECT_URL` | Pre-pipeline | The HTTP(S) address of the project. |
| `CI_PROJECT_VISIBILITY` | Pre-pipeline | The project visibility: `internal`, `private`, or `public`. |
| `CI_PROJECT_CLASSIFICATION_LABEL` | Pre-pipeline | The project external authorization classification label. |
| `CI_REGISTRY` | Pre-pipeline | Address of the container registry server. Only if container registry is enabled. |
| `CI_REGISTRY_IMAGE` | Pre-pipeline | Base address for the container registry for this project. Only if container registry is enabled. |
| `CI_REGISTRY_PASSWORD` | Job-only | The password to push containers to the project's container registry. Valid only while the job is running. |
| `CI_REGISTRY_USER` | Job-only | The username to push containers to the project's container registry. |
| `CI_RELEASE_DESCRIPTION` | Pipeline | The description of the release. Available only on pipelines for tags. |
| `CI_REPOSITORY_URL` | Job-only | The full path to Git clone (HTTP) the repository with a CI/CD job token. |
| `CI_RUNNER_DESCRIPTION` | Job-only | The description of the runner. |
| `CI_RUNNER_EXECUTABLE_ARCH` | Job-only | The OS/architecture of the GitLab Runner executable. |
| `CI_RUNNER_ID` | Job-only | The unique ID of the runner being used. |
| `CI_RUNNER_REVISION` | Job-only | The revision of the runner running the job. |
| `CI_RUNNER_SHORT_TOKEN` | Job-only | The runner's unique ID, used to authenticate new job requests. |
| `CI_RUNNER_TAGS` | Job-only | A JSON array of runner tags. |
| `CI_RUNNER_VERSION` | Job-only | The version of the GitLab Runner running the job. |
| `CI_SERVER_FQDN` | Pre-pipeline | The fully qualified domain name (FQDN) of the instance. |
| `CI_SERVER_HOST` | Pre-pipeline | The host of the GitLab instance URL, without protocol or port. |
| `CI_SERVER_NAME` | Pre-pipeline | The name of CI/CD server that coordinates jobs. |
| `CI_SERVER_PORT` | Pre-pipeline | The port of the GitLab instance URL. |
| `CI_SERVER_PROTOCOL` | Pre-pipeline | The protocol of the GitLab instance URL. |
| `CI_SERVER_SHELL_SSH_HOST` | Pre-pipeline | The SSH host of the GitLab instance. |
| `CI_SERVER_SHELL_SSH_PORT` | Pre-pipeline | The SSH port of the GitLab instance. |
| `CI_SERVER_REVISION` | Pre-pipeline | GitLab revision that schedules jobs. |
| `CI_SERVER_TLS_CA_FILE` | Pipeline | File containing the TLS CA certificate to verify the GitLab server. |
| `CI_SERVER_TLS_CERT_FILE` | Pipeline | File containing the TLS certificate to verify the GitLab server. |
| `CI_SERVER_TLS_KEY_FILE` | Pipeline | File containing the TLS key to verify the GitLab server. |
| `CI_SERVER_URL` | Pre-pipeline | The base URL of the GitLab instance, including protocol and port. |
| `CI_SERVER_VERSION_MAJOR` | Pre-pipeline | The major version of the GitLab instance. |
| `CI_SERVER_VERSION_MINOR` | Pre-pipeline | The minor version of the GitLab instance. |
| `CI_SERVER_VERSION_PATCH` | Pre-pipeline | The patch version of the GitLab instance. |
| `CI_SERVER_VERSION` | Pre-pipeline | The full version of the GitLab instance. |
| `CI_SERVER` | Job-only | Available for all jobs executed in CI/CD. `yes` when available. |
| `CI_SHARED_ENVIRONMENT` | Pipeline | Only available if the job is executed in a shared environment. `true` when available. |
| `CI_TEMPLATE_REGISTRY_HOST` | Pre-pipeline | The host of the registry used by CI/CD templates. Defaults to `registry.gitlab.com`. |
| `CI_TRIGGER_SHORT_TOKEN` | Job-only | First 4 characters of the trigger token of the current job. |
| `CI_UPSTREAM_JOB_ID` | Pre-pipeline | ID of the upstream trigger job that triggered the current pipeline. |
| `CI_UPSTREAM_PIPELINE_ID` | Pre-pipeline | ID of the upstream pipeline that triggered the current pipeline. |
| `CI_UPSTREAM_PROJECT_ID` | Pre-pipeline | ID of the upstream project that triggered the current pipeline. |
| `GITLAB_CI` | Pre-pipeline | Available for all jobs executed in CI/CD. `true` when available. |
| `GITLAB_FEATURES` | Pre-pipeline | The comma-separated list of licensed features available for the GitLab instance and license. |
| `GITLAB_USER_EMAIL` | Pipeline | The email of the user who started the pipeline. |
| `GITLAB_USER_ID` | Pipeline | The numeric ID of the user who started the pipeline. |
| `GITLAB_USER_LOGIN` | Pipeline | The unique username of the user who started the pipeline. |
| `GITLAB_USER_NAME` | Pipeline | The display name of the user who started the pipeline. |
| `KUBECONFIG` | Pipeline | The path to the `kubeconfig` file with contexts for every shared agent connection. |
| `TRIGGER_PAYLOAD` | Pipeline | The webhook payload. Only available when a pipeline is triggered with a webhook. |

## Predefined variables for merge request pipelines

These pre-pipeline variables are available when the pipeline is a merge request pipeline and the merge request is open.

| Variable | Description |
| --- | --- |
| `CI_MERGE_REQUEST_APPROVED` | Approval status of the merge request. `true` when approved. |
| `CI_MERGE_REQUEST_ASSIGNEES` | Comma-separated list of usernames of assignees. |
| `CI_MERGE_REQUEST_DIFF_BASE_SHA` | The base SHA of the merge request diff. |
| `CI_MERGE_REQUEST_DIFF_ID` | The version of the merge request diff. |
| `CI_MERGE_REQUEST_EVENT_TYPE` | The event type: `detached`, `merged_result`, or `merge_train`. |
| `CI_MERGE_REQUEST_DESCRIPTION` | The description of the merge request (first 2700 characters). |
| `CI_MERGE_REQUEST_DESCRIPTION_IS_TRUNCATED` | `true` if `CI_MERGE_REQUEST_DESCRIPTION` is truncated. |
| `CI_MERGE_REQUEST_ID` | The instance-level ID of the merge request. |
| `CI_MERGE_REQUEST_IID` | The project-level IID of the merge request. |
| `CI_MERGE_REQUEST_LABELS` | Comma-separated label names of the merge request. |
| `CI_MERGE_REQUEST_MILESTONE` | The milestone title of the merge request. |
| `CI_MERGE_REQUEST_PROJECT_ID` | The ID of the project of the merge request. |
| `CI_MERGE_REQUEST_PROJECT_PATH` | The path of the project of the merge request. |
| `CI_MERGE_REQUEST_PROJECT_URL` | The URL of the project of the merge request. |
| `CI_MERGE_REQUEST_REF_PATH` | The ref path of the merge request. |
| `CI_MERGE_REQUEST_SOURCE_BRANCH_NAME` | The source branch name of the merge request. |
| `CI_MERGE_REQUEST_SOURCE_BRANCH_PROTECTED` | `true` when the source branch is protected. |
| `CI_MERGE_REQUEST_SOURCE_BRANCH_SHA` | The HEAD SHA of the source branch. Present only in merged results pipelines. |
| `CI_MERGE_REQUEST_SOURCE_PROJECT_ID` | The ID of the source project of the merge request. |
| `CI_MERGE_REQUEST_SOURCE_PROJECT_PATH` | The path of the source project of the merge request. |
| `CI_MERGE_REQUEST_SOURCE_PROJECT_URL` | The URL of the source project of the merge request. |
| `CI_MERGE_REQUEST_SQUASH_ON_MERGE` | `true` when the squash on merge option is set. |
| `CI_MERGE_REQUEST_TARGET_BRANCH_NAME` | The target branch name of the merge request. |
| `CI_MERGE_REQUEST_TARGET_BRANCH_PROTECTED` | `true` when the target branch is protected. |
| `CI_MERGE_REQUEST_TARGET_BRANCH_SHA` | The HEAD SHA of the target branch. Present only in merged results pipelines. |
| `CI_MERGE_REQUEST_TITLE` | The title of the merge request. |
| `CI_MERGE_REQUEST_DRAFT` | `true` if the merge request is a draft. |

## Predefined variables for external pull request pipelines

Only available when using external pull request pipelines and the pull request is open.

| Variable | Description |
| --- | --- |
| `CI_EXTERNAL_PULL_REQUEST_IID` | Pull request ID from GitHub. |
| `CI_EXTERNAL_PULL_REQUEST_SOURCE_REPOSITORY` | The source repository name of the pull request. |
| `CI_EXTERNAL_PULL_REQUEST_TARGET_REPOSITORY` | The target repository name of the pull request. |
| `CI_EXTERNAL_PULL_REQUEST_SOURCE_BRANCH_NAME` | The source branch name of the pull request. |
| `CI_EXTERNAL_PULL_REQUEST_SOURCE_BRANCH_SHA` | The HEAD SHA of the source branch of the pull request. |
| `CI_EXTERNAL_PULL_REQUEST_TARGET_BRANCH_NAME` | The target branch name of the pull request. |
| `CI_EXTERNAL_PULL_REQUEST_TARGET_BRANCH_SHA` | The HEAD SHA of the target branch of the pull request. |

## Deployment variables

Integrations responsible for deployment configuration can define their own predefined variables.
These variables are only defined for deployment jobs. The documentation for each integration explains
if the integration has any deployment variables available.

## Auto DevOps variables

When Auto DevOps is enabled, some additional pre-pipeline variables are made available:

* `AUTO_DEVOPS_EXPLICITLY_ENABLED`: Has a value of `1` to indicate Auto DevOps is enabled.
* `STAGING_ENABLED`: See Auto DevOps deployment strategy.
* `INCREMENTAL_ROLLOUT_MODE`: See Auto DevOps deployment strategy.
* `INCREMENTAL_ROLLOUT_ENABLED`: Deprecated.

## Integration variables

Some integrations make job-only predefined variables available in jobs:

* Harbor: `HARBOR_URL`, `HARBOR_HOST`, `HARBOR_OCI`, `HARBOR_PROJECT`, `HARBOR_USERNAME`, `HARBOR_PASSWORD`
* Apple App Store Connect: `APP_STORE_CONNECT_API_KEY_ISSUER_ID`, `APP_STORE_CONNECT_API_KEY_KEY_ID`, `APP_STORE_CONNECT_API_KEY_KEY`, `APP_STORE_CONNECT_API_KEY_IS_KEY_CONTENT_BASE64`
* Google Play: `SUPPLY_PACKAGE_NAME`, `SUPPLY_JSON_KEY_DATA`
* Diffblue Cover: `DIFFBLUE_LICENSE_KEY`, `DIFFBLUE_ACCESS_TOKEN_NAME`, `DIFFBLUE_ACCESS_TOKEN`

## Troubleshooting

You can output the values of all variables available for a job with a `script` command.
