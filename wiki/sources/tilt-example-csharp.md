---
title: "Tilt Example: C# / ASP.NET Core"
tags: [tilt, example, csharp, live-update]
sources: [tilt-example-csharp]
updated: 2026-07-01
---

# Tilt Example: C# / ASP.NET Core

A staged walkthrough of optimising the inner-dev loop for a "hello world"
ASP.NET Core (Razor Pages) web server running on [[kubernetes]]. The repo is
[tilt-example-csharp](https://github.com/tilt-dev/tilt-example-csharp).
See also [[tilt-example-go]], [[tilt-example-python]], [[tilt-example-nodejs]],
[[tilt-example-java]] for the same pattern in other languages.

## Step 0 — Baseline ("naive")

Three config files are enough to get started:

| File              | Role                                                                           |
| ----------------- | ------------------------------------------------------------------------------ |
| `Dockerfile`      | Multi-stage build: `dotnet restore` → `dotnet publish` → ASP.NET runtime image |
| `kubernetes.yaml` | Deployment manifest                                                            |
| `Tiltfile`        | Ties everything together                                                       |

Minimal [[tiltfile]]:

```python
docker_build('hello-tilt', './hello-tilt')
k8s_yaml('kubernetes.yaml')
k8s_resource('hello-tilt', port_forwards='8080:80')
```

`docker_build` image name must match the container `image:` in the Deployment;
`k8s_resource` name must match `metadata.name`. Port-forward exposes the
server at `localhost:8080`.

**Baseline deploy time: 10.4 s**

## Step 1 — Measure with `local_resource`

A `local_resource` runs a shell command on the developer's machine and appears
as a managed resource in the [[tilt]] UI sidebar.

```python
local_resource(
    'deploy',
    './record-start-time.sh',
    deps=['./record-start-time.sh']
)
```

`record-start-time.sh` writes a timestamp into a C# source file; the running
server reads it on each request and displays elapsed time — giving an
end-to-end latency benchmark independent of Tilt's own sidebar metrics.

## Step 2 — Local Compilation (8.2 s)

The naive [[docker]] build runs `dotnet restore` + `dotnet publish` inside the
image every time. Moving compilation to a `local_resource` lets the host's
incremental compiler cache dependencies:

```python
local_resource(
    'build',
    'dotnet publish -c Release -o out',
    deps=['hello-tilt'],
    ignore=['hello-tilt/obj'],
    resource_deps=['deploy'],
)
```

The [[dockerfile]] is slimmed down to copy only the pre-built output:

```dockerfile
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
COPY . /app/out
WORKDIR /app/out
ENTRYPOINT ["dotnet", "hello-tilt.dll"]
```

`docker_build` is updated to pass only the `out/` directory as context:

```python
docker_build('hello-tilt', 'out', dockerfile='Dockerfile')
```

**Deploy time after local compile: 8.2 s**

## Step 3 — `live_update` (4.8 s)

[[tilt-live-update]] skips image rebuild, push, and pod reschedule entirely.
The `restart_process` extension handles process restart after file sync.

```python
load('ext://restart_process', 'docker_build_with_restart')

docker_build_with_restart(
    'hello-tilt',
    'out',
    entrypoint=['dotnet', 'hello-tilt.dll'],
    dockerfile='Dockerfile',
    live_update=[
        sync('out', '/app/out'),
    ],
)
```

- `sync('out', '/app/out')` copies the compiled output into the running container.
- `docker_build_with_restart` is a drop-in for `docker_build` that knows to
  re-execute `entrypoint` after a live-update sync.
- The `restart_process` extension is framework-agnostic; frameworks with native
  hot-reload can replace it with a `run` step instead.

**Deploy time with live_update: 4.8 s** — a 2.2× improvement over baseline.

## Performance Summary

| Approach                                 | Deploy Time |
| ---------------------------------------- | ----------- |
| Naive (full Docker build in-image)       | 10.4 s      |
| Local compile (`dotnet publish` on host) | 8.2 s       |
| Local compile + `live_update`            | **4.8 s**   |

## CI

The example repo uses [ctlptl](https://github.com/tilt-dev/ctlptl) to spin up
a single-use [[kubernetes]] cluster in CircleCI, then runs `tilt ci` — which
deploys all resources defined in the [[tiltfile]] and exits 0 if they reach
healthy status.

## Key Takeaways

- Move slow build steps (`dotnet restore`, `dotnet publish`) out of [[docker]]
  and onto the host; pass only pre-built artefacts as build context.
- Use `local_resource` with `resource_deps` to express ordering between the
  compile step and the image build.
- `live_update` with `sync` + `restart_process` gives sub-5 s feedback for
  compiled languages without hot-reload support.
- The same three-stage pattern (baseline → local build → live_update) applies
  across all [[tilt-example-*]] language examples.
