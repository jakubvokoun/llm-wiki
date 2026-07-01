---
title: "Tilt File Watching and Ignores"
tags: [tilt, file-watching, docker, devtools]
sources: [tilt-file-changes]
updated: 2026-07-01
---

# Tilt File Watching and Ignores

Reference: how [[tilt]] watches the filesystem, what triggers rebuilds, and how to suppress spurious ones.

## Design Principles

1. When a build is triggered, Tilt logs which file change caused it.
2. Files outside your control should not cause rebuilds.
3. Syntax is optimised to make ignoring easy and over-watching hard.

## Sources of File Watches

### Tiltfile

Tilt always watches the [[tiltfile]]. On change it re-executes the file (including any `local()` calls), diffs `docker_build()` / `k8s_yaml()` configs, and rebuilds only what changed.

Built-in functions that read files — `helm()`, `load()`, `read_file()` — automatically register watches on those files. For files read inside `local()` calls (which Tilt cannot introspect), register watches manually:

```python
watch_file("path/to/file")
```

### Image Builds (`docker_build`)

`docker_build('image-foo', './foo')` watches the entire `./foo` context directory. Any file change there triggers an image rebuild and redeploy of dependent Kubernetes resources.

### Custom and Local Resources

`custom_build()` and `local_resource()` accept a `deps=` parameter — a path or list of paths. A change anywhere under those paths reruns the associated script.

## Ignore Mechanisms

Multiple layers of ignores interact. Innermost (most specific) wins.

| Mechanism                      | Scope                          | Affects rebuild trigger | Affects Docker context     |
| ------------------------------ | ------------------------------ | ----------------------- | -------------------------- |
| `.git/` (hard-coded)           | all builds                     | yes                     | yes (removed from context) |
| Editor temp files (hard-coded) | rebuild trigger only           | yes                     | no                         |
| `.dockerignore`                | all `docker_build` in that dir | yes                     | yes                        |
| `docker_build(ignore=)`        | single `docker_build` call     | yes                     | yes                        |
| `docker_build(only=)`          | single `docker_build` call     | yes                     | yes                        |
| `.tiltignore`                  | all resources, entire project  | yes                     | no                         |
| `watch_settings(ignore=)`      | all resources (Tiltfile-level) | yes                     | no                         |

### `.git` and Editor Temp Files

Always ignored. `.git` is also stripped from [[docker]] build contexts. If you genuinely need `.git` in a build, use `custom_build` instead of `docker_build`.

Editor temp files (Emacs, Vim, etc.) are excluded from triggering rebuilds but are still sent in Docker build contexts by default — use `.dockerignore` to exclude them from the context too.

### `.dockerignore`

Place in the build context directory. Patterns follow `.dockerignore` syntax (gitignore-style). Files matching these patterns are excluded from both rebuild triggers and the Docker build context for every `docker_build` targeting that directory.

### `docker_build(ignore=)`

Per-image ignore patterns, evaluated relative to the `context` argument:

```python
docker_build(
    'image-foo',
    './foo',       # context
    ignore=['bar'] # ignores foo/bar
)
```

Useful when multiple services share a monorepo directory.

### `docker_build(only=)`

Inverse of `ignore=` — excludes everything _except_ the listed paths:

```python
docker_build(
    'image-foo',
    './foo',
    only=['./src', './static-files']
)
```

Equivalent `.dockerignore`:

```
**
!./src
!./static-files
```

`only=` accepts paths, not glob patterns. Paths are relative to `context` (`foo/src`, `foo/static-files` in the example). `only=` is not available on `custom_build` or `local_resource` — use `deps=` to control what those watch.

### `.tiltignore`

Project-wide ignore file. Place it next to your [[tiltfile]]. Uses `.dockerignore` syntax. Files matching these patterns never trigger any rebuild but are **not** excluded from Docker build contexts.

### `watch_settings(ignore=)`

Tiltfile-level equivalent of `.tiltignore`. Primarily used in Tilt extensions that download files and want to avoid self-triggering:

```python
watch_settings(ignore=['path/to/downloaded/files'])
```

Like `.tiltignore`, does not affect Docker build contexts.

## Inspecting File Watches

Tilt exposes a `FileWatch` API object for every watch it creates.

```bash
tilt get filewatches                          # list all watches
tilt describe filewatches                     # detailed view
tilt get filewatches configs:singleton -o yaml  # full spec + status for Tiltfile watch
```

The `status.fileEvents` field records each detected change with a timestamp, making it easy to see exactly which file triggered a reload.

### Live Editing for Debugging

`tilt edit filewatch <name>` opens the watch in `$EDITOR` for on-the-fly modification — add ignore patterns or remove watched paths temporarily. Edits are ephemeral: reloading the Tiltfile regenerates all watches from scratch.

```bash
EDITOR=vim tilt edit filewatch image:my-image
```

## Debugging Checklist

1. **Which file triggered the build?** Check Tilt's build log — it should name the file.
2. **Why is a file being watched at all?** Run `tilt get filewatches -o yaml` and inspect `spec.watchedPaths`.
3. **Suppress a specific file temporarily:** `tilt edit filewatch` to remove it or add an ignore pattern.
4. **Suppress globally:** add a pattern to `.tiltignore` next to the Tiltfile.
5. **Suppress for one image:** add `ignore=` to the `docker_build()` call.
6. **Suppress from Docker context too:** add to `.dockerignore` in the build directory.

## Known Gaps (as of source date)

- No UI indication of _which_ rule (`.dockerignore` vs `.tiltignore` vs `ignore=`) suppressed a given file change.
- No built-in tool to identify files present in a Docker image that shouldn't be there.

See also: [[tilt-control-loop]], [[tiltfile]]
