---
title: "Live Update — Technical Reference"
tags: [tilt, live-update, reference]
sources: [tilt-live-update-reference]
updated: 2026-07-01
---

# Live Update — Technical Reference

Technical specification of `live_update`, the [[tilt-live-update|Live Update]] mechanism that cuts update time from minutes to seconds by patching a running container in place. For per-language recipes see [[tilt-example-go]], [[tilt-example-python]], [[tilt-example-nodejs]], [[tilt-example-java]], [[tilt-example-static-html]], [[tilt-example-csharp]], [[tilt-example-bazel]].

## Tiltfile API

`live_update` is an optional argument to `docker_build()` or `custom_build()` ([[docker]], [[tilt-custom-build]]). It takes an **ordered** list of `LiveUpdateStep`s:

1. 0 or more `fall_back_on` steps
2. 0 or more `sync` steps
3. 0 or more `run` steps

On `tilt up` the initial build is a full build. On a file change:

1. If it matches a `fall_back_on` file → **full rebuild + deploy**.
2. Else if it matches a `sync` local path → **Live Update**: copy synced files, then for each `run` step, execute it (only if changed files match its `triggers`, when given).

Steps are objects and can be assigned to variables and reused. Tiltfile validation errors if a created step is never used.

## Steps

### `sync(local_path, remote_path)`

The backbone of Live Update — Tilt only runs a Live Update when a change matches a `sync` step. Copies a file/dir to the remote path (including deletions).

- **Synced local paths must fall within the build's watched files** — the `docker_build` `context` (or `custom_build` `deps`). You can't sync files that aren't watched. Multiple dependent images: sync from anywhere in any image's context.
- A change inside the context but **not** matching a `sync` triggers a full Docker build; a change outside both does nothing.

### `fall_back_on(files)`

Optional; must come first. If a change that would trigger a Live Update matches these paths, Tilt falls back to a full rebuild + deploy instead (e.g. for dependency manifests).

### `run(cmd, trigger=None)`

Command executed **on the running container** (from `/` — use absolute paths). Must come after all `sync` steps; multiple `run`s execute in order. Without a `trigger`, runs on every Live Update; with a `trigger`, runs only when a changed file matches. **Trigger files must also be covered by a `sync` step** (a trigger doesn't itself cause watching/syncing).

```python
docker_build('my-img', '.', live_update=[
    sync('./src', '/app'),
    run('/app/setup.sh'),
    run('cd /app/web && yarn install', trigger='./src/web/yarn.lock'),
])
```

## Restarting your process

Apps that don't hot-reload need re-execution. For most setups use the **`restart_process` extension** ([[tilt-extensions]]): swap `docker_build` for `docker_build_with_restart` and set `entrypoint`. It does **not** work for:

- Docker Compose resources → use the `restart_container()` step instead ([[tilt-docker-compose]])
- `custom_build` images
- Images without a shell (`scratch`, `distroless`)
- CRDs

Workarounds: the `rerun-process-wrapper` scripts (`run('/path/to/restart.sh')`) or `entr` (`echo /restart.txt | entr -rz /path/to/bin`, restart via `run('date > /restart.txt')`). Both require a shell in the image. The container command can be changed via Dockerfile `ENTRYPOINT`/`CMD`, K8s `spec.containers[].command`, or the `entrypoint` build parameter.

Related: [[tilt-live-update]], [[tilt]], [[tiltfile]].
