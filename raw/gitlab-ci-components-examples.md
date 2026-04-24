# CI/CD component examples

* Tier: Free, Premium, Ultimate
* Offering: GitLab.com, GitLab Self-Managed, GitLab Dedicated

## Test a component

Depending on a component's functionality, testing the component might require additional files in the repository.
For example, a component which lints, builds, and tests software in a specific programming language requires actual source code samples.

### Example: Test a Rust language CI/CD component

The following "hello world" example for the Rust programming language uses the `cargo` tool chain:

1. Go to the CI/CD component root directory.
2. Initialize a new Rust project:

   ```
   cargo init
   ```

   The command creates all required project files, including a `src/main.rs` "hello world" example.

   ```
   .
   ├── Cargo.toml
   ├── LICENSE.md
   ├── README.md
   ├── src
   │   └── main.rs
   └── templates
       └── build.yml
   ```

3. Ensure that the component has a job to build the Rust source code, in `templates/build.yml`:

   ```yaml
   spec:
     inputs:
       stage:
         default: build
         description: 'Defines the build stage'
       rust_version:
         default: latest
         description: 'Specify the Rust version'
   ---

   "build-$[[ inputs.rust_version ]]":
     stage: $[[ inputs.stage ]]
     image: rust:$[[ inputs.rust_version ]]
     script:
       - cargo build --verbose
   ```

4. Test the component's `build` template in `.gitlab-ci.yml`:

   ```yaml
   include:
     - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/build@$CI_COMMIT_SHA
       inputs:
         stage: build

   stages: [build, test, release]
   ```

5. Add a `test` component template in `templates/test.yml`:

   ```yaml
   spec:
     inputs:
       stage:
         default: test
         description: 'Defines the test stage'
       rust_version:
         default: latest
         description: 'Specify the Rust version'
   ---

   "test-$[[ inputs.rust_version ]]":
     stage: $[[ inputs.stage ]]
     image: rust:$[[ inputs.rust_version ]]
     script:
       - cargo test --verbose
   ```

6. Include both component templates in `.gitlab-ci.yml`:

   ```yaml
   include:
     - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/build@$CI_COMMIT_SHA
       inputs:
         stage: build
     - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/test@$CI_COMMIT_SHA
       inputs:
         stage: test

   stages: [build, test, release]
   ```

## CI/CD component patterns

### Use boolean inputs to conditionally configure jobs

Combine `boolean` type inputs and `extends` functionality to conditionally configure jobs:

```yaml
spec:
  inputs:
    enable_special_caching:
      description: 'If set to `true` configures a complex caching behavior'
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
  extends: '.my-component:enable_special_caching:$[[ inputs.enable_special_caching ]]'
  script: ... # run some fancy tooling
```

This pattern works by passing the `enable_special_caching` input into the `extends` keyword.
Depending on whether it is `true` or `false`, the appropriate hidden job configuration is selected.

### Use `options` to conditionally configure jobs

Use `extends` with `string` type and multiple `options` for any number of conditions:

```yaml
spec:
  inputs:
    cache_mode:
      description: Defines the caching mode to use for this component
      type: string
      options:
        - default
        - aggressive
        - relaxed
---

.my-component:cache_mode:default:
  extends: null

.my-component:cache_mode:aggressive:
  cache:
    policy: push
    key: $CI_COMMIT_SHA
    paths: ['*/**']

.my-component:cache_mode:relaxed:
  cache:
    policy: pull-push
    key: $CI_COMMIT_BRANCH
    paths: ['bin/*']

my-job:
  extends: '.my-component:cache_mode:$[[ inputs.cache_mode ]]'
  script: ... # run some fancy tooling
```

### Use component context to reference versioned resources

Use component context CI/CD expressions to reference component metadata like version and commit SHA.
One use case is to build and publish versioned resources (like Docker images) with your component
and ensure the component uses the matching version.

In the component project's release pipeline (`.gitlab-ci.yml`):

```yaml
build-image:
  stage: build
  image: docker:latest
  script:
    - docker build -t $CI_REGISTRY_IMAGE/my-tool:$CI_COMMIT_TAG .
    - docker push $CI_REGISTRY_IMAGE/my-tool:$CI_COMMIT_TAG

create-release:
  stage: release
  image: registry.gitlab.com/gitlab-org/cli:latest
  script: echo "Creating release $CI_COMMIT_TAG"
  rules:
    - if: $CI_COMMIT_TAG
  release:
    tag_name: $CI_COMMIT_TAG
    description: "Release $CI_COMMIT_TAG"
```

In the component template (`templates/my-component/template.yml`):

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
    - echo "Running tool version $[[ component.version ]]"
    - echo "Component was included using reference: $[[ component.reference ]]"
    - my-tool --version
```

In this example:
* If you include the component with `@1.0.0`, the job uses the image `my-tool:1.0.0`.
* If you include it with `@1.0`, it resolves to the latest `1.0.x` version (e.g. `1.0.3`) and uses `my-tool:1.0.3`.
* If you include it with `@~latest`, it uses the latest released version.
* `component.reference` shows the exact reference you specified (`1.0`, `~latest`, or a SHA).

## CI/CD component migration examples

### CI/CD component migration example: Go

A typical Go CI/CD template to migrate:

```yaml
default:
  image: golang:latest

stages:
  - test
  - build
  - deploy

format:
  stage: test
  script:
    - go fmt $(go list ./... | grep -v /vendor/)
    - go vet $(go list ./... | grep -v /vendor/)
    - go test -race $(go list ./... | grep -v /vendor/)

compile:
  stage: build
  script:
    - mkdir -p mybinaries
    - go build -o mybinaries ./...
  artifacts:
    paths:
      - mybinaries
```

Migration steps:

1. **Analyze jobs and dependencies**:
   * The `image` global configuration must be moved into job definitions.
   * The `format` job's `go test` should be moved into a separate job.
   * The `compile` job should be renamed to `build`.

2. **Define optimization strategies**:
   * `stage` should be configurable via input.
   * `image` should use `golang_version` input with `latest` as default.
   * Binary directory should be dynamic via input.

3. **Create the component structure**:

   ```
   git init
   mkdir templates
   touch templates/{format,build,test}.yml
   touch README.md LICENSE.md .gitlab-ci.yml .gitignore
   ```

4. **Create component templates**:

   `templates/build.yml`:
   ```yaml
   spec:
     inputs:
       stage:
         default: 'build'
         description: 'Defines the build stage'
       golang_version:
         default: 'latest'
         description: 'Go image version tag'
       binary_directory:
         default: 'mybinaries'
         description: 'Output directory for created binary artifacts'
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

   `templates/format.yml`:
   ```yaml
   spec:
     inputs:
       stage:
         default: 'format'
         description: 'Defines the format stage'
       golang_version:
         default: 'latest'
         description: 'Golang image version tag'
   ---

   "format-$[[ inputs.golang_version ]]":
     image: golang:$[[ inputs.golang_version ]]
     stage: $[[ inputs.stage ]]
     script:
       - go fmt $(go list ./... | grep -v /vendor/)
       - go vet $(go list ./... | grep -v /vendor/)
   ```

   `templates/test.yml`:
   ```yaml
   spec:
     inputs:
       stage:
         default: 'test'
         description: 'Defines the test stage'
       golang_version:
         default: 'latest'
         description: 'Golang image version tag'
   ---

   "test-$[[ inputs.golang_version ]]":
     image: golang:$[[ inputs.golang_version ]]
     stage: $[[ inputs.stage ]]
     script:
       - go test -race $(go list ./... | grep -v /vendor/)
   ```

5. **Test the component** in `.gitlab-ci.yml`:

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

6. **Add Go source code** to test the component:

   ```
   go mod init example.gitlab.com/components/golang
   ```

   Create `main.go`:

   ```go
   package main

   import "fmt"

   func main() {
     fmt.Println("Hello, CI/CD Component")
   }
   ```

Final directory tree:

```
.
├── LICENSE.md
├── README.md
├── go.mod
├── main.go
└── templates
    ├── build.yml
    ├── format.yml
    └── test.yml
```

Complete the migration by committing, pushing, verifying pipeline results, updating README.md, and releasing the component.
