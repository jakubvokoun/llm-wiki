---
title: "Tilt in Continuous Integration"
tags: [tilt, ci, kubernetes]
sources: [tilt-ci]
updated: 2026-07-01
---

# Tilt in Continuous Integration

Guide to using [[tilt|Tilt]] in CI to verify that services still build and deploy on every change. Two things must be configured: the `tilt ci` command, and a Kubernetes cluster for it to deploy to.

## The `tilt ci` command

`tilt ci` is a one-shot command made for CI jobs. Under the hood it:

1. Executes the [[tiltfile|Tiltfile]].
2. Runs all `local_resource` commands ([[tilt-local-resource]]).
3. Builds all images.
4. Deploys all [[kubernetes]] resources.
5. Waits until all servers and resources are healthy.

Behavior:

- Defaults to **log-streaming mode** (web UI still at `http://localhost:10350/`, terminal is a plain log stream).
- Exits **immediately with an error code** if any step fails, or if a resource crashes / looks like it will never become healthy (e.g. a pod that won't schedule).
- Exits **0** once all services are healthy.
- Port forwards are **not** active after `tilt ci` exits.

### Debugging a stuck `tilt ci`

Inspect the **`Session`** object — the Tilt API that drives `tilt ci`:

```
tilt describe session        # human-readable
tilt get session -o yaml     # machine-readable
tilt get session -o json
```

The session status reports the current Tilt PID, start time, and each target Tilt is waiting on with its state (waiting / running / terminated).

## Single-use Kubernetes clusters in CI

[`kind`](https://kind.sigs.k8s.io/) is the gold standard for Kubernetes in CI (used by the Kubernetes project itself); it runs a cluster inside Docker and can host a local registry on `localhost:5000`, which Tilt auto-detects and pushes to instead of a prod registry. See [[tilt-choosing-clusters]] for local-dev cluster options.

| Approach                        | Verdict         | Notes                                                                     |
| ------------------------------- | --------------- | ------------------------------------------------------------------------- |
| **Cluster on VM-based CI**      | Easiest         | `kind` + local registry on a VM; VMs slower, heavier dependency upgrades  |
| **Cluster in remote Docker CI** | Recommended     | `kind` in a remote Docker env; `socat` forwards registry+cluster (tricky) |
| **Remote registry** (Quay, GCR) | Not recommended | Secret/permission management pain; risk of images leaking between tests   |

The Tilt team maintains **`ctlptl`** ([github.com/tilt-dev/ctlptl](https://github.com/tilt-dev/ctlptl)), a CLI to declaratively set up local clusters; it auto-detects remote Docker environments and wires up the `socat` forwarding automatically.

Related: [[tilt-control-loop]], [[tilt-example-go]], [[tilt-example-nodejs]], [[continuous-integration]].
