---
title: "GitLab CI/CD Components"
tags: [gitlab, ci-cd, components, catalog, reusability]
sources: [gitlab-ci-components.md]
updated: 2026-04-23
---

# GitLab CI/CD Components

CI/CD components are reusable single pipeline configuration units in GitLab (GA in GitLab 17.0).
They can be composed into larger pipelines, parameterized with inputs, versioned, and published
to the CI/CD Catalog.

## Component projects

A **component project** is a GitLab project hosting one or more components (max 100 per project).
All components in a project are versioned together. Each component is defined as either:

- A single YAML file: `templates/<name>.yml`
- A directory: `templates/<name>/template.yml` (only `template.yml` is used by consumers;
  other files like Dockerfiles or test scripts stay private)

Required structure:

```
├── templates/
│   ├── my-component.yml
│   └── my-other-component/
│       ├── template.yml
│       └── Dockerfile     # not exposed
├── README.md
├── LICENSE.md
└── .gitlab-ci.yml
```

## Using a component

```yaml
include:
  - component: $CI_SERVER_FQDN/my-org/security-components/secret-detection@1.0.0
    inputs:
      stage: build
```

Format: `<FQDN>/<project-path>/<component-name>@<version>`

Use `$CI_SERVER_FQDN` (not hardcoded domain) for cross-instance compatibility.

## Version specifiers

Priority order (highest first):

1. Commit SHA — `e3262fdd0914fa823210cdb79a8c421e2cef79d8`
2. Tag — `1.0.0` (SHA takes precedence over same-named tag)
3. Branch name — `main` (tag takes precedence over same-named branch)
4. Partial semver / `~latest` — resolves to latest published catalog version

Partial semver examples (from versions `1.0.0`, `1.1.0`, `1.1.1`, `1.2.0`, `2.0.0`, `2.1.0`):

- `1` → `1.2.0` (latest 1.x.x)
- `1.1` → `1.1.1` (latest 1.1.x)
- `~latest` → `2.1.0` (absolute latest)

Pre-releases excluded from partial version resolution. Only works with catalog-published components.

## Component `spec` section

```yaml
spec:
  inputs:
    stage:
      default: test
      description: "Pipeline stage to run in"
      type: string
  component: [name, version, reference] # opt-in context fields
---
my-job:
  stage: $[[ inputs.stage ]]
  image: my-registry.example.com/$[[ component.name ]]:$[[ component.version ]]
  script:
    - echo "Running $[[ component.version ]] (ref: $[[ component.reference ]])"
```

`spec:component` fields: `name`, `sha`, `version`, `reference`. Used for versioned resource
references (e.g., Docker image built at same version as component).

## Writing components: best practices

### Avoid global keywords

Never use `default:` or `stages:` in a component — they affect all jobs in the consumer's pipeline.
Instead, add config to each job directly or use `extends` with unique names:

```yaml
.my-comp:image-ruby:
  image: ruby:3.0

rspec-1:
  extends: .my-comp:image-ruby
  script: bundle exec rspec dir1/
```

### Use inputs instead of hardcoded values

Always parameterize `stage`, job names, image versions:

```yaml
spec:
  inputs:
    stage:
      default: test
    job-prefix:
      description: "Prefix for job name"
---
"$[[ inputs.job-prefix ]]-scan":
  stage: $[[ inputs.job-stage ]]
  script: scan
```

### Prefer inputs over CI/CD variables

Inputs provide type validation, required enforcement, and explicit contracts. Variables silently default to empty strings when missing.

### Conditional job configuration with boolean inputs

```yaml
spec:
  inputs:
    enable_caching:
      type: boolean
---
.my-comp:enable_caching:false:
  extends: null

.my-comp:enable_caching:true:
  cache:
    key: $CI_COMMIT_SHA
    paths: [...]

my-job:
  extends: ".my-comp:enable_caching:$[[ inputs.enable_caching ]]"
  script: run-tool
```

### Manage dependencies

- Minimize dependencies; duplication is better than coupling
- Pin external component versions to catalog releases, not `~latest`
- Use `include:local` for local file dependencies (same SHA guaranteed)
- Prefer Buildah over Docker to avoid requiring privileged runners

## CI/CD Catalog

Published components appear in the CI/CD Catalog (`Explore > CI/CD Catalog`).
Catalog visibility follows the source project visibility.

### Publishing to catalog

1. Enable **CI/CD Catalog project** toggle in project settings
2. Add a `release` job triggered by a semver tag:

```yaml
create-release:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  script: echo "Creating release $CI_COMMIT_TAG"
  rules:
    - if: $CI_COMMIT_TAG
  release:
    tag_name: $CI_COMMIT_TAG
    description: "Release $CI_COMMIT_TAG of components in $CI_PROJECT_PATH"
```

Must use the `release` CI/CD keyword (not the Releases API). Must use semantic versioning.

### Verified component badges

- **GitLab-maintained**: Created and maintained by GitLab.
- **GitLab Partner**: Verified partner components.
- **Verified creator**: User verified by instance admin (Self-Managed).

## Security best practices

### For users

- Audit and review component source code before using.
- Pin to commit SHA (preferred) or release tag. Avoid `~latest`.
- Use minimally scoped, short-lived tokens.
- Do not pass cache/artifacts from other jobs to component jobs unless necessary.
- Restrict `CI_JOB_TOKEN` access for projects using components.
- Review all changes before updating to a newer SHA or tag.

### For maintainers

- Require 2FA for all maintainers and owners.
- Use protected branches; set "Allowed to push and merge" to `No one`.
- Block force pushes.
- Sign all commits.
- Require MR approvals for all user-facing changes.
- Avoid `@latest` examples in README.
- Update dependencies regularly.

## Converting a CI/CD template to a component

1. Create or choose a component project.
2. Create `templates/<name>.yml` following directory structure.
3. Copy template content.
4. Refactor: move `image` from `default` to each job, add `inputs` for stage/version/names.
5. Test by including `$CI_SERVER_FQDN/$CI_PROJECT_PATH/<name>@$CI_COMMIT_SHA` in `.gitlab-ci.yml`.
6. Tag and release.

See [component examples](gitlab-ci-components-examples.md) for a complete Go migration walkthrough.

## Related

- [GitLab entity](../entities/gitlab.md)
- [GitLab CI/CD Components concept](../concepts/gitlab-ci-components.md)
- [Component examples](gitlab-ci-components-examples.md)
- [GitLab CI/CD Variables](../concepts/gitlab-ci-variables.md)
