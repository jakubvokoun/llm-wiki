---
title: "Tilt: Custom Image Builders (custom_build)"
tags: [tilt, build, docker]
sources: [tilt-custom-build]
updated: 2026-07-01
---

# Tilt: Custom Image Builders (`custom_build`)

While [[docker]] `docker_build()` covers the common case, [[tilt]] provides
`custom_build()` for any other image builder — wrapping Docker, using
alternative runtimes, or integrating build systems like [[bazel]].

## Core API

```python
custom_build(
  ref,          # image name / registry ref, e.g. 'frontend' or 'gcr.io/co/frontend'
  cmd,          # shell command to run the build
  deps,         # list of files/dirs to watch; rebuild triggers on changes
)
```

All three positional arguments are required. Additional keyword args are
described below.

---

## Builder Patterns

### 1. Custom Docker wrapper

Use when you have a script that calls `docker build` with extra flags or
abstractions that `docker_build()` doesn't expose:

```python
custom_build(
  'frontend',
  'docker build -t $EXPECTED_REF frontend',
  ['./frontend'],
)
```

Tilt runs the command, verifies the image landed in the local Docker store, then
pushes it with an immutable content-based tag.

### 2. Jib / Bazel (Docker-interoperable builders)

Tools that write to the local Docker image store work with the same pattern.
Jib (Gradle/Maven Java builds) example from
[tilt-example-java](https://github.com/tilt-dev/tilt-example-java):

```python
custom_build(
  'example-java-image',
  './gradlew jibDockerBuild --image $EXPECTED_REF',
  deps=['src'],
)
```

[[bazel]] with `rules_docker` follows the same approach — see
[[tilt-integrating-bazel]] for the full walkthrough.

### 3. Buildah (Docker-independent builders)

Builders with their own image store must both build **and** push in the same
command. Set `skips_local_docker=True` so Tilt doesn't try to verify the image
locally:

```python
custom_build(
  'frontend',
  'buildah bud -t $EXPECTED_REF frontend && buildah push $EXPECTED_REF $EXPECTED_REF',
  ['./frontend'],
  skips_local_docker=True,
)
```

**Caveats for Docker-independent builders:**

- May require privileged access (`sudo` or an appropriate sandbox).
- Insecure registry support (e.g. Microk8s `localhost:32000`) must be
  configured in the builder's own registry config, not just in Tilt.

---

## Immutable Tag Management

Tilt never deploys mutable refs. Every image is retagged with a
content-based nonce before deployment:

```
gcr.io/company-name/frontend  →  gcr.io/company-name/frontend:tilt-ffd9c2013b5bf5d4
```

This eliminates race conditions when rolling out multiple pods: all pods use
exactly the same image bytes. Tilt then injects the new ref into the container
spec so Kubernetes can cache it aggressively.

### Coordinating the tag with your build script

**Good way — `$EXPECTED_REF`** (preferred): Tilt sets this env var to a
randomized ref before invoking the command. The build script tags the image with
`$EXPECTED_REF`; Tilt then re-tags it with a content digest and pushes.

**Hacky way — `tag=` kwarg**: For tools that hard-code an output ref:

```python
custom_build(
  'frontend',
  'my-builder',
  ['./src'],
  tag='gcr.io/company-name/frontend:dev',
)
```

Tilt finds the image at the given mutable tag and retaggs it. Less robust
because the build always overwrites the same mutable tag.

**Content-tag output file — `outputs_image_ref_to=`**: For scripts that can
produce their own content-based tags, tell Tilt to read the final ref from a
file:

```python
custom_build(
  'frontend',
  './build.sh',
  ['./src'],
  outputs_image_ref_to='ref.txt',
)
```

Tilt also injects `REGISTRY_HOST` (e.g. `localhost:5000`) when a local registry
is detected.

### Inspecting the deploy ref

To find out what content-based tag Tilt will use after a build (rare, advanced):

```sh
tilt dump image-deploy-ref $EXPECTED_REF
```

---

## Live Update and Other Features

`custom_build` supports `live_update` with the same syntax as `docker_build`,
enabling in-place code sync without a full rebuild. See [[tilt-dependent-images]]
for patterns involving images that depend on one another.

### File watching: `ignore`

```python
custom_build(
  'image-foo',
  'docker build -t $EXPECTED_REF .',
  deps=['dep1', 'dep2'],
  ignore=['baz'],          # ignores dep1/baz and dep2/baz
)
```

Patterns follow `.dockerignore` syntax and are evaluated relative to each entry
in `deps`.

---

## Extensions and Community Resources

The
[tilt-example-builders](https://github.com/tilt-dev/tilt-example-builders) repo
demonstrates many builders (each tested against a live ephemeral Kubernetes
cluster on CI). The [Tilt extensions
index](https://github.com/tilt-dev/tilt-extensions) lists additional community
image-builder extensions.

---

## Key Parameters Reference

| Parameter              | Purpose                                                       |
| ---------------------- | ------------------------------------------------------------- |
| `ref`                  | Image name / registry ref                                     |
| `cmd`                  | Build command; receives `$EXPECTED_REF` env var               |
| `deps`                 | Files/dirs to watch for changes                               |
| `tag`                  | Hard-coded output tag (hacky way)                             |
| `skips_local_docker`   | `True` for builders with their own image store (e.g. Buildah) |
| `outputs_image_ref_to` | File path where build script writes the final image ref       |
| `ignore`               | Patterns (`.dockerignore` syntax) to exclude from watch       |
| `live_update`          | Live update steps, same syntax as `docker_build`              |

---

## See Also

- [[tilt]] — overview of the Tilt dev tool
- [[tiltfile]] — the Starlark config file where `custom_build` is called
- [[tilt-integrating-bazel]] — detailed Bazel integration guide
- [[tilt-dependent-images]] — handling images that depend on other images
