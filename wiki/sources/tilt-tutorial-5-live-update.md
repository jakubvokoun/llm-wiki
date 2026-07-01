---
title: "Tilt Tutorial 5: Smart Rebuilds with Live Update"
tags: [tilt, live-update, docker, kubernetes]
sources: [tilt-tutorial-5-live-update]
updated: 2026-07-01
---

# Tilt Tutorial 5: Smart Rebuilds with Live Update

Part of the [[tilt]] tutorial series. Covers [[tilt-live-update]] — in-place container updates that bypass the full image rebuild/push/deploy cycle.

## The Problem: Slow Naïve Rebuilds

Without Live Update, every code change in a [[kubernetes]]-based workflow requires:

1. `docker build` — rebuild the container image
2. `docker push` — push to registry
3. `kubectl apply -f` — update the Deployment with the new tag
4. Wait for pod rollout

Live Update short-circuits all of this by **copying changed files directly into running containers**, optionally running follow-up commands inside the container.

## Configuring Live Update in `docker_build()`

Live Update is enabled via the `live_update` argument to `docker_build()` in the [[tiltfile]]:

```python
docker_build(
    'tilt-avatar-api',
    context='.',
    dockerfile='./deploy/api.dockerfile',
    only=['./api/'],
    live_update=[
        sync('./api/', '/app/api/'),
        run(
            'pip install -r /app/requirements.txt',
            trigger=['./api/requirements.txt']
        )
    ]
)
```

The `live_update` value is an ordered list of steps executed in sequence when a watched file changes.

## Step Types

### `sync(src, dest)`

Copies files from the host into a running container.

| Argument | Description                                                                   |
| -------- | ----------------------------------------------------------------------------- |
| `src`    | Path on host, relative to the `Tiltfile`. Tilt watches this path recursively. |
| `dest`   | Absolute path **inside the container** where files are copied.                |

**Constraint:** Files synced must already be within paths that Tilt watches for the image build (i.e. covered by the `only` or `context` arguments of `docker_build()`).

Example log output when a sync fires:

```
Will copy 1 file(s) to container: 4a9aac5527
- '/Users/quixote/dev/tilt-avatars/api/app.py' --> '/app/api/app.py'
  → Container 4a9aac5527 updated!
```

For frameworks with hot-reload support (e.g. Flask dev server, Webpack), a `sync()` step alone is sufficient — no process restart needed.

### `run(cmd, trigger=[])`

Runs a shell command **inside the container** after a matching file change.

| Argument  | Description                                                          |
| --------- | -------------------------------------------------------------------- |
| `cmd`     | Shell command to execute inside the container.                       |
| `trigger` | List of host paths (relative to `Tiltfile`) that activate this step. |

The `trigger` condition is evaluated after the `sync()` step, so the updated file is already present in the container when `run()` executes.

Example — installing updated Python dependencies when `requirements.txt` changes:

```python
run(
    'pip install -r /app/requirements.txt',
    trigger=['./api/requirements.txt']
)
```

Log output:

```
Will copy 1 file(s) to container: 4a9aac5527
- '.../api/requirements.txt' --> '/app/api/requirements.txt'
[CMD 1/1] sh -c pip install -r /app/requirements.txt
   ...
  → Container 4a9aac5527 updated!
```

## Process Restart (Hot Reload Not Required)

For compiled languages or frameworks without native hot reload, Live Update can restart the process inside the container after syncing updated binaries/files. This still avoids the image build and deployment overhead. See the [Live Update Reference](https://docs.tilt.dev/live_update_reference.html#restarting-your-process) for details.

## Key Takeaways

- `live_update` is a list of ordered steps inside `docker_build()`.
- `sync()` copies files host → container without rebuilding the image.
- `run()` executes commands in the container, conditionally gated by `trigger` paths.
- Works with both interpreted (Python/Flask, JS/Webpack) and compiled languages.
- The [[tilt-control-loop]] detects file changes and applies Live Update steps instead of triggering a full image rebuild when the `live_update` config matches.

## Related Pages

- [[tilt]] — overview of the Tilt dev tool
- [[tiltfile]] — Tiltfile authoring reference
- [[tilt-live-update]] — full Live Update reference
- [[tilt-control-loop]] — how Tilt watches and responds to changes
- [[docker]] — underlying image build tooling
- [[kubernetes]] — target deployment environment
