---
title: "Tilt: Building Dependent and Multi-Stage Image Hierarchies"
tags: [tilt, docker, images]
sources: [tilt-dependent-images]
updated: 2026-07-01
---

# Tilt: Building Dependent and Multi-Stage Image Hierarchies

Reference: [Tilt docs — Getting Started with Image Builds](https://docs.tilt.dev/dependent_images.html)

## From `docker build` to `docker_build()`

The [[tiltfile]] equivalent of `docker build -t my-image .` is:

```python
docker_build('my-image', '.')
```

The first argument is an **image selector** — [[tilt]] scans all workload manifests and matches any object whose image name contains `my-image` (tag ignored). The second argument is the build context directory; Tilt watches it for changes automatically.

**Restart behaviour:**

- Image unchanged → containers do **not** restart.
- Image changed → containers always restart with the fresh image.

### Tag-based matching

By default the selector ignores tags. To match a specific tag (useful for mono-repo "mega images" that differ only by tag):

```python
docker_build('my-mega-image:service-a', '.', entrypoint='/service-a')
docker_build('my-mega-image:service-b', '.', entrypoint='/service-b')
```

When a tag is specified, Tilt matches only deploy objects with that exact tag.

## Dependent Image Hierarchies

Multiple services often share a common base image (e.g. installed dependencies). Tilt supports a dependency tree of `docker_build()` calls where one image's `FROM` references another.

### Example: NodeJS base + app images

**`base.dockerfile`** — installs `node_modules`:

```dockerfile
FROM node:16-alpine
ARG node_env=production
ENV NODE_ENV $node_env
WORKDIR '/var/www/app'
ADD package.json package.json
RUN npm install
ENTRYPOINT node server.js
```

**`app.dockerfile`** — copies source on top of the base:

```dockerfile
FROM nodejs-express-base-image
WORKDIR '/var/www/app'
ADD . .
```

**[[tiltfile]]:**

```python
k8s_yaml('app.yml')

docker_build('nodejs-express-base-image',
             './package',
             dockerfile='base.dockerfile',
             build_args={'node_env': 'development'})

docker_build('nodejs-express-app-image',
             '.',
             dockerfile='app.dockerfile')

k8s_resource('nodejs-express-app', port_forwards=3000)
```

Key points:

- The base image uses `./package` as its context — Tilt only rebuilds it when files under `./package` change.
- When `tilt up` runs, Tilt resolves the dependency order automatically and injects the locally built base image into the app image's `FROM` (rewriting it to a local registry reference such as `localhost:5005/nodejs-express-base-image:tilt-<hash>`).
- A change to `server.js` skips the base image build entirely and rebuilds only the app image.

## Adding Live Updates

[[tilt-live-update]] rules should always be attached to the **deployed** image, never the base image (Tilt matches the image in the running container to decide which container to update).

```python
docker_build('nodejs-express-app-image',
             '.',
             dockerfile='app.dockerfile',
             live_update=[
               sync('.', '/var/www/app')
             ],
             entrypoint='yarn run nodemon /var/www/app/server.js')
```

- `sync(src, dest)` — copies local files into the running container without a rebuild.
- `entrypoint` override — here `nodemon` handles hot-reload; the exact reload step is framework-specific.
- Every live-update config needs both a **sync** step and a **reload** mechanism.

## Container Restart Orchestration

Tilt handles the full dependency graph:

| Trigger                            | What Tilt does                                              |
| ---------------------------------- | ----------------------------------------------------------- |
| File changes in base image context | Rebuild base → rebuild app image → restart container        |
| File changes in app context only   | Rebuild app image → restart container (skip base)           |
| Live-update sync matches           | Sync files into container → trigger reload (no image build) |

## Alternatives for Non-Standard Builds

- [[tilt-custom-build]] — for shell-script-driven or non-Docker build pipelines.
- Custom Resources — see Tilt's custom resource guide when injecting images into CRDs rather than standard Kubernetes `Deployment`/`Job` objects.

## Troubleshooting

- Unexpected rebuilds → check the build context path; narrower contexts (e.g. `./package` vs `.`) reduce noise.
- [[tilt]] file-change debugging guide covers how Tilt watches and ignores files.
- [[tilt-live-update]] reference covers the relationship between build context and live-update rules.

## Reference Projects

- [`tilt-example-base-image`](https://github.com/tilt-dev/tilt-example-base-image) — base image for `package.json` dependencies.
- [`live_update_base_image` integration test](https://github.com/tilt-dev/tilt/blob/master/integration/live_update_base_image/Tiltfile) — 2-level base image chain.
- [`imagetags` integration test](https://github.com/tilt-dev/tilt/blob/master/integration/imagetags/Tiltfile) — tag-based image matching.
