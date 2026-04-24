---
title: "GitLab CI/CD Component Examples"
tags: [gitlab, ci-cd, components, examples, migration]
sources: [gitlab-ci-components-examples.md]
updated: 2026-04-23
---

# GitLab CI/CD Component Examples

Practical examples for testing, implementing patterns, and migrating CI/CD templates
to reusable components.

## Testing components with source code samples

Some components need actual source code to test against (e.g., a Rust build component needs Rust source).
Include sample files directly in the component project.

### Rust component example

1. `cargo init` in the component root to generate `src/main.rs` and `Cargo.toml`.
2. Define `templates/build.yml` and `templates/test.yml` with appropriate `spec:inputs`.
3. Include both via `$CI_SERVER_FQDN/$CI_PROJECT_PATH/<template>@$CI_COMMIT_SHA` in `.gitlab-ci.yml`.

```yaml
# templates/build.yml
spec:
  inputs:
    stage:
      default: build
    rust_version:
      default: latest
---
"build-$[[ inputs.rust_version ]]":
  stage: $[[ inputs.stage ]]
  image: rust:$[[ inputs.rust_version ]]
  script:
    - cargo build --verbose
```

## Conditional configuration patterns

### Boolean input pattern

Use `boolean` inputs + `extends` to conditionally apply configuration blocks:

```yaml
spec:
  inputs:
    enable_special_caching:
      type: boolean
---
.my-component:enable_special_caching:false:
  extends: null

.my-component:enable_special_caching:true:
  cache:
    policy: pull-push
    key: $CI_COMMIT_SHA
    paths: [...]

my-job:
  extends: ".my-component:enable_special_caching:$[[ inputs.enable_special_caching ]]"
  script: run-tool
```

Works because `extends` interpolates the boolean value to select the correct hidden job.

### Multiple options pattern

Extend the pattern to 3+ conditions using `options`:

```yaml
spec:
  inputs:
    cache_mode:
      type: string
      options: [default, aggressive, relaxed]
---
.my-component:cache_mode:default:
  extends: null

.my-component:cache_mode:aggressive:
  cache:
    policy: push
    key: $CI_COMMIT_SHA
    paths: ["*/**"]

.my-component:cache_mode:relaxed:
  cache:
    policy: pull-push
    key: $CI_COMMIT_BRANCH
    paths: ["bin/*"]

my-job:
  extends: ".my-component:cache_mode:$[[ inputs.cache_mode ]]"
  script: run-tool
```

## Component context for versioned resources

Build Docker images versioned with the component, then reference via `component.version`:

**Release pipeline** (`.gitlab-ci.yml`):

```yaml
build-image:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE/my-tool:$CI_COMMIT_TAG .
    - docker push $CI_REGISTRY_IMAGE/my-tool:$CI_COMMIT_TAG
```

**Component template** (`templates/my-component/template.yml`):

```yaml
spec:
  component: [version, reference]
  inputs:
    stage:
      default: test
---
run-tool:
  stage: $[[ inputs.stage ]]
  image: $CI_REGISTRY_IMAGE/my-tool:$[[ component.version ]]
  script:
    - echo "Running $[[ component.version ]] (ref: $[[ component.reference ]])"
```

This ensures:

- `@1.0.0` → uses `my-tool:1.0.0`
- `@1.0` → resolves to latest `1.0.x`, uses that exact image (e.g. `my-tool:1.0.3`)
- `@~latest` → uses latest released version

## Go CI/CD template migration

Shows migrating a monolithic Go template to discrete components.

**Original template** issues:

- `default: image: golang:latest` affects all jobs globally
- `format` job does too much (fmt + vet + test in one job)
- Hardcoded stage names and binary directory

**Migrated component structure**:

```
.
├── LICENSE.md
├── README.md
├── go.mod
├── main.go          ← sample source for testing
└── templates/
    ├── build.yml
    ├── format.yml
    └── test.yml
```

**`templates/build.yml`**:

```yaml
spec:
  inputs:
    stage:
      default: "build"
    golang_version:
      default: "latest"
    binary_directory:
      default: "mybinaries"
---
"build-$[[ inputs.golang_version ]]":
  image: golang:$[[ inputs.golang_version ]]
  stage: $[[ inputs.stage ]]
  script:
    - mkdir -p $[[ inputs.binary_directory ]]
    - go build -o $[[ inputs.binary_directory ]] ./...
  artifacts:
    paths:
      - $[[ inputs.binary_directory ]]
```

**Test pipeline** (`.gitlab-ci.yml`):

```yaml
stages: [format, build, test]

include:
  - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/format@$CI_COMMIT_SHA
  - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/build@$CI_COMMIT_SHA
  - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/build@$CI_COMMIT_SHA
    inputs:
      golang_version: "1.21"
  - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/test@$CI_COMMIT_SHA
    inputs:
      golang_version: latest
```

Key migration decisions:

- `image` moved from `default` global into each job using `inputs.golang_version`
- `go test` split into separate `test` component for parallelism
- Job names are dynamic (`build-latest`, `build-1.21`) to avoid name conflicts when including twice

## Related

- [GitLab CI/CD Components source](gitlab-ci-components.md)
- [GitLab CI/CD Components concept](../concepts/gitlab-ci-components.md)
