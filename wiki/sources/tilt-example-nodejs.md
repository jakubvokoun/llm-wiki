---
title: "Tilt Example: Node.js (Express + live_update)"
tags: [tilt, example, nodejs, live-update]
sources: [tilt-example-nodejs]
updated: 2026-07-01
---

A walkthrough of the [tilt-example-nodejs](https://github.com/tilt-dev/tilt-example-nodejs) repo, demonstrating how to progressively optimise a Node.js/Express app running on Kubernetes with [[tilt]], from a naive full rebuild down to sub-two-second in-place updates.

## The app

A minimal Express server (port 8000) that serves an HTML page rendered with [Mustache](https://mustache.github.io/). Later steps extend it to display the elapsed time since the last deploy, reading a timestamp file (`start-time.txt`) written by a `local_resource`.

## Step 0 — Simplest deployment

The base [[tiltfile]] is three lines:

```python
docker_build('example-nodejs-image', '.')
k8s_yaml('kubernetes.yaml')
k8s_resource('example-nodejs', port_forwards=8000)
```

- `docker_build` builds the image from the current directory; the image name must match the container reference in the Kubernetes Deployment.
- `k8s_yaml` loads the Deployment YAML.
- `k8s_resource` wires up port-forwarding; the resource name must match `metadata.name` in the YAML.

## Step 1 — Benchmarking with `local_resource`

A `local_resource` named `deploy` writes the current Unix timestamp to `start-time.txt`, triggering a redeploy:

```python
local_resource('deploy', 'date +%s > start-time.txt')
k8s_resource('example-nodejs', port_forwards=8000, resource_deps=['deploy'])
```

The server reads `start-time.txt` on startup via `getSecsSinceDeploy()` and renders the elapsed time in the page. Baseline result: **11.31–14.21 s**.

## Step 2 — Optimised [[docker]] layer caching

The naive Dockerfile ran `yarn install` on every build because application files were added before the lock files. Reordering fixes it:

```dockerfile
FROM node:10
WORKDIR /app
ADD package.json .
ADD yarn.lock .
RUN yarn install      # cached unless lock files change
ADD . .
ENTRYPOINT [ "node", "/app/index.js" ]
```

`yarn install` is now skipped on subsequent builds when `package.json` and `yarn.lock` are unchanged. Result: **3.25–4.12 s**.

## Step 3 — `live_update` with nodemon

Skips image rebuilds and pod restarts entirely by syncing source files directly into the running container and relying on [nodemon](https://nodemon.io/) to restart the Node process.

### Tiltfile changes

```python
congrats = "🎉 Congrats, you ran a live_update! 🎉"
docker_build('example-nodejs-image', '.',
    build_args={'node_env': 'development'},
    entrypoint='yarn run nodemon /app/index.js',
    live_update=[
        sync('.', '/app'),
        run('cd /app && yarn install', trigger=['./package.json', './yarn.lock']),
        run('touch /app/index.js', trigger='./start-time.txt'),
        run('sed -i "s/Hello cats!/{}/g" /app/views/index.mustache'.format(congrats)),
    ]
)
```

Key parameters:

| Parameter                                | Purpose                                                                            |
| ---------------------------------------- | ---------------------------------------------------------------------------------- |
| `entrypoint`                             | Overrides the Dockerfile `ENTRYPOINT` to run `yarn run nodemon /app/index.js`      |
| `build_args={'node_env': 'development'}` | Sets `$NODE_ENV=development` so `yarn install` includes dev dependencies (nodemon) |
| `live_update`                            | Ordered list of [[tilt-live-update]] steps executed in-place                       |

### `live_update` step sequence

1. `sync('.', '/app')` — copies changed local files into `/app` in the container.
2. `run('cd /app && yarn install', trigger=[...])` — re-runs only if `package.json` or `yarn.lock` changed.
3. `run('touch /app/index.js', trigger='./start-time.txt')` — nudges nodemon to reload when only the timestamp file changed (otherwise nodemon wouldn't detect a meaningful change).
4. A `run('sed -i ...')` that patches the Mustache template as a congratulatory demo.

nodemon watches `/app` and restarts the Node process automatically after file sync.

Result: **1.1–1.8 s**.

## Performance summary

| Approach             | Deploy time   |
| -------------------- | ------------- |
| Naive                | 11.31–14.21 s |
| Optimised Dockerfile | 3.25–4.12 s   |
| With `live_update`   | 1.1–1.8 s     |

## CI

The repo uses `ctlptl` to spin up a single-use [[kubernetes]] cluster on CircleCI and runs `tilt ci`, which deploys all resources defined in the [[tiltfile]] and exits 0 when they are healthy.

## Related examples

- [[tilt-example-go]]
- [[tilt-example-python]]
- [[tilt-example-java]]
- [[tilt-example-static-html]]

Other JS reference projects from the Tilt team: _tilt-avatars_ (Vite frontend), _pixeltilt_ (Next.js), _abc123_ (microservice), _servantes_ (multi-language).
