---
title: "Tilt Example: Bazel"
tags: [tilt, example, bazel]
sources: [tilt-example-bazel]
updated: 2026-07-01
---

# Tilt Example: Bazel

Official example from the [[tilt]] docs showing how to integrate [[bazel]] with Tilt to shorten the iterative development feedback loop when deploying to [[kubernetes]].

Source repo: [tilt-dev/tilt-example-bazel](https://github.com/tilt-dev/tilt-example-bazel)

## Goal

The example demonstrates three things:

1. Run a Go template-based HTTP server on Kubernetes using Bazel for image builds.
2. Measure the baseline time from a code change to a running new process.
3. Optimise that time progressively across multiple Tiltfile stages.

The recommended, fully optimised [[tiltfile]] lives at [`3-recommended/Tiltfile`](https://github.com/tilt-dev/tilt-example-bazel/blob/main/3-recommended/Tiltfile).

## Approach

The example is structured as numbered stages (`1-`, `2-`, `3-recommended/`) so readers can follow the optimisation progression. Each stage's `Tiltfile` is self-contained and can be studied in isolation.

Tilt wraps Bazel builds using [[tilt-custom-build]] (the `custom_build()` function), which lets Tilt call an arbitrary shell command — including `bazel run` or `bazel build` — to produce a container image, then hands the result to Kubernetes. This avoids Docker daemon involvement and keeps the Bazel hermetic build model intact.

For deeper background on the integration pattern see [[tilt-integrating-bazel]].

## CI

The example repo uses [CircleCI](https://github.com/tilt-dev/tilt-example-bazel/blob/master/.circleci/config.yml) with [`ctlptl`](https://github.com/tilt-dev/ctlptl) to spin up a single-use Kubernetes cluster and validate the setup via `tilt ci`. `tilt ci` deploys all services defined in the [[tiltfile]] and exits 0 when they are healthy.

- CircleCI config: `.circleci/config.yml`
- Test script: `test/test.sh`

## Related examples

Other [[tilt]] language/build-tool examples follow the same numbered-stage pattern:

- [[tilt-example-go]]
- [[tilt-example-python]]
- [[tilt-example-nodejs]]
- [[tilt-example-static-html]]
- [[tilt-example-java]]
