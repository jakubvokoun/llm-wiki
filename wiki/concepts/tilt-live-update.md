---
title: "Live Update (Tilt)"
tags: [tilt, docker, development, inner-loop]
sources:
  [
    tilt-live-update-reference,
    tilt-tutorial-5-live-update,
    tilt-dependent-images,
  ]
updated: 2026-07-01
---

# Live Update (Tilt)

**Live Update** is [[tilt|Tilt]]'s optimization that updates a **running container in place** instead of rebuilding the image and redeploying the pod — collapsing the inner-loop feedback time from tens of seconds to ~1–2s in the per-language example guides.

## Steps

A `live_update` is attached to a `docker_build` (or `custom_build`) as an ordered list of steps:

| Step                  | Behavior                                                                            |
| --------------------- | ----------------------------------------------------------------------------------- |
| `fall_back_on(paths)` | If a listed file changes, abandon Live Update and do a full image build+deploy      |
| `sync(local, remote)` | Copy changed local files into the running container                                 |
| `run(cmd, trigger)`   | Execute a command inside the container (optionally only when certain files changed) |
| `restart_container()` | Restart the container process (legacy; discouraged for some runtimes)               |

Order matters: `fall_back_on` guards first, then `sync`, then `run`.

## When it applies

- Works best for interpreted/hot-reload stacks (sync source; let a watcher like `nodemon` reload) and for compiled stacks by syncing a freshly built binary and restarting.
- A change outside the sync scope, or to a `fall_back_on` path (e.g. dependency manifests), triggers a normal [[tilt-control-loop|build+deploy]].

See the language guides — [[tilt-example-go]], [[tilt-example-python]], [[tilt-example-nodejs]], [[tilt-example-java]], [[tilt-example-csharp]] — for concrete `live_update` recipes.
