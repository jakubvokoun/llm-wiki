# Debugging CI/CD pipelines

* Tier: Free, Premium, Ultimate
* Offering: GitLab.com, GitLab Self-Managed, GitLab Dedicated

GitLab provides several tools to help make it easier to debug your CI/CD configuration.

If you are having issues with a specific CI/CD feature, see the related troubleshooting section for that feature:
Caching, CI/CD job tokens, Container registry, Docker, Downstream pipelines, Environments, GitLab Runner, ID tokens, Jobs, Job artifacts, Merge request pipelines, Pipeline editor, Variables, YAML `includes` keyword, YAML `script` keyword.

## Debugging techniques

### Verify syntax

An early source of problems can be incorrect syntax. The pipeline shows a `yaml invalid` badge and does not start running if any syntax or formatting problems are found.

#### Edit `.gitlab-ci.yml` with the pipeline editor

The pipeline editor is the recommended editing experience. It includes:
* Code completion suggestions that ensure you are only using accepted keywords.
* Automatic syntax highlighting and validation.
* The CI/CD configuration visualization, a graphical representation of your `.gitlab-ci.yml` file.

#### Edit `.gitlab-ci.yml` locally

You can use the GitLab CI/CD schema in your editor to verify basic syntax issues. Any editor with Schemastore support uses the GitLab CI/CD schema by default.

#### Verify syntax with CI Lint tool

You can use the CI Lint tool to verify that the syntax of a CI/CD configuration snippet is correct.
Paste in full `.gitlab-ci.yml` files or individual job configurations to verify the basic syntax.

When a `.gitlab-ci.yml` file is present in a project, you can also use the CI Lint tool to simulate the creation of a full pipeline for deeper verification.

### Use pipeline names

Use `workflow:name` to give names to all your pipeline types:

```yaml
variables:
  PIPELINE_NAME: "Default pipeline name"

workflow:
  name: '$PIPELINE_NAME'
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      variables:
        PIPELINE_NAME: "Merge request pipeline"
    - if: '$CI_PIPELINE_SOURCE == "schedule" && $PIPELINE_SCHEDULE_TYPE == "hourly_deploy"'
      variables:
        PIPELINE_NAME: "Hourly deployment pipeline"
    - if: '$CI_PIPELINE_SOURCE == "schedule"'
      variables:
        PIPELINE_NAME: "Other scheduled pipeline"
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
      variables:
        PIPELINE_NAME: "Default branch pipeline"
    - if: '$CI_COMMIT_BRANCH =~ /^\d{1,2}\.\d{1,2}-stable$/'
      variables:
        PIPELINE_NAME: "Stable branch pipeline"
```

### CI/CD variables

#### Verify variables

Export the full list of variables available in each problematic job. Check if the variables you expect are present, and check if their values are what you expect.

#### Use variables to add flags to CLI commands

Define CI/CD variables that are not used in standard pipeline runs, but can be used for debugging on demand:

```yaml
my-flaky-job:
  variables:
    DEBUG_VARS: ""
  script:
    - my-test-command $DEBUG_VARS /test-dirs
```

`DEBUG_VARS` is blank by default. To debug, run the pipeline manually and set `DEBUG_VARS` to `--verbose` for additional output.

### Dependencies

#### Verify dependency versions

Output dependency versions before running the main script commands:

```yaml
job:
  before_script:
    - node --version
    - yarn --version
  script:
    - my-javascript-tests.sh
```

#### Pin versions

Pin key dependencies and images to avoid surprise changes from updates:

```yaml
variables:
  ALPINE_VERSION: '3.18.6'

job1:
  image: alpine:$ALPINE_VERSION  # This will never change unexpectedly
  script:
    - my-test-script.sh

job2:
  image: alpine:latest  # This might suddenly change
  script:
    - my-test-script.sh
```

### Verify job output

#### Make output verbose

Avoid `--silent` flags in CI jobs. Use `--verbose` when possible for additional details:

```yaml
job1:
  script:
    - my-test-tool --silent         # If this fails, it might be impossible to identify the issue.
    - my-other-test-tool --verbose  # This command will likely be easier to debug.
```

#### Save output and reports as artifacts

Save tool output files as artifacts for later analysis:

```yaml
job1:
  script:
    - my-tool --json-output my-output.json
  artifacts:
    paths:
      - my-output.json
```

To make reports available for inspection:

```yaml
job1:
  script:
    - rspec --format RspecJunitFormatter --out rspec.xml
  artifacts:
    reports:
      junit: rspec.xml
    paths:
      - rspec.xml
```

Do not save tokens, passwords, or other sensitive information in artifacts.

### Run the job's commands locally

You can use a tool like Rancher Desktop to run the job's container image locally. Then run the job's `script` commands in the container and verify the behavior.

### Troubleshoot a failed job with Root Cause Analysis

You can use GitLab Duo Root Cause Analysis in GitLab Duo Chat to troubleshoot failed CI/CD jobs.

## Job configuration issues

A lot of common pipeline issues can be fixed by analyzing the behavior of `rules` or `only/except` configuration.
Don't mix `rules` and `only/except` in the same pipeline. `rules` is the preferred choice as `only`/`except` are no longer being actively developed.

### Jobs or pipelines don't run when expected

If a pipeline runs but a job is not added, it's usually due to `rules` or `only/except` configuration issues.

If a pipeline does not run at all with no error message, it may be due to `rules`, `only/except`, or `workflow: rules`.

### Unexpected behavior when `.gitlab-ci.yml` file contains a byte order mark (BOM)

A UTF-8 Byte-Order Mark (BOM) in the `.gitlab-ci.yml` file can lead to incorrect pipeline behavior.
The BOM affects parsing, causing some configuration to be ignored — jobs might be missing, and variables could have wrong values.

### A job with the `changes` keyword runs unexpectedly

`changes` always evaluates to `true` in certain pipeline types, including scheduled pipelines and pipelines for tags.

Use `changes` only with `if` sections in `rules` or `only/except` that ensure the job is only added to branch pipelines or merge request pipelines.

### Two pipelines run at the same time

Two pipelines can run when pushing a commit to a branch that has an open merge request. Usually one is a merge request pipeline and the other is a branch pipeline. Use `workflow: rules` or rewrite your rules to prevent duplicate pipelines.

### No pipeline or the wrong type of pipeline runs

A pipeline does not run if no jobs are added to it at the end of the evaluation.

If the wrong pipeline type ran, check `rules` or `only/except` configuration. Also check if `workflow: rules` blocked or allowed the wrong pipeline type.

### Pipeline with many jobs fails to start

A pipeline that has more jobs than the instance's defined CI/CD limits fails to start. Split `.gitlab-ci.yml` into independent parent-child pipelines to reduce the number of jobs.

## Pipeline warnings

Pipeline configuration warnings are shown when you validate configuration with CI Lint or manually run a pipeline.

### `Job may allow multiple pipelines to run for a single action` warning

When you use `rules` with a `when` clause without an `if` clause, multiple pipelines may run.
Use `workflow: rules` or rewrite your rules to prevent duplicate pipelines.

## Pipeline errors

### Error: `Identity verification is required in order to run CI jobs`

When using GitLab-hosted runners on GitLab.com with a free plan, you may need to complete identity verification. This prevents abuse of free compute resources. To complete:

1. In the alert banner, select **Verify my account**.
2. Follow the identity verification steps.
3. Create a new commit or manually trigger a new pipeline.

### `A CI/CD pipeline must run and be successful before merge` message

Shown if the **Pipelines must succeed** setting is enabled and a pipeline has not yet run successfully. Disable **Pipelines must succeed** if you don't use pipelines for your project.

### `Checking ability to merge automatically` message

If your merge request is stuck with this message, try:
* Refreshing the merge request page.
* Closing and re-opening the merge request.
* Rebasing with the `/rebase` quick action.
* Merging with the `/merge` quick action.

### `Checking pipeline status` message

Displayed when the merge request does not yet have a pipeline associated with the latest commit. Possible causes:
* GitLab hasn't finished creating the pipeline yet.
* Using an external CI service.
* CI/CD pipelines not configured for the project.
* `rules` or `only/except` prevented a pipeline from running on the source branch.
* The latest pipeline was deleted.
* The source branch of the merge request is on a private fork.

### `Project <group/project> not found or access denied` message

Shown if configuration is added with `include` and either the project cannot be found or the pipeline runner lacks access. Verify:
* The path format is `my-group/my-project` without repository folders.
* The user running the pipeline is a member of projects containing included files with CI/CD permissions.

### `The parsed YAML is too big` message

Shown when the YAML configuration is too large or nested too deeply. To reduce size:
* Check the expanded CI/CD configuration in the pipeline editor's Full configuration tab.
* Move long or repeated `script` sections into standalone scripts.
* Use parent and child pipelines to move work to independent child pipelines.

### `500` error when editing the `.gitlab-ci.yml` file

A loop of included configuration files can cause a `500` error. Ensure included configuration files do not create a loop of references.

### `Failed to pull image` messages

A runner returns `Failed to pull image` when:
* The **Limit access to this project** option is enabled in the private project hosting the image.
* The job attempting to fetch the image is running in a project not listed in the allowlist.

To resolve: add projects with CI/CD jobs that fetch images to the target project's job token allowlist.

#### Random or intermittent `Failed to pull image` errors

Can occur when users have different permissions to access images, combined with runner image caching. Bot users are commonly affected. Ensure all users that run pipelines, including bot users, can access the project hosting pulled images.

### `config contains unknown keys: <key-name>` error

Caused by:
* A typo in a keyword (e.g., `imag` instead of `image`).
* Incorrect spacing or indentation for a keyword or job.

Example:
```yaml
test-job:
  artifacts:
    path:        # Typo: should be `paths`
      - test
    image: test  # Wrong indentation: should be at the same level as `script`
  script:
    - echo
```
