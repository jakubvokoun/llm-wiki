---
title: "Tilt Debugging FAQ"
tags: [tilt, debugging, troubleshooting, devtools]
sources: [tilt-debug-faq]
updated: 2026-07-01
---

# Tilt Debugging FAQ

Reference for diagnosing and resolving common [[tilt]] problems, drawn from the official debugging FAQ.

## Getting Help

- **Kubernetes Slack** — `#tilt` channel; the full Tilt team monitors it.
- **GitHub Issues** — file at `https://github.com/tilt-dev/tilt/issues`.
- **Snapshots** — share a frozen interactive copy of your Tilt UI for async debugging (see [[tilt-snapshots]]).

---

## Crash Diagnostics

### `tilt doctor`

First step whenever Tilt crashes or behaves unexpectedly on startup. Prints:

- Tilt version
- Operating system
- Docker host and version
- Kubernetes version
- Cluster type (Docker for Mac, Microk8s, etc.)
- Container runtime

This is the first thing the Tilt team asks for in bug reports.

---

## Image Build Failures

### `tilt docker -- build ARGS`

Runs Docker exactly as Tilt would run it, including any environment variables and optimizations Tilt applies automatically.

Useful when a build succeeds with a plain `docker build` but fails inside Tilt. For example, on Minikube, Tilt sets:

```
DOCKER_HOST=tcp://192.168.99.100:2376
DOCKER_CERT_PATH=/home/nick/.minikube/certs
DOCKER_TLS_VERIFY=1
```

…because it builds against Minikube's Docker daemon, not the host's. Running `tilt docker -- build -t image-name .` reveals exactly which environment is being used.

---

## Resource Usage (CPU / Memory)

Tilt exposes standard Go **pprof** endpoints at `http://localhost:10350/debug/pprof/` (since v0.10.26).

| Profile               | Command                                                               |
| --------------------- | --------------------------------------------------------------------- |
| 30-second CPU profile | `go tool pprof http://localhost:10350/debug/pprof/profile?seconds=30` |
| Heap snapshot         | `go tool pprof http://localhost:10350/debug/pprof/heap`               |

Both commands open an interactive REPL. Type `web` inside the REPL to render a visual CPU/allocation graph.

File an issue if Tilt is unexpectedly resource-heavy; the team actively works on these.

---

## State Inspection

[[tilt-control-loop|Tilt's engine]] is implemented as a control loop: it watches the Tiltfile, local source files, and the Kubernetes cluster, records changes in a central state store, and drives updates from that store.

### `tilt dump engine`

Prints a JSON representation of everything Tilt knows about build state and cluster state. Run in a second terminal while Tilt is running.

### `tilt dump webview`

Prints the complete state of the Tilt web UI — useful for diagnosing UI-level discrepancies.

Both commands are key tools for understanding what the [[tilt-control-loop]] is currently doing or has recorded.

---

## Sharing Debug Context

A **snapshot** is a frozen, shareable copy of the Tilt UI at a point in time. Recipients can interactively browse services, alerts, and Kubernetes events — everything available in the live UI. See [[tilt-snapshots]] for how to create and share them.

Snapshots are the recommended artifact to attach to bug reports.

---

## Team Usage Telemetry

`experimental_telemetry_cmd` (Tiltfile function, experimental) — accepts a shell command. Tilt execs it every minute, passing newline-separated [OpenTelemetry](https://opentelemetry.io/) span JSON on stdin. Spans represent all user activity in the preceding minute.

```python
# Send to a local script
experimental_telemetry_cmd("/path/to/honeycomb_ingest.py")

# Send via a Docker image
experimental_telemetry_cmd("docker run --env USER -i my-telemetry-image")
```

Each span JSON object includes `Name`, `StartTime`, `EndTime`, `SpanContext`, and related tracing fields. Designed for larger teams that need centralized observability into Tilt usage. Known integrations: Datadog time series, statsd.

---

## Quick Reference

| Symptom                            | Command / Action                       |
| ---------------------------------- | -------------------------------------- |
| Crash on startup                   | `tilt doctor`                          |
| Build fails in Tilt, works locally | `tilt docker -- build ARGS`            |
| High CPU                           | `go tool pprof .../profile?seconds=30` |
| High memory                        | `go tool pprof .../heap`               |
| Understand engine state            | `tilt dump engine`                     |
| Understand UI state                | `tilt dump webview`                    |
| Share context with team/support    | Create a [[tilt-snapshots\|snapshot]]  |

## Related Pages

- [[tilt]] — overview and core concepts
- [[tilt-faq]] — general FAQ
- [[tilt-control-loop]] — how the Tilt engine processes state
- [[tilt-snapshots]] — sharing Tilt state snapshots
