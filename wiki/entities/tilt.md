---
title: "Tilt"
tags: [tool, kubernetes, development, microservices, docker]
sources:
  [
    tilt-product-faq,
    tilt-control-loop,
    tilt-tiltfile-concepts,
    tilt-live-update-reference,
  ]
updated: 2026-07-01
---

# Tilt

**Tilt** is an open-source developer tool for **local development of microservice apps on Kubernetes** (and Docker Compose). Its tagline: _"Kubernetes for Prod, Tilt for Dev."_ Running `tilt up` starts a [[tilt-control-loop|control loop]] that watches source files, builds container images, and keeps the cluster up-to-date — automating the manual `docker build && kubectl apply` cycle. It is maintained by **[[docker|Docker, Inc.]]** and hosted at [github.com/tilt-dev/tilt](https://github.com/tilt-dev/tilt).

## What it does

- Watches files → builds [[docker|container]] images → deploys to [[kubernetes]], continuously.
- Configured by a **[[tiltfile|Tiltfile]]**, written in **[[starlark|Starlark]]** (a Python dialect).
- **[[tilt-live-update|Live Update]]** patches running containers in-place to avoid full image rebuilds.
- Presents a **web UI** (and `tilt` CLI) showing per-resource status, logs, and endpoints.
- Extensible via **[[tilt-extensions|Tilt extensions]]** — shareable Tiltfile functions.

## Positioning

- **vs. Skaffold** — Tilt uses imperative Starlark config and a richer UI; migration guides exist ([[tilt-skaffold]]).
- **vs. plain `docker-compose up` / `kubectl apply`** — adds file-watching, smart rebuilds, dependency ordering, and observability.
- Works with any local cluster (Kind, k3d, Minikube, Docker Desktop, Rancher Desktop) or remote dev clusters — see [[tilt-choosing-clusters]] and [[tilt-local-vs-remote]].

## Core building blocks

| Concept               | Role                                           |
| --------------------- | ---------------------------------------------- |
| [[tiltfile]]          | Starlark config declaring what to build/deploy |
| [[tilt-control-loop]] | Watch → build → deploy → repeat engine         |
| [[tilt-live-update]]  | In-place container updates (sync/run/fallback) |
| [[tilt-extensions]]   | Reusable, shareable Tiltfile functionality     |

Runs on macOS, Linux, and Windows. Sends anonymized [[tilt-telemetry-faq|telemetry]] (opt-out).

## Documentation map

All Tilt source pages ingested from docs.tilt.dev (2026-07-01):

- [Choosing a Local Dev Cluster for Tilt](../sources/tilt-choosing-clusters.md)
- [Tilt in Continuous Integration](../sources/tilt-ci.md)
- [Contributing a Tilt Extension](../sources/tilt-contribute-extension.md)
- [Tilt's Control Loop](../sources/tilt-control-loop.md)
- [Tilt: Custom Image Builders (custom_build)](../sources/tilt-custom-build.md)
- [Custom Buttons (uibutton)](../sources/tilt-custom-buttons.md)
- [Managing Kubernetes Custom Resources in Tilt](../sources/tilt-custom-resource.md)
- [Tilt Debugging FAQ](../sources/tilt-debug-faq.md)
- [Connecting Debuggers (Python)](../sources/tilt-debuggers-python.md)
- [Tilt: Building Dependent and Multi-Stage Image Hierarchies](../sources/tilt-dependent-images.md)
- [Tilt: Disabling Resources at Runtime](../sources/tilt-disable-resources.md)
- [Tilt with Docker Compose](../sources/tilt-docker-compose.md)
- [Tilt Editor Support](../sources/tilt-editor-support.md)
- [Tilt Example: Bazel](../sources/tilt-example-bazel.md)
- [Tilt Example: C# / ASP.NET Core](../sources/tilt-example-csharp.md)
- [Tilt Example: Go — Staged Optimization for Fast Feedback](../sources/tilt-example-go.md)
- [Tilt Example: Java/Spring Boot Live Update](../sources/tilt-example-java.md)
- [Tilt Example: Node.js (Express + live_update)](../sources/tilt-example-nodejs.md)
- [Tilt Example: Python + Flask](../sources/tilt-example-python.md)
- [Tilt Example: Plain Old Static HTML](../sources/tilt-example-static-html.md)
- [Tilt Extensions — Using and Loading](../sources/tilt-extensions.md)
- [Tilt FAQ: Help, Errors & Cluster Setup](../sources/tilt-faq.md)
- [Tilt File Watching and Ignores](../sources/tilt-file-changes.md)
- [Using Helm with Tilt](../sources/tilt-helm.md)
- [Tilt Installation Guide](../sources/tilt-install.md)
- [Integrating Bazel with Tilt](../sources/tilt-integrating-bazel.md)
- [Live Update — Technical Reference](../sources/tilt-live-update-reference.md)
- [Local Resources — Commands, Servers, and Tests](../sources/tilt-local-resource.md)
- [Tilt: Local vs Remote Service Architectures](../sources/tilt-local-vs-remote.md)
- [Tilt Manual Update Control](../sources/tilt-manual-update-control.md)
- [Tilt: Many Tiltfiles and Many Repos](../sources/tilt-multiple-repos.md)
- [Team Onboarding Checklist](../sources/tilt-onboarding-checklist.md)
- [Setting Up Image Registries in Tilt](../sources/tilt-personal-registry.md)
- [Tilt: Accessing Service Endpoints](../sources/tilt-port-forwards.md)
- [Tilt Product FAQ](../sources/tilt-product-faq.md)
- [Tilt Resource Dependencies and Startup Order](../sources/tilt-resource-dependencies.md)
- [From Skaffold to Tilt: Comparison and Migration](../sources/tilt-skaffold.md)
- [Sharing Snapshots](../sources/tilt-snapshots.md)
- [Tiltfile Snippets Reference](../sources/tilt-snippets.md)
- [Tilt Telemetry FAQ](../sources/tilt-telemetry-faq.md)
- [Modifying YAML for Dev with Tilt](../sources/tilt-templating-yaml.md)
- [Writing Your First Tiltfile](../sources/tilt-tiltfile-authoring.md)
- [Tiltfile Concepts](../sources/tilt-tiltfile-concepts.md)
- [Tiltfile Per-User Configuration](../sources/tilt-tiltfile-config.md)
- [Tilt Tutorial Part 1: Prerequisites & Installation](../sources/tilt-tutorial-1-prerequisites.md)
- [Tilt Tutorial 2: Launching & Managing Resources with tilt up](../sources/tilt-tutorial-2-tilt-up.md)
- [Tilt UI — Tutorial Part 3](../sources/tilt-tutorial-3-tilt-ui.md)
- [Tilt Tutorial 4: Code, Update, Repeat](../sources/tilt-tutorial-4-code-update-repeat.md)
- [Tilt Tutorial 5: Smart Rebuilds with Live Update](../sources/tilt-tutorial-5-live-update.md)
- [Tilt Tutorial: First Look Overview](../sources/tilt-tutorial-overview.md)
- [Tilt: Upgrade Guide](../sources/tilt-upgrade.md)

**Concept pages:**

- [Tiltfile](../concepts/tiltfile.md)
- [Control Loop](../concepts/tilt-control-loop.md)
- [Live Update](../concepts/tilt-live-update.md)
- [Extensions](../concepts/tilt-extensions.md)
