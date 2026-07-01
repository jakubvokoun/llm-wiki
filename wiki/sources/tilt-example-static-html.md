---
title: "Tilt Example: Plain Old Static HTML"
tags: [tilt, example, live-update]
sources: [tilt-example-static-html]
updated: 2026-07-01
---

# Tilt Example: Plain Old Static HTML

Source: [tilt-dev/tilt-example-html](https://github.com/tilt-dev/tilt-example-html) |
Docs: <https://docs.tilt.dev/example_static_html.html>

A minimal walkthrough showing how to bring a static HTML server into [[tilt]], measure its
feedback loop, and then collapse that loop with [[tilt-live-update]]. The server itself is
intentionally trivial (two-line busybox shell script) so that every second of latency is clearly
attributable to the tooling, not the app.

## The App

```sh
echo "Serving files on port 8000"
busybox httpd -f -p 8000
```

Three files are needed to run this on [[kubernetes]]: a `Dockerfile`, a `kubernetes.yaml`
Deployment manifest, and a [[tiltfile]].

## Step 0 — Simplest Deployment

```python
docker_build('example-html-image', '.')
k8s_yaml('kubernetes.yaml')
k8s_resource('example-html', port_forwards=8000)
```

- `docker_build('example-html-image', '.')` — builds a [[docker]] image named `example-html-image`
  from the current directory. The image name must match the `image:` field in the Deployment.
- `k8s_yaml('kubernetes.yaml')` — loads the Kubernetes Deployment manifest.
- `k8s_resource('example-html', port_forwards=8000)` — exposes the service at `localhost:8000`.
  The first argument must match `metadata.name` in the YAML.

Run with:

```sh
git clone https://github.com/tilt-dev/tilt-example-html
cd tilt-example-html/0-base
tilt up
```

## Step 1 — Benchmarking with `local_resource`

To measure the feedback loop before optimising it, a `local_resource` records a start timestamp on
every deploy trigger:

```python
k8s_resource('example-html', port_forwards=8000, resource_deps=['deploy'])

local_resource(
  'deploy',
  'date +%s > start-time.txt')
```

- `local_resource('deploy', cmd)` — creates a sidebar resource named `deploy` that runs an
  arbitrary shell command on the developer's machine.
- `resource_deps=['deploy']` — ensures the Kubernetes resource waits for `deploy` to finish before
  updating, so the elapsed time captured by the server is meaningful.
- The server reads `start-time.txt` and prints elapsed milliseconds to its log.

**Naive baseline: 1–2 s** end-to-end (image build → schedule → process ready).

## Step 2 — Optimising with `live_update`

Instead of rebuilding the image on every change, [[tilt-live-update]] syncs files directly into
the running container:

```python
docker_build('example-html-image', '.', live_update=[
  sync('.', '/app'),
  run('./report-deployment-time.sh'),
  run('sed -i "s/Hello cats/Congratulations, you set up live_update/g" index.html'),
])
```

### `live_update` steps in order

| Step | Function                             | Effect                                                                      |
| ---- | ------------------------------------ | --------------------------------------------------------------------------- |
| 1    | `sync('.', '/app')`                  | Copies changed files from host `.` into container `/app` — no image rebuild |
| 2    | `run('./report-deployment-time.sh')` | Executes the timing script inside the container                             |
| 3    | `run('sed -i …')`                    | Rewrites `index.html` as a one-time congratulatory message                  |

**Result: update completes in < 1 s** (Tilt skips the full image build and Kubernetes reschedule).

## Feedback-Loop Summary

| Approach                    | Deploy Time |
| --------------------------- | ----------- |
| Naive (`docker_build` only) | 1–2 s       |
| With `live_update`          | 0–1 s       |

The speedup comes from bypassing the three slow steps on every code change: image build, manifest
apply, and pod reschedule. `live_update` replaces all three with a direct file sync.

## CI Integration

The example repo uses `ctlptl` to spin up a single-use [[kubernetes]] cluster in CircleCI, then
runs `tilt ci` — which deploys all resources defined in the [[tiltfile]] and exits 0 only if all
are healthy. This validates the `live_update` configuration in CI without requiring a long-lived
cluster.

## Related Examples

See sibling examples for the same pattern applied to real language stacks:
[[tilt-example-go]], [[tilt-example-nodejs]], [[tilt-example-python]], [[tilt-example-java]].
