---
title: "Tilt Tutorial 2: Launching & Managing Resources with tilt up"
tags: [tilt, tiltfile, kubernetes, control-loop]
sources: [tilt-tutorial-2-tilt-up]
updated: 2026-07-01
---

# Tilt Tutorial 2: Launching & Managing Resources

Tutorial page covering `tilt up`, the [[tiltfile]], resources, and the [[tilt-control-loop]]. Uses the
[Tilt Avatars](https://github.com/tilt-dev/tilt-avatars) sample project (Python API + JS SPA).

## CLI Commands

| Command     | Description                                                                                                                            |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `tilt demo` | One-shot demo: spins up a temporary local [[kubernetes]] cluster in [[docker]], clones Tilt Avatars, runs `tilt up`, cleans up on exit |
| `tilt up`   | Start the [[tilt-control-loop]] for the current directory's `Tiltfile`                                                                 |
| `tilt down` | Tear down resources deployed by `tilt up`                                                                                              |

Press `Spacebar` in the terminal after `tilt up` to open the Tilt UI in the browser (default: `http://localhost:3366/`).

## The Tiltfile

- Named exactly `Tiltfile` (no extension), placed in the project root.
- Written in [[starlark]] — a simplified, Python-like dialect; supports loops, functions, arrays.
- More extensible than static config formats (JSON/YAML) because it is a program.
- The `Tiltfile` is itself a [[tilt]] resource: edit it and Tilt re-evaluates without a restart.

### Key Built-in Functions

| Function         | Purpose                                                |
| ---------------- | ------------------------------------------------------ |
| `k8s_yaml()`     | Register [[kubernetes]] manifests with the Tilt engine |
| `docker_build()` | Register a [[docker]] image build                      |
| `k8s_resource()` | Override/extend auto-assembled resource configuration  |

When Tilt executes the `Tiltfile`:

1. Built-ins register metadata with the engine.
2. Tilt assembles _resources_ from the registered metadata.
3. Tilt watches relevant source files and triggers updates on changes.

## Resources

A **resource** = a bundle of related work items (e.g. a Docker image build + a Kubernetes manifest apply).

- Bundling is **automatic** in most cases — Tilt infers relationships.
- Use `k8s_resource()` in the `Tiltfile` to override when automatic detection isn't enough.
- Resources are not limited to containers: `local_resource()` manages locally-executed commands too.

### Update Status

Tilt determines which resources are stale and runs only the necessary steps:

- `make` — compile locally
- `docker build` — rebuild container image
- `kubectl apply -f` / `helm install` — deploy/reconcile

Tilt is **file-aware**: changing a Pod label won't trigger an image rebuild; editing JSX won't recompile the backend.
If services are already running and unchanged when `tilt up` starts, Tilt skips re-deploying them.

### Runtime Status

After deployment, Tilt monitors runtime health separately from build status. It surfaces _why_ something
failed (e.g. crash loop, bad config), saving manual `kubectl` investigation.

## The Control Loop

[[tilt-control-loop]] — Tilt's core architecture. Continuous watch → react cycle, more "hands-free" than
task-based tools (`make`) or one-shot service tools (`docker-compose up`).

| Change type                            | Tilt reaction                                         |
| -------------------------------------- | ----------------------------------------------------- |
| Source code file                       | Sync to running container (see [[tilt-live-update]])  |
| Dependency file (`package.json`, etc.) | Sync + run install command inside container           |
| Build spec (`Dockerfile`)              | Rebuild image + redeploy                              |
| Deployment spec (`app.yaml`)           | `kubectl apply` reconcile                             |
| `Tiltfile`                             | Re-evaluate; create/modify/delete resources as needed |

The loop means developers focus on code; Tilt handles deciding _which_ updates are needed.

## Gotchas & Notes

- `tilt demo` is for quick evaluation; `tilt up` is the standard command for real projects.
- `tilt demo` requires [[docker]] (for the temporary cluster) but no pre-existing [[kubernetes]] cluster.
- If you already have a local cluster, clone and run `tilt up` directly; clean up with `tilt down`.
- Even `Tiltfile` changes don't require restarting Tilt — the file is watched like any other resource.
- For even faster iteration (skip image rebuilds entirely), see [[tilt-live-update]] (tutorial step 5).

## Cross-references

- [[tilt]] — tool overview
- [[tiltfile]] — authoring guide
- [[tilt-control-loop]] — deep dive on the watch/react architecture
- [[tilt-live-update]] — skip rebuilds with in-place file sync
- [[tilt-extensions]] — reusable Tiltfile packages
- [[starlark]] — the language `Tiltfile` is written in
- [[kubernetes]] — primary deployment target
- [[docker]] — default image build engine
