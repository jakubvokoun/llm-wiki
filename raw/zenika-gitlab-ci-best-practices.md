# GitLab CI: 10+ Best Practices to Avoid Widespread Anti-Patterns

## Initial thoughts

GitLab CI is a powerful tool that has gained significant traction over the past 10 years due to its remarkable capabilities. However, despite its growing community and the abundance of online resources, developers often find themselves confused by the coexistence of patterns and anti-patterns in GitLab CI. This confusion hampers their efforts to enhance their GitLab CI skills.

This article aims to address this issue by gathering best practices to combat the anti-patterns commonly found in real-life projects and on the internet.

For performance-specific optimizations, see the companion article [GitLab CI Optimization: 15+ Tips for Faster Pipelines](https://dev.to/zenika/gitlab-ci-optimization-15-tips-for-faster-pipelines-55al).

## 1. Start CI with versioned public CI docker images

The foundation of a containerized job in GitLab CI relies on a Docker image and an instantiated container. Within this container, we execute commands to manipulate our valuable codebase.

Many package managers and commonly used CI tools already provide well-maintained public Docker images. By using these images, you benefit from their pre-configured settings and dependencies. It is crucial to regularly update the version of the image you use. Avoid using the `latest` tag, as it can lead to unexpected breaking changes. In such cases, you may find yourself spending hours troubleshooting your pipeline, wondering why it suddenly stopped working (*"Is this Tristan's fault? He was the latest developer to merge something into the repository!"*).

### Widespread usage: custom docker image upfront

When you cannot find the perfect image that meets all your requirements, the temptation may arise to create a custom one. It seems as simple as running `docker build && docker push`, right? However, before you release the Kraken, there are a few considerations to keep in mind.

First and foremost, you need to:

* Set up a Docker registry specifically for CI images.
* Configure your runners to authenticate with this Docker registry.
* Administer the registry to handle the potential growth of disk usage. Keep in mind that there will likely be more image versions than you initially anticipate.

This is still fine, especially for companies with tight security policies. An internal Docker registry mirrors public images. But if you rely on images with custom content, buckle up — the maintenance cycle is just getting started:

* The custom image will be perceived as a black box by developers.
  + Someone must take responsibility for its maintenance.
  + Upgrading tools within the image requires careful planning.
  + Changes required by one project might have unintended consequences for other jobs or projects.
* The cost of making changes is high. You must:
  + Locate the Dockerfile.
  + Make the necessary changes to the Dockerfile.
  + Push the modified image as a test tag.
  + Test the new image on projects that depend on it.
  + Iterate and repeat until the image is deemed satisfactory.
  + Finally, push the image as a final tag.

### Advice: minor installations at runtime

A more efficient approach is to split jobs based on their core goals, choose images that align with the main ecosystem, and install any missing tools at runtime. Here are a few examples:

```
node-and-git:
  image: node:18.10-alpine
  before_script:
    - apk --no-cache add git

kubectl-and-stern:
  image: alpine/k8s:1.22.13
  before_script:
    # install stern
    - curl --show-error --silent --location https://github.com/stern/stern/releases/download/v1.22.0/stern_1.22.0_linux_amd64.tar.gz | tar zx --directory /usr/bin/ stern && chmod 755 /usr/bin/stern

playwright-and-kubectl:
  image: mcr.microsoft.com/playwright:v1.35.1-focal
  before_script:
    # install kubectl
    - curl --show-error --silent --location --remote-name https://storage.googleapis.com/kubernetes-release/release/v1.25.3/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/
```

But you might wonder, does this approach slow down execution time? The answer is mostly no, at least not significantly, especially if you have reliable runners.

However, there is a potential issue with this pattern due to the [Docker Hub rate limits](https://www.docker.com/increase-rate-limits/). To mitigate this, configure your runner to use local images whenever possible by creating or configuring it with `--docker-pull-policy "if-not-present"`.

If you are using autoscaling runners, you may still encounter rate limit problems. In such cases, you can use a Docker registry proxy. GitLab can act as a pull-through service, reducing network latency when interacting with Docker Hub.

To enable this feature (credit to [this article](https://www.yotec.net/tips-on-how-to-speed-up-ci-cd-tasks-in-gitlab-pipelines/)):

* Enable the functionality at the group level (Settings > Packages & Registries > Dependency Proxy > Enable Proxy).
* Add the prefix `${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}` to the image name in your YAML file: `image: ${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}/alpine:latest`.

In certain advanced use cases, driven by company constraints, a custom image may still be necessary. However, it is important to approach this route wisely. Before resorting to a custom image, consider starting with the approach of installing missing tools at runtime.

## 2. Start a new product in a mono-repo

When starting a new product, you are faced with an important decision:

* Option 1: **Multi-Repos** - Create a separate repository for each module.
* Option 2: **Mono-Repo** - Keep all modules within a single repository.

The discussion around this topic can be as passionate as the debate between monoliths and microservices. In this article, we will only scratch the surface. Here's a summary of the two options:

**Multi-Repos Product on GitLab:**

* ✅ Requires basic knowledge of pipeline setup and package management.
* ❌ Multiple merge requests for a single functionality.
* ❌ Requires an advanced versioning strategy.
* ❌ Limited or no real continuous integration testing without advanced or costly tooling.
* ❌ Limited or no continuous delivery without advanced or costly tooling.
* ❌ No cache sharing between modules.

**Mono-Repos Product on GitLab:**

* ❌ Requires advanced knowledge of pipeline setup and package management.
* ✅ One merge request per functionality.
* ✅ No need for a versioning strategy.
* ✅ Enables real continuous integration testing without advanced tooling.
* ✅ Enables continuous delivery without advanced tooling.
* ✅ Allows for cache sharing between modules.

When starting a project, especially distributed monoliths, many underestimate the difficulty of managing common code (libraries) in a multi-repo setup. Testing changes and handling version numbers can quickly become overwhelming, whereas these tasks are much simpler in a mono-repository.

Choosing a product mono-repo can also help avoid other structural anti-patterns, such as next pattern and last pattern (triggered pipelines).

## 3. Start CI with local GitLab CI YAML files

In many companies, the software delivery process often includes centralized GitLab templates. This is particularly true in cases where the [DevOps Team Silo](https://web.devopstopologies.com/) anti-pattern exists.

Instead of constantly adding and enriching templates in a centralized location for every new requirement, it is recommended to start by building your CI YAML locally. You can even duplicate it when you encounter a second identical use case. Only after the third usage should you consider centralizing the YAML.

It's important to understand that centralization comes with various trade-offs in terms of efficiency. Before opting for centralization, consider the difficulties you already face with developing CI/CD pipelines, such as the slow feedback loop. Adding centralization introduces additional challenges, including:

* Committing and pushing changes to another repository while testing in the current one.
* Handling potential side effects on other projects that use the same YAML files.
* Managing template versions.

By starting with local YAML files, you simplify development and get a clear picture of your CI/CD needs. Once you understand those needs, you can decide whether centralization makes sense.

## 4. Start scripting with raw commands

Many developers are tempted to replace raw commands with a script in their CI/CD pipelines. For example replacing this:

```
script:
  - kustomize build devops/k8s/$MODULE/overlays/$OVERLAY | DOLLAR='$' envsubst | kubectl -n $NAMESPACE apply -f -
  - echo -e "\\e[93;1mWaiting for the new app version to be fully operational...\\e[0m"
  # waiting for successful deployment
  - kubectl -n $NAMESPACE rollout status deploy/$MODULE
```

With a script:

```
script:
  - make deploy
```

The main reason behind this change is to have consistent scripts for local testing and remote runners during testing and debugging. However, there are already tools available, such as [gitlab-ci-local](https://github.com/firecow/gitlab-ci-local), that allow you to run jobs locally, partially invalidating this argument. You can even [automate the testing of job rules](https://dev.to/zenika/gitlab-ci-automated-testing-of-job-rules-1i03) to detect unintended side effects of rules changes. Additionally, working locally may not provide access to all necessary variables.

However, by encapsulating commands within scripts, something more important than local testing is lost: understanding the execution process and precisely identifying the step at which an error occurred. When using a script, the CI/CD pipeline, which is already cryptic for most developers, becomes a black box unless the script is meticulously crafted to provide detailed information. Consequently, any CI problem will be passed on to the CI maintainer(s), even if the root cause lies in the code changes.

It is generally recommended to keep a minimal number of commands per job, which advocates for encapsulating scripts. However, by utilizing the appropriate Docker image, packaging tools for your programming languages (such as Maven, Npm, etc.), and the additional job logic in GitLab CI (such as variables, dotenv, rules, job templates, etc.), you can avoid lengthy job scripts. In most cases, if a job script exceeds a few lines, there is a good chance that a suitable (and free) command-line tool exists, which you should consider using.

As always, this is a recommended starting point rather than a strict rule. If there are cases where a script is more suitable, feel free to create and use it as needed.

## 5. Use workflow:rules and rules

By default, every job runs on every Git event, such as a pushed commit, a new branch, or a new tag. While this may be suitable for simple use cases, there will come a time when you want to avoid running unnecessary jobs in certain pipelines. To address this, you can use the [workflow:rules](https://docs.gitlab.com/ee/ci/yaml/#workflowrules) keyword to determine when a pipeline is triggered. For fine-grained control over the triggering of individual jobs, you can utilize the [rules](https://docs.gitlab.com/ee/ci/yaml/#rules) keyword.

You may still come across the deprecated [only / except](https://docs.gitlab.com/ee/ci/yaml/#only--except) keywords in pipelines. However, it is discouraged to use them as they are no longer maintained. The [rules](https://docs.gitlab.com/ee/ci/yaml/#rules) keyword covers all the features previously provided by [only / except](https://docs.gitlab.com/ee/ci/yaml/#only--except), so it is recommended to migrate to the new syntax.

One aspect that was available with [only / except](https://docs.gitlab.com/ee/ci/yaml/#only--except) and is missing from [rules](https://docs.gitlab.com/ee/ci/yaml/#rules) is the ability to compose jobs or templates through inheritance. While [rules](https://docs.gitlab.com/ee/ci/yaml/#rules) partially supports this through [!reference](https://docs.gitlab.com/ee/ci/jobs/job_control.html#reuse-rules-in-different-jobs), it doesn't cover all cases. Initially, this delayed our migration to [rules](https://docs.gitlab.com/ee/ci/yaml/#rules). However, we soon realized that [rules](https://docs.gitlab.com/ee/ci/yaml/#rules) offer superior functionality and reduce cognitive load for readers.

Overall, using [workflow:rules](https://docs.gitlab.com/ee/ci/yaml/#workflowrules) and [rules](https://docs.gitlab.com/ee/ci/yaml/#rules) is the more reliable and flexible way to control job execution in GitLab CI/CD pipelines.

## 6. Abstract duplicated code (without YAML anchors)

Abstraction is a fundamental concept in any programming language that allows us to avoid duplicating code. GitLab CI provides a form of abstraction through job templates, also known as "hidden jobs" in the GitLab documentation. By using the `extends` keyword, and sometimes the `!reference` keyword for composition, we can achieve the necessary flexibility. Job templates do not necessarily have to be valid jobs, which further enhances their versatility.

Even the GitLab official blog is not always free of anti-patterns, providing us with an opportunity to abstract the following duplicate code from the article ["Managing multiple environments with Terraform and GitLab CI"](https://about.gitlab.com/blog/2023/06/14/managing-multiple-environments-with-terraform-and-gitlab-ci/) as an example:

```
fmt-dev:
  extends: .fmt
  rules:
    - changes:
        - dev/**/*

validate-dev:
  extends: .validate
  rules:
    - changes:
        - dev/**/*

build-dev:
  extends: .build
  rules:
    - changes:
        - dev/**/*

deploy-dev:
  extends: .deploy
  rules:
    - changes:
        - dev/**/*
```

Unfortunately, what would horrify people in traditional development languages is often tolerated in CI/CD code. However, here is a refactored version that is more readable:

```
.dev:
  rules:
    - changes:
        - dev/**/*

fmt-dev:
  extends:
    - .fmt
    - .dev

validate-dev:
  extends:
    - .validate
    - .dev

build-dev:
  extends:
    - .build
    - .dev

deploy-dev:
  extends:
    - .deploy
    - .dev
```

While GitLab supports YAML anchors as a way to share blocks, it is a technical and hard-to-follow approach that is limited to the current YAML file. It is generally recommended not to use YAML anchors, as there is almost always a better alternative.

Here is a sub-optimal example usage from the [official documentation itself](https://docs.gitlab.com/ee/ci/yaml/yaml_optimization.html#yaml-anchors-for-variables):

```
.default_scripts: &default_scripts
  - ./default-script1.sh
  - ./default-script2.sh

.job_template:
  &job_configuration # Hidden yaml configuration that defines an anchor named 'job_configuration'
  image: ruby:2.6
  services:
    - postgres
    - redis

job1:
  <<: *job_configuration # Add the contents of the 'job_configuration' alias
  script:
    - *default_scripts
    - ./job-script.sh
```

Which can easily be replaced with:

```
.default_scripts:
  script:
    - ./default-script1.sh
    - ./default-script2.sh

.job_template:
  image: ruby:2.6
  services:
    - postgres
    - redis

job1:
  extends: .job_template
  script:
    - !reference [.default_scripts, script]
    - ./job-script.sh
```

To summarize, you can always avoid code duplication in GitLab CI. However, in some cases, a little duplication is better than over-engineered abstraction. Remember, developers spend most of their time reading code, and GitLab CI YAML can be challenging to comprehend.

## 7. Use artifacts and cache as intended

The features of artifacts and cache in GitLab CI are often misused, as there is nothing preventing you from using one for the purpose of the other.

Artifacts are small files that are guaranteed to be transmitted to further jobs in the same pipeline. On the other hand, cache is non-guaranteed and optimized for handling thousands of files downloaded from the internet. In the Maven world, **jars** are considered artifacts, while the Maven local repository (**.m2/repository**) serves as the cache. Similarly, in the NPM world, **dist** folder is an artifact, and **node_modules** are candidates for cache.

To summarize the differences between artifacts and cache:

|  | artifacts | cache |
| --- | --- | --- |
| use case | transmit data | speed up pipeline |
| multi-jobs or multi-pipelines ? | multi-jobs | both |
| guaranteed | ✅ | ❌ |
| stored on GitLab server | ✅ | ❌ |
| downloadable through GUI and historicized | ✅ | ❌ |
| configurable lifetime | ✅ | ❌ |
| deletion in GUI | individual | global |
| large size allowed | ❌ | ✅ |
| multiple per producer job | ❌ | ✅ |

We advise you to use artifacts and cache as intended to avoid duplicate tasks and unnecessary downloads in your jobs. By utilizing them correctly in their respective areas of use, you can optimize your pipeline and improve overall efficiency.

To go further, you may read [GitLab CI Optimization: 15+ Tips for Faster Pipelines](https://dev.to/zenika/gitlab-ci-optimization-15-tips-for-faster-pipelines-55al).

## 8. Split jobs wisely

When designing your pipeline, you have the choice to include all tasks in a single job or split them into multiple jobs based on your requirements.

Having all tasks in one job can potentially make your pipeline faster, as shown in this [article](https://medium.com/nerd-for-tech/speed-up-gitlab-ci-by-using-fewer-steps-in-the-pipeline). On the other hand, splitting tasks into separate jobs can make the flow easier to understand.

Before grouping tasks into a single job, consider the following:

* Progress tracking becomes more challenging.
* You may need a custom Docker image that includes everything, which can be cumbersome (refer to the corresponding section in this article).
* There is a risk of hitting the runner's log limit.
* GitLab does not parallelize tasks by default, so you would need to rely on external tools for parallelization (especially for testing and deployment), otherwise, you may slow down your pipelines.
* Developers are less likely to understand the cause of failure in a bulky job, leading to more requests for assistance from maintainers.
* In case of failure in a flaky task, the entire job needs to be restarted, which occurs more frequently in larger jobs.
* Bulky jobs can hinder runner resource optimization, resulting in slower pipelines overall.

Similarly, when considering over-splitting jobs, keep the following in mind:

* You need to carefully manage your artifacts and cache.
* Caching itself takes time.
* It can be challenging to avoid duplicating steps, especially with package managers like Maven that tend to repeat previous steps.
* The more stages you have, the higher the likelihood of slower pipelines.

An anti-pattern worth mentioning is the multi-stage Docker build. While it may seem tempting to achieve isolated artifact creation for perfect reproduction, this concern about non-reproducibility is already addressed when using Docker runners. You can achieve the same results by packaging and testing in a traditional job and then passing artifacts to the image build. This approach provides valuable running information and speed, compared to duplicating packaging steps in separate jobs.

Consider these factors when deciding how to split your jobs in order to optimize your pipeline for efficiency and maintainability.

## 9. Use needs keyword wisely

### Use needs chains but stop it when appropriate

By default, a stage in GitLab CI does not start until the previous stage has successfully finished. However, the "needs" keyword allows you to bypass this constraint for specific jobs. These jobs will start as soon as the "needed" jobs have successfully completed.

This feature is particularly useful when multiple chains of jobs can run in parallel without much interaction, which naturally occurs in mono-repos. However, it's important to note that jobs in a "needs" chain become autonomous. They are no longer stopped if other jobs fail. To prevent instability in your application, it's crucial to stop the "needs" chains before resource-consuming jobs (such as container image build/push) and/or critical steps (such as deployments). Otherwise, having full chains of "needs" all the way to deployment can result in an unstable application, with some modules being in a new version while others have not yet been deployed.

Another workaround for this issue is to add synchronization jobs that wait for multiple "needs" chains to complete before proceeding.

### Avoid the stageless pipeline

The "needs" keyword can also be applied to jobs within the same stage, allowing you to create stageless pipelines similar to those in Jenkins. However, it's important to note that in reality, jobs fall into the default stage, which is **Test**. This limitation is currently being addressed in GitLab, as mentioned in this [issue](https://gitlab.com/gitlab-org/gitlab/-/issues/359936).

Due to this limitation and the lack of advantages over the partial use of "needs", we do not recommend the use of stageless pipelines. If you still have a valid reason for using stageless pipelines, please share your insights in the comments!

## 10. Avoid downstream pipelines

### a. Avoid child pipelines

GitLab provides the concept of child pipelines, which allows you to trigger downstream pipelines within the same project. Child pipelines run separately from the main pipeline in terms of variable context and stages. You can even create dynamic child pipelines, generating the pipeline on the fly in an early parent job and triggering it in a later job.

While child pipelines show promise, there are several aspects that make them a less-than-ideal solution currently:

* The user interface for child pipelines is clunky. Child pipelines are not fully visible in the pipelines list and require inconvenient scrolling to access the details on the far right of the parent pipeline.
* The parent pipeline cannot utilize reports from child pipelines, as mentioned in this [issue](https://gitlab.com/gitlab-org/gitlab/-/issues/280818).
* The parent pipeline cannot stop a child pipeline if another one has failed.
* Creating dynamic child pipelines is technically complex, as GitLab does not offer built-in templating. Third-party tools are required to achieve this functionality.
* Synchronizing parent/child artifacts is unnecessarily complex.

### b. Avoid multi-project pipelines

GitLab provides the capability to trigger pipelines in other projects using multi-project pipelines. However, it is important to consider the limitations associated with this feature. The parent pipeline has limited control over the triggered pipelines, including the inability to access artifacts. This significantly restricts the possibilities when using multi-project pipelines.

In general, the need for this type of pipeline arises either from issues with the repository architecture, the git workflow, or both. As previously recommended, when working with a mono-repo product, you can easily avoid using downstream pipelines altogether.

Crafting a single pipeline handling CI and CD might seem complex at first. But when best practice are applied, this is in fact simpler overall, and obviously faster. A next article will present a full pipeline as example.

## Wrapping up

By following these best practices, you can avoid the most common GitLab CI anti-patterns. If you have any additional best practices that you think should be added to this list, or if you find any of these choices controversial for valid reasons, please share your thoughts in the comments below.
