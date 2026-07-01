---
title: "Tilt Tutorial 4: Code, Update, Repeat"
tags: [tilt, live-update, docker, kubernetes]
sources: [tilt-tutorial-4-code-update-repeat]
updated: 2026-07-01
---

# Tilt Tutorial 4: Code, Update, Repeat

Part of the Tilt Avatars tutorial series. Covers how [[tilt]]'s [[tilt-control-loop]] detects file changes and drives automatic resource updates. See also [[tilt-tutorial-3-tilt-ui]] and [[tilt-live-update]].

## The Hands-Free Loop

Once `tilt up` is running, [[tilt]] watches for file changes and automatically:

1. Detects which resource owns the changed file
2. Rebuilds the container image
3. Pushes it to the local registry
4. Re-deploys to [[kubernetes]]
5. Streams pod rollout events and logs

No manual intervention needed between saving a file and seeing the result.

## `docker_build` — File Watching Arguments

The [[tiltfile]] function `docker_build()` controls both what gets built _and_ what files Tilt watches:

```python
docker_build(
    'tilt-avatar-web',          # image name
    context='.',                # build context root; Tilt watches recursively
    dockerfile='./deploy/web.dockerfile',  # optional; defaults to ./Dockerfile
    only=['./web/'],            # restrict watching/context to this subset
    ignore=['./web/dist/'],     # exclude paths from context and watching
    live_update=[...]           # see tilt-live-update
)
```

| Argument     | Required | Effect on file watching                               |
| ------------ | -------- | ----------------------------------------------------- |
| `context`    | yes      | Watch all files in this directory tree recursively    |
| `dockerfile` | no       | Watch only this file for Dockerfile changes           |
| `only`       | no       | Narrow watching to listed paths (useful in monorepos) |
| `ignore`     | no       | Exclude paths; supplements `.dockerignore`            |

> Path arguments are relative to the `Tiltfile`'s location.

### Monorepo pattern

In a monorepo with multiple services sharing a single repo root as `context`, use `only` to prevent changes in one service (e.g. `api/`) from triggering rebuilds in another (e.g. `web/`).

## Resource Auto-Assembly

[[tilt]] links a `docker_build` image to a resource by matching the image name against container image references in [[kubernetes]] YAML loaded via `k8s_yaml()`. No extra configuration is needed when names match. Manual assembly is available when auto-assembly is insufficient.

## Update Steps (Full Rebuild Path)

When a watched file changes and no [[tilt-live-update]] rule applies, Tilt runs a full update:

```
STEP 1/3 — Building Dockerfile: [tilt-avatar-web]
STEP 2/3 — Pushing localhost:44099/tilt-avatar-web:tilt-0b9fcdf9cfea47ba
STEP 3/3 — Deploying
     Injecting images into Kubernetes YAML
     Applying via kubectl:
     → web:deployment
```

The push step is cluster-dependent — local clusters that share the [[docker]] daemon may skip it.

## Immutable Image Tags

Tilt automatically tags every built image with a unique `:tilt-<hash>` tag and rewrites the Kubernetes YAML (or Helm chart) at deploy time to reference it. This avoids issues with rolling tags like `:latest` and image pull policy ambiguity. No configuration required.

## Pod Rollout Monitoring

After deploy, Tilt tracks the new pod and surfaces events inline:

```
Tracking new pod rollout (web-7f9b8b65f4-wt97k):
     ┊ Scheduled       - <1s
     ┊ Initialized     - <1s
     ┊ Ready           - 1s
```

Relevant events (image pull status, container crashes) are shown without needing `kubectl` commands. Once running, container logs are streamed automatically.

## Gotchas

- Changes to files matched by `ignore` or outside `only` are silently skipped — no rebuild triggered.
- Config-file changes (e.g. `vite.config.js`) that can't be hot-reloaded force a full image rebuild; use [[tilt-live-update]] rules for source-code changes to get faster inner-loop updates.
- The tutorial deliberately edits a config file to demonstrate the full-rebuild path before introducing [[tilt-live-update]].
