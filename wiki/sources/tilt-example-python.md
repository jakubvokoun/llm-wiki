---
title: "Tilt Example: Python + Flask"
tags: [tilt, example, python, live-update]
sources: [tilt-example-python]
updated: 2026-07-01
---

# Tilt Example: Python + Flask

A step-by-step walkthrough from the official Tilt docs showing how to take a
minimal Flask "hello world" app from a naive Kubernetes deployment to a
sub-2-second live-update workflow. The repo is
[tilt-dev/tilt-example-python](https://github.com/tilt-dev/tilt-example-python).

Related: [[tilt]] · [[tiltfile]] · [[tilt-live-update]] · [[docker]] ·
[[kubernetes]]

---

## The App

Seven-line Flask server (`app.py`):

```python
from flask import Flask, render_template
app = Flask(__name__)

@app.route("/")
def serve():
    return render_template("index.html")

if __name__ == "__main__":
    app.run(port=8000)
```

---

## Step 0 — Baseline Tiltfile (`0-base/`)

Three files are required: a `Dockerfile`, a `kubernetes.yaml` deployment, and a
[[tiltfile]]:

```python
docker_build('example-python-image', '.')
k8s_yaml('kubernetes.yaml')
k8s_resource('example-python', port_forwards=8000)
```

- `docker_build` — image name must match the `image:` field in the K8s
  Deployment.
- `k8s_yaml` — loads the Deployment manifest.
- `k8s_resource` — wires up port-forwarding; resource name must match
  `metadata.name` in `kubernetes.yaml`.

Run with `tilt up` from `0-base/`. The Tilt UI turns green when Flask logs
`Serving Flask app "app"`.

---

## Step 1 — Benchmarking with `local_resource` (`1-measured/`)

Add a `local_resource` to timestamp the start of each deploy:

```python
local_resource(
  'deploy',
  'date +%s > start-time.txt'
)
k8s_resource('example-python', port_forwards=8000,
             resource_deps=['deploy'])
```

The server reads the timestamp on startup via `get_update_time_secs()`:

```python
def get_update_time_secs() -> float:
    with open('/app/start-time.txt', 'r') as file:
        start_ns_since_epoch = float(file.read().strip())
    start_secs_since_epoch = start_ns_since_epoch / 10**9
    now_secs_since_epoch = time.time()
    return round(now_secs_since_epoch - start_secs_since_epoch, 2)
```

Called once at startup and stored in a global; rendered in the HTML template.
The `resource_deps` field ensures `deploy` runs before the server is updated.

**Baseline timing: 10–11 s.**

---

## Step 2 — Optimise the [[docker]] Layer Cache (`2-optimize-dockerfile/`)

The naive Dockerfile runs `pip install` on every build because application code
is added before dependencies. Fix: copy `requirements.txt` first so the
`pip install` layer is cached independently of source changes.

```dockerfile
ADD requirements.txt .
RUN pip install -r requirements.txt

ADD . .
```

Rule: place infrequently-changing layers (dependency installation) before
frequently-changing ones (application source).

**Timing after cache fix: 2.5–3.1 s.**

---

## Step 3 — `live_update` (`3-recommended/`)

Skip image rebuild + pod reschedule entirely by syncing files directly into the
running container.

```python
congrats = "🎉 Congrats, you ran a live_update! 🎉"
docker_build('example-python-image', '.', build_args={'flask_debug': 'True'},
    live_update=[
        sync('.', '/app'),
        run('cd /app && pip install -r requirements.txt',
            trigger='./requirements.txt'),
        run('touch /app/app.py', trigger='./start-time.txt'),
        run('sed -i "s/Hello cats!/{}/g" /app/templates/index.html'.
            format(congrats)),
    ])
```

`live_update` steps execute in order on each triggering change:

1. **`sync('.', '/app')`** — rsync the working directory into `/app` in the
   container.
2. **`run(…, trigger='./requirements.txt')`** — re-run `pip install` only when
   `requirements.txt` changes.
3. **`run('touch /app/app.py', trigger='./start-time.txt')`** — poke `app.py`
   to force Flask's dev-mode reloader to pick up the new start time.
4. Cosmetic `sed` step (demo only).

The `build_args={'flask_debug': 'True'}` parameter sets `FLASK_DEBUG=True`
inside the container (via a Dockerfile `ARG`/`ENV` pair), enabling Flask's
built-in file watcher so it auto-reloads on synced changes.

**Timing with live_update: 1–2 s.**

---

## Performance Summary

| Approach             | Deploy Time |
| -------------------- | ----------- |
| Naive                | 10–11 s     |
| Optimized Dockerfile | 2.5–3.1 s   |
| With `live_update`   | 1–2 s       |

---

## CI Integration

The example repo uses CircleCI + [`ctlptl`](https://github.com/tilt-dev/ctlptl)
to spin up a throwaway cluster and then runs `tilt ci`, which deploys all
resources defined in the [[tiltfile]] and exits 0 if they are healthy.

---

## See Also

- [[tilt-live-update]] — concept page for the live_update mechanism
- [[tiltfile]] — Tiltfile reference
- [[tilt-example-go]], [[tilt-example-nodejs]] — sibling language examples
- Tilt Avatars repo — microservice demo with a Python API backend
