---
title: "Tiltfile"
tags: [tilt, configuration, starlark, kubernetes, docker]
sources:
  [
    tilt-tiltfile-authoring,
    tilt-tiltfile-concepts,
    tilt-tiltfile-config,
    tilt-control-loop,
  ]
updated: 2026-07-01
---

# Tiltfile

A **Tiltfile** is the configuration file for [[tilt|Tilt]], written in **[[starlark|Starlark]]** (a simplified, deterministic dialect of Python). It is real code — conditionals, loops, and functions are allowed — but it does **not** execute anything against the cluster directly. Instead it registers **resources** with the [[tilt-control-loop|Tilt engine]], which performs the builds and deploys.

## Core functions

| Function                             | Purpose                                                                                   |
| ------------------------------------ | ----------------------------------------------------------------------------------------- |
| `k8s_yaml(...)`                      | Register [[kubernetes]] objects to deploy (files, `kustomize`, `helm`, or generated YAML) |
| `docker_build(ref, context)`         | Tell Tilt how to build a [[docker]] image; ID is injected into the deployed YAML          |
| `k8s_resource(name, ...)`            | Configure a resource — `port_forwards`, `new_name`, dependencies                          |
| `local_resource(...)`                | Run a local command/server/test ([[tilt-local-resource]])                                 |
| `custom_build(...)`                  | Use a non-Docker image builder ([[tilt-custom-build]])                                    |
| `load()` / `include()`               | Compose across files and repos ([[tilt-multiple-repos]])                                  |
| `config.define_*` / `config.parse()` | Per-user config flags and args ([[tilt-tiltfile-config]])                                 |

## Model

- Tilt executes the whole Tiltfile top-to-bottom to assemble **resource definitions**; some are declared explicitly, some assembled by heuristics (e.g. an image named `myservice` is grouped with YAML deploying `myservice`).
- Tilt watches the Tiltfile and its inputs; any change re-evaluates it.
- Example minimal Tiltfile:

```python
k8s_yaml('app.yaml')
docker_build('companyname/frontend', 'frontend')
k8s_resource('frontend', port_forwards=8080)
```

Related: [[tilt-live-update]], [[tilt-snippets]], [[tilt-templating-yaml]], [[tilt-helm]], [[starlark]].
