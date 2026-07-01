---
title: "Tilt Example: Go — Staged Optimization for Fast Feedback"
tags: [tilt, example, golang, live-update]
sources: [tilt-example-go]
updated: 2026-07-01
---

# Tilt Example: Go

Canonical Tilt walkthrough showing how to shrink the code-change-to-running-process loop for a Go HTTP server deployed on [[kubernetes]]. Progresses through three optimization stages, each measurably faster than the last.

Source repo: [tilt-dev/tilt-example-go](https://github.com/tilt-dev/tilt-example-go)

## The Application

A simple Go HTTP server using `gorilla/mux` for routing:

```go
func main() {
    http.Handle("/", NewExampleRouter())
    log.Println("Serving on port 8000")
    err := http.ListenAndServe(":8000", nil)
    if err != nil {
        log.Fatalf("Server exited with: %v", err)
    }
}
```

Uses Go HTML templates served from a `./web` directory. The binary entry point is `main.go` and `start.go`.

## Stage 0 — Naive Tiltfile (baseline)

Three files required to get the server running on Kubernetes:

1. `deployments/Dockerfile` — builds the image
2. `deployments/kubernetes.yaml` — Kubernetes Deployment manifest
3. `Tiltfile` — ties them together

```python
docker_build('example-go-image', '.',
    dockerfile='deployments/Dockerfile')
k8s_yaml('deployments/kubernetes.yaml')
k8s_resource('example-go', port_forwards=8000)
```

- `docker_build` image name must match the container `image` reference in the Deployment YAML.
- `k8s_resource` name must match `metadata.name` in `kubernetes.yaml`.
- Port-forwarding makes the server reachable at `localhost:8000`.

See also: [[tiltfile]], [[docker]].

## Stage 1 — Measuring with `local_resource`

Before optimizing, instrument the loop. A `local_resource` records the deploy start time into a Go source file; the running server reads it and logs elapsed time.

```python
k8s_resource(
    'example-go',
    port_forwards=8000,
    resource_deps=['deploy'])

local_resource(
    'deploy',
    './record-start-time.sh',
)
```

`resource_deps=['deploy']` means the Kubernetes resource waits for the `deploy` local resource to finish before updating. Clicking the `deploy` button in the [[tilt]] UI triggers `record-start-time.sh`, which kicks off a full rebuild cycle.

| Approach | Deploy Time |
| -------- | ----------- |
| Naive    | 4.2 s       |

The naive cycle is slow because every file change triggers: source copy → dependency download → full compile inside [[docker]].

## Stage 2 — Local Compile (binary copy into container)

Compile the Go binary locally (where the Go toolchain cache exists) and copy only the output binary into the Docker build context.

```python
local_resource(
  'example-go-compile',
  'CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/tilt-example-go ./',
  deps=['./main.go', './start.go'],
  resource_deps=['deploy'])

docker_build(
  'example-go-image',
  '.',
  dockerfile='deployments/Dockerfile',
  only=[
    './build',
    './web',
  ])
```

Key changes:

- `local_resource` named `example-go-compile` runs `go build` targeting `linux/amd64` and writes the binary to `build/tilt-example-go`.
- `deps` list means Tilt only re-runs the compile step when `main.go` or `start.go` change.
- `only` parameter on `docker_build` restricts the build context to `./build` and `./web`, preventing unrelated changes from triggering Docker rebuilds.
- The Dockerfile is updated to `COPY` only those two directories.

| Approach      | Deploy Time |
| ------------- | ----------- |
| Naive         | 4.2 s       |
| Local Compile | 3.5 s       |

## Stage 3 — `live_update` (recommended)

Skip the image rebuild and pod reschedule entirely by syncing files directly into the running container and restarting the process in place. Uses the `restart_process` [[tilt]] extension.

```python
load('ext://restart_process', 'docker_build_with_restart')
...
docker_build_with_restart(
  'example-go-image',
  '.',
  entrypoint='/app/build/tilt-example-go',
  dockerfile='deployments/Dockerfile',
  only=[
    './build',
    './web',
  ],
  live_update=[
    sync('./build', '/app/build'),
    sync('./web', '/app/web'),
  ],
)
```

Key changes:

- `load('ext://restart_process', 'docker_build_with_restart')` imports the extension.
- `docker_build_with_restart` replaces `docker_build`; it is otherwise identical but adds automatic process restart after a `live_update` cycle.
- `live_update` list contains two `sync` steps: `sync(local_path, container_path)`.
- `entrypoint` specifies what to re-execute after sync (`/app/build/tilt-example-go`).

On a code change Tilt now: compiles locally → syncs `./build` and `./web` into the container → sends a restart signal. No image push, no pod reschedule.

See also: [[tilt-live-update]].

| Approach         | Deploy Time |
| ---------------- | ----------- |
| Naive            | 4.2 s       |
| Local Compile    | 3.5 s       |
| With live_update | **1.5 s**   |

## Architecture Pattern Summary

```
file change
  → local_resource (go build, local cache)
  → docker_build_with_restart (only: build/ + web/)
      on first deploy: full image build + push + pod schedule
      on subsequent changes: live_update sync + process restart
```

## CI Integration

The example repo uses CircleCI with [`ctlptl`](https://github.com/tilt-dev/ctlptl) to create a disposable [[kubernetes]] cluster and runs `tilt ci` (deploys all [[tiltfile]] services and exits 0 if healthy) as the gating test.

## Related Examples

- [[tilt-example-nodejs]]
- [[tilt-example-python]]
- [[tilt-example-java]]
- [[tilt-example-static-html]]
