---
source_url: https://appsec.guide/docs/fuzzing/oss-fuzz/
fetched: 2026-06-19
---

# OSS-Fuzz

[OSS-Fuzz](https://google.github.io/oss-fuzz/) is an open-source project developed by Google that aims to improve the security and stability of open-source software by providing free distributed infrastructure for continuous fuzz testing. Using a pre-existing framework like OSS-Fuzz has many advantages over manually running harnesses: it streamlines the process and facilitates simpler modifications. Although only select projects are accepted into OSS-Fuzz, because the project's core is open-source, anyone can host their own instance of OSS-Fuzz and use it for private projects.

This chapter will help project developers understand how to leverage OSS-Fuzz to both fuzz a project on your private instance and delegate the fuzzing computation to Google. Additionally, security researchers will learn how to run a single harness on an existing project, extend a harness, or reproduce an individual crash.

## OSS-Fuzz project components

OSS-Fuzz provides a simple CLI framework for building and starting harnesses or calculating their coverage, which streamlines the process of creating and testing them locally. Additionally, OSS-Fuzz can be used as a service that hosts static web pages generated from fuzzing outputs such as coverage information.

While not all components are open-sourced, here is a list of publicly available OSS-Fuzz tools:

* The [bug tracker](https://issues.oss-fuzz.com/issues?q=status:open) allows for:
  + Checking bugs from a specific project. (Bugs are initially visible only for maintainers, but are later made public.)
  + Creating a new issue and commenting.
  + Reading discussions under public issues.
  + Finding disclosed bugs in **all projects**, similar to a bug you see in your project. (You can search for any phrase in all OSS-Fuzz public issues.)
* The [build status system](https://oss-fuzz-build-logs.storage.googleapis.com/index.html) helps you track whether everything is functioning correctly:
  + The build statuses of all included projects.
  + The date of the last successful build.
* [Fuzz Introspector](https://oss-fuzz-introspector.storage.googleapis.com/index.html) displays the coverage of a project enrolled in OSS-Fuzz, including coverage data and hit frequency, allowing you to understand the performance of the fuzzer and identify any blockers.

## CLI: Running a single harness

You don't need to host the whole OSS-Fuzz platform to use it. OSS-Fuzz provides a helper script to easily access its features. You can run a single fuzzing harness, run a harness with input that previously caused a crash, test new harnesses, or run old ones under different configurations.

First, clone the main oss-fuzz repository and use the `infra/helper.py` script:

```
$ git clone https://github.com/google/oss-fuzz
$ cd oss-fuzz
$ python3 infra/helper.py --help
```

To run a harness, follow these steps:

* First, execute the helper script with the `build_image` argument: `build_image --pull <project-name>`
* Next, run `build_fuzzers` followed by your selected sanitizers and project name: `build_fuzzers --sanitizer=<sanitizers-list> <project-name>`. For AddressSanitizer with LeakSanitizer, use `--sanitizer=address`. Sanitizers' support for languages other than C or C++ may be limited; for example, Rust supports only AddressSanitizer with libfuzzer as an engine.
* Finally, to run the fuzzer, use `run_fuzzer <project-name> <harness-name> [<fuzzer-args>]`

The helper script should automatically run any missed steps if you skip one. The `build_fuzzers` command builds the fuzz targets into the `/build/out/<project-name>/` directory, which contains the llvm-symbolizer, harnesses, dictionaries, corpus, etc. Crash files will be saved there as well.

> **PRO TIP:** When working on a new harness, refrain from copying code from the source code or pulling it manually. Instead, look at the Dockerfile (or other harnesses) to understand how the code is copied to the Docker image.

## Coverage analysis

OSS-Fuzz can also generate a webpage code coverage report for your project.

* First, install gsutil. You can skip gcloud initialization.
* Then build harnesses with Coverage Sanitizer (`python3 infra/helper.py --sanitizer=coverage <project-name>`).
* Finally, run Coverage Analysis and host the page. You may request use of the local corpus (`--no-corpus-download`): `python3 infra/helper.py coverage <project-name>`

### Example (irssi)

Clone the OSS-Fuzz repository, then build and run the fuzzing harness:

```
git clone https://github.com/google/oss-fuzz
cd oss-fuzz
python3 infra/helper.py build_image --pull irssi
python3 infra/helper.py build_fuzzers --sanitizer=address irssi
python3 infra/helper.py run_fuzzer irssi irssi-fuzz
```

This produces libFuzzer output showing seed corpus loading, coverage (`cov:`), features (`ft:`), corpus growth (`corp:`), and mutation operations (e.g. `ShuffleBytes`, `EraseBytes`, `CrossOver`).

## Docker images in OSS-Fuzz

Harnesses are built and executed in Docker containers with the build directory mounted as a volume. All projects share a runner image. Each project is built in its own Docker image, which should be indirectly based on the base image.

Image hierarchy (each builds on the previous):

* `base_image`: a specific version of Ubuntu
* `base_clang`: compiles clang, used to compile most projects; based on `base_image`
* `base_builder`: some build dependencies, based on `base_clang`. For other languages, images like `base_builder_go` exist.
* Your project Docker image to **build** fuzzing targets (based on `base_builder/base_builder_*`): you must create this one.

Images used separately to run harnesses (common for all projects):

* `base_runner` (based on `base_clang`)
* `base_runner_debug` (with debug tools, based on `base_runner`)

## Using your project with OSS-Fuzz

If you're working on an open-source project, enrolling it in OSS-Fuzz fuzzes it continuously on Google's infrastructure for free. Acceptance is at the discretion of the OSS-Fuzz team. OSS-Fuzz gives each new project proposal a [criticality score](https://github.com/ossf/criticality_score) and uses this value to determine if a project should be accepted. You can still add projects to your own copy of OSS-Fuzz.

* Generally, you create three files: `project.yaml` (general information), `Dockerfile` (image with all build dependencies), and `build.sh` (building harnesses).
* Look at files of existing projects enrolled in oss-fuzz first.
* Keep source code for harnesses outside of the oss-fuzz project. Some projects create a separate repo for fuzzing, like cURL (curl-fuzzer).

## Project not eligible? Use CIFuzz / ClusterFuzzLite

When you already have harnesses, but your project is not eligible to be fuzzed continuously by Google infrastructure, it's important to fuzz the project regularly and for extended periods. One way is using CIFuzz (with ClusterFuzzLite if your project is not enrolled in OSS-Fuzz) to perform short fuzzing as a post-commit (or pre-commit) CI job. Because CIFuzz tests code from every commit, you can easily see which commit introduced the problem. If your project supports code-coverage calculations, CIFuzz can run only harnesses that touch modified code rather than all of them.

---

Source: Trail of Bits Testing Handbook. Licensed CC BY 4.0.
