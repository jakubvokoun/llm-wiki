---
title: "Local Resources — Commands, Servers, and Tests"
tags: [tilt, local-resource, tiltfile]
sources: [tilt-local-resource]
updated: 2026-07-01
---

# Local Resources — Commands, Servers, and Tests

A **local resource** is a [[tilt-control-loop|Tilt resource]] whose work is to execute an arbitrary command on the local filesystem (rather than build an image and deploy [[kubernetes]] YAML). Defined with `local_resource()` in the [[tiltfile|Tiltfile]]:

```python
local_resource('yarn', cmd='yarn install', deps=['package.json'])
```

## Key arguments

| Argument            | Purpose                                                                             |
| ------------------- | ----------------------------------------------------------------------------------- |
| `cmd`               | Batch command; runs and is expected to terminate (red/green by exit code)           |
| `deps`              | File(s) that trigger re-execution on change. Without `deps`, runs once on `tilt up` |
| `serve_cmd`         | Long-running process (a server); resource is "running" as soon as it starts         |
| `resource_deps`     | Ordering — run after other resources are ready (see [[tilt-resource-dependencies]]) |
| `ignore`            | Files/dirs to exclude from `deps` watching                                          |
| `allow_parallel`    | Opt into running in parallel with other local resources (default: serial)           |
| `auto_init`         | `False` = don't run on startup (see [[tilt-manual-update-control]])                 |
| `env` / `serve_env` | Environment overrides for `cmd` / `serve_cmd`                                       |
| `readiness_probe`   | Determines when a `serve_cmd` is considered ready                                   |

## Behavior notes

- **Parallelism:** Tilt runs local build commands **serially** by default to avoid read/write race conditions; set `allow_parallel=True` for read-only jobs (linters, unit tests).
- **`auto_init=False`** pairs with `trigger_mode=TRIGGER_MODE_MANUAL` (only on explicit trigger) or `TRIGGER_MODE_AUTO` (not on `tilt up`, but on dep changes — useful for tests).
- **`serve_cmd` lifecycle:** on update Tilt runs `cmd` first and does **not** kill the old process until `cmd` succeeds; then it starts `serve_cmd`. If `serve_cmd` exits with any code, the resource turns red.

```python
# build then serve locally
local_resource('local-server', cmd='go build ./cmd/myserver',
               serve_cmd='./myserver --port=8001', deps=['cmd/myserver'])

# keep a port-forward open to a service Tilt didn't deploy
local_resource('kube-port-forward',
               serve_cmd='kubectl port-forward -n openfaas svc/gateway 8080:8080')
```

## Readiness probes

Probes decide when a `serve_cmd` is ready, so dependent resources wait for it. They mirror Kubernetes readiness probes: `http_get_action`, `tcp_socket_action`, or `exec_action`, with `period_secs`, failure thresholds, etc.

```python
local_resource("probe-example", serve_cmd="./myserver --port=8001",
   readiness_probe=probe(period_secs=15,
      http_get=http_get_action(port=8001, path="/health")))
```

Related: [[tilt]], [[tilt-control-loop]], [[tilt-manual-update-control]], [[tilt-resource-dependencies]].
