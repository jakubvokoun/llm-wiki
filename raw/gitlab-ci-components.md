# CI/CD components

* Tier: Free, Premium, Ultimate
* Offering: GitLab.com, GitLab Self-Managed, GitLab Dedicated

A CI/CD component is a reusable single pipeline configuration unit. Use components
to create a small part of a larger pipeline, or even to compose a complete pipeline configuration.

A component can be configured with input parameters for more dynamic behavior.

CI/CD components are similar to other kinds of configuration added with the `include` keyword,
but have several advantages:

* Components can be listed in the CI/CD Catalog.
* Components can be released and used with a specific version.
* Multiple components can be defined in the same project and versioned together.

## Component project

A component project is a GitLab project with a repository that hosts one or more components.
All components in the project are versioned together, with a maximum of 100 components per project.

If a component requires different versioning from other components, the component should be moved
to a dedicated component project.

### Create a component project

To create a component project, you must:

1. Create a new project with a `README.md` file:
   * Ensure the description gives a clear introduction to the component.

2. Add a YAML configuration file for each component, following the required directory structure. For example:

   ```yaml
   spec:
     inputs:
       stage:
         default: test
   ---
   component-job:
     script: echo job 1
     stage: $[[ inputs.stage ]]
   ```

### Directory structure

The repository must contain:

* A `README.md` file documenting the details of all the components in the repository.
* A top level `templates/` directory that contains all the component configurations.
  In this directory, you can:
  + Use single files ending in `.yml` for each component, like `templates/secret-detection.yml`.
  + Create subdirectories with a `template.yml` for each component,
    like `templates/secret-detection/template.yml`. Only the `template.yml` file is used by other projects.

You should also:

* Configure the project's `.gitlab-ci.yml` to test the components and release new versions.
* Add a `LICENSE.md` file.

Example single-component structure:

```
├── templates/
│   └── my-component.yml
├── LICENSE.md
├── README.md
└── .gitlab-ci.yml
```

Example multi-component structure:

```
├── templates/
│   ├── my-component.yml
│   └── my-other-component/
│       ├── template.yml
│       ├── Dockerfile
│       └── test.sh
├── LICENSE.md
├── README.md
└── .gitlab-ci.yml
```

## Use a component

To add a component to a project's CI/CD configuration, use the `include: component` keyword.
The component reference is formatted as `<fully-qualified-domain-name>/<project-path>/<component-name>@<specific-version>`:

```yaml
include:
  - component: $CI_SERVER_FQDN/my-org/security-components/secret-detection@1.0.0
    inputs:
      stage: build
```

In this example:
* `$CI_SERVER_FQDN` is the fully qualified domain name matching the GitLab host.
* `my-org/security-components` is the full path of the project containing the component.
* `secret-detection` is the component name.
* `1.0.0` is the version of the component.

Pipeline configuration and component configuration merge into the pipeline's configuration.
Make sure your pipeline and the component do not share configuration with the same name,
unless you intend to override the component's configuration.

### Component versions

In order of highest priority first, the component version can be:

* A commit SHA, for example `e3262fdd0914fa823210cdb79a8c421e2cef79d8`.
* A tag, for example: `1.0.0`. If a tag and commit SHA exist with the same name, the commit SHA takes precedence.
* A branch name, for example `main`. If a branch and tag exist with the same name, the tag takes precedence.
* `~latest` or a partial semantic version, which selects the latest version within the specified pattern published in the CI/CD Catalog.

#### Partial semantic versions

You can use partial semantic version numbers and `~latest` to select the latest published version matching your specification.

Use:
* `1.2` to select the latest `1.2.*` version
* `1` to select the latest `1.*.*` version
* `~latest` to select the latest released version

For example, a component has versions: `1.0.0`, `1.1.0`, `1.1.1`, `1.2.0`, `2.0.0`, `2.0.1`, `2.1.0`

When referencing the component:
* `1` selects `1.2.0`
* `1.1` selects `1.1.1`
* `~latest` selects `2.1.0`

Pre-release versions are never fetched when using partial version selection.

### Use component context in components

Components can access metadata about themselves with a component context CI/CD expression.
Use this expression to reference the version, commit SHA, and other metadata dynamically.

To use component context in a component, you must:

1. Declare which component context fields the component needs in the `spec:component` header.
   `spec:component` supports `name`, `sha`, `version`, and `reference` fields.
2. Reference the context fields using the CI/CD expression `$[[ component.field-name ]]` in the component template.

For example:

```yaml
spec:
  component: [name, version, reference]
  inputs:
    stage:
      default: build
---

build-image:
  stage: $[[ inputs.stage ]]
  image: registry.example.com/$[[ component.name ]]:$[[ component.version ]]
  script:
    - echo "Building with component version $[[ component.version ]]"
    - echo "Component reference: $[[ component.reference ]]"
```

### Component `spec` section

The `spec` section in a component template defines the component's configuration and inputs.
You can use the following keywords in the `spec` section:

* `spec:description`: Provide a short description of the component.
* `spec:inputs`: Define input parameters for users to customize component configuration.
* `spec:component`: Declare which component context fields to make available for interpolation.

You cannot use `spec:include` in components. Components should be self-contained.

## Write a component

### Manage dependencies

* Keep dependencies to a minimum.
* Rely on local dependencies whenever possible.
* When depending on components from other projects, pin their version to a release from the catalog rather than `~latest`.
* Update your dependencies regularly.
* Evaluate the permissions of dependencies.

### Write a clear `README.md`

* Start with a summary of the capabilities that the components provide.
* Add a `## Components` section with sub-sections for each component.
* In each component section: describe what the component does, add YAML examples, document inputs.
* Add a `## Contribute` section if contributions are welcome.

### Test the component

Test changes in a CI/CD pipeline by creating a `.gitlab-ci.yml` in the root directory:

```yaml
include:
  - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/my-component@$CI_COMMIT_SHA
    inputs:
      stage: build

stages: [build, test, release]

ensure-job-added:
  stage: test
  image: badouralix/curl-jq
  script:
    - |
      route="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/pipelines/${CI_PIPELINE_ID}/jobs"
      count=`curl --silent --header "JOB-TOKEN: ${CI_JOB_TOKEN}" "$route" | jq 'map(select(.name | contains("component job of my-component"))) | length'`
      if [ "$count" != "1" ]; then
        exit 1; else
        echo "Component Job present"
      fi

create-release:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  script: echo "Creating release $CI_COMMIT_TAG"
  rules:
    - if: $CI_COMMIT_TAG
  release:
    tag_name: $CI_COMMIT_TAG
    description: "Release $CI_COMMIT_TAG of components repository $CI_PROJECT_PATH"
```

### Avoid hard-coding instance or project-specific values

When using another component, use `$CI_SERVER_FQDN` instead of a hardcoded domain like `gitlab.com`.
When accessing the GitLab API, use `$CI_API_V4_URL` instead of a full URL.

### Avoid using global keywords

Avoid using global keywords like `default` in a component. They affect all jobs in a pipeline,
including jobs defined in the main `.gitlab-ci.yml` or other included components.

Instead, add the configuration directly to each job, or use the `extends` keyword with unique names.

### Replace hardcoded values with inputs

Avoid hardcoded values in CI/CD components. Use the `input` keyword for dynamic component configuration.

For example, to create a component with `stage` configuration that can be defined by users:

```yaml
spec:
  inputs:
    stage:
      default: test
---
unit-test:
  stage: $[[ inputs.stage ]]
  script: echo unit tests

integration-test:
  stage: $[[ inputs.stage ]]
  script: echo integration tests
```

#### Define job names with inputs

Avoid hard-coding job names in CI/CD components. Use `inputs` to allow customizable job names
or prefixes, preventing conflicts with existing pipeline job names.

```yaml
spec:
  inputs:
    job-prefix:
      description: "Define a prefix for the job name"
    job-stage:
      default: test
---

"$[[ inputs.job-prefix ]]-scan-website":
  stage: $[[ inputs.job-stage ]]
  script:
    - scan-website-1
```

### Replace custom CI/CD variables with inputs

When using CI/CD variables in a component, evaluate if `inputs` should be used instead.
Inputs are explicitly defined, have better validation, and return pipeline errors when missing.

In other cases, CI/CD variables might still be preferred:
* Use predefined variables to automatically configure a component to match a user's project.
* Ask users to store sensitive values as masked or protected CI/CD variables in project settings.

## CI/CD Catalog

The CI/CD Catalog is a list of projects with published CI/CD components you can use
to extend your CI/CD workflow. Anyone can create a component project and add it to the catalog.

### Publish a component project

To publish a component project in the CI/CD catalog, you must:

1. Set the project as a catalog project (via Settings > General > Visibility, project features, permissions > CI/CD Catalog project toggle).
2. Publish a new release.

#### Publish a new release

Prerequisites:
* You must use the `release` keyword in a CI/CD job to create the release (not the Releases API).
* The project must have a description, README.md, and at least one component in `templates/`.
* Tags must use semantic versioning.

Example release job:

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

#### Semantic versioning

When tagging and releasing new versions of components to the Catalog, you must use semantic versioning.
For example, `1.0.0`, `2.3.4`, and `1.0.0-alpha` are all valid semantic versions.

### Verified component creators

Some CI/CD components are badged to show they were created and maintained by verified users:

* **GitLab-maintained**: Created and maintained by GitLab.
* **GitLab Partner**: Independently created and maintained by a GitLab-verified partner.
* **Verified creator**: Created and maintained by a user verified by an administrator.

## CI/CD component security best practices

### For component users

* **Audit and review component source code** before using it.
* **Minimize access to credentials and tokens**: use minimally scoped, short-lived tokens.
* **Use pinned versions**: Pin to a specific commit SHA (preferred) or release tag. Avoid `~latest`.
* **Store secrets securely**: Never store secrets in CI/CD configuration files.
* **Use ephemeral, isolated runner environments**.
* **Securely handle cache and artifacts**: Do not pass cache/artifacts from other jobs unless necessary.
* **Limit CI_JOB_TOKEN access**: Restrict job token project access for projects using CI/CD components.
* **Review CI/CD component changes** before updating to a newer commit SHA or release tag.
* **Audit custom container images** used by the CI/CD component.

### For component maintainers

* **Use two-factor authentication (2FA)** for all maintainers and owners.
* **Use protected branches** for releases; set "Allowed to push and merge" to `No one`.
* **Block force pushes** to protected branches.
* **Sign all commits** to the component project.
* **Discourage using `latest`**: avoid `@latest` examples in README.
* **Update CI/CD component dependencies** regularly.
* **Use merge request approvals** for all user-facing changes.

## Troubleshooting

### `content not found` message

If you receive this error when using `~latest` or a partial semantic version:

```
This GitLab CI configuration is invalid: Component 'gitlab.com/my-namespace/my-project/my-component@~latest' - content not found
```

The `~latest` behavior now refers to the latest semantic version of the catalog resource.
Resolve by creating a new release.

### Error: `Build component error: Spec must be a valid json schema`

This can be caused by an empty `spec:inputs` section. If your configuration does not use any inputs,
make the `spec` section empty:

```yaml
spec:
---

my-component:
  script: echo
```
