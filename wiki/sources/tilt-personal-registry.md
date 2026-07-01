---
title: "Setting Up Image Registries in Tilt"
tags: [tilt, registry, docker]
sources: [tilt-personal-registry]
updated: 2026-07-01
---

# Setting Up Image Registries in Tilt

Reference: how [[tilt]] resolves, pushes, and rewrites image names across different registry setups. Covers the `default_registry()` function in a [[tiltfile]] and special-case patterns for ECR and split-URL registries.

## The Common Case — No Configuration Needed

For most cluster types, the registry is already handled:

- **Docker Desktop** — no registry; Tilt builds directly into the container runtime.
- **Local clusters (Kind, etc.)** — Tilt's setup scripts provision a local registry automatically.
- **Managed cloud clusters (AKS, EKS, GKE, DigitalOcean)** — a colocated registry is already configured.

Tilt never talks to a registry directly. It tells the image builder (e.g. [[docker]]) to push when a build finishes. Authentication is handled by the image builder:

```sh
docker login              # Docker Hub
docker login quay.io      # other registries
```

For AWS ECR, Google Artifact Registry, and GCR, use the provider's credential helper to keep `kubectl` and registry credentials in sync.

## `docker_build` — Image Selector Basics

The first argument to `docker_build` is an image _selector_, matched against image names in your deploy YAML (e.g. a [[kubernetes]] Deployment):

```python
docker_build('my-image', '.')
```

- **Local cluster:** the host part of the image name does not matter — Tilt rewrites the fully-qualified name automatically.
- **Remote cluster:** use the full registry path in both `docker_build` and the YAML, e.g. `gcr.io/my-project/my-image`.

## `default_registry` — Redirect All Pushes

`default_registry()` rewrites every image name Tilt builds, so you do not need to put the registry host in `docker_build()` or your YAML.

### Anonymous ephemeral registry (`ttl.sh`)

Useful when the cluster has no registry configured:

```python
default_registry('ttl.sh/[my-user-name]-[random-string]')
```

Tilt first tries to load the image directly to the cluster; if that fails, it pushes to `ttl.sh` (HTTPS, no auth, images deleted after 1 hour).

### Personal or per-team registry via `tilt_option.json`

For organisations that want each developer to push to their own registry without editing the shared [[tiltfile]]:

**`Tiltfile`:**

```python
settings = read_json('tilt_option.json', default={})
default_registry(settings.get('default_registry', 'gcr.io/shared-project-registry'))
```

**`tilt_option.json`** (developer-local, not committed):

```json
{
  "default_registry": "gcr.io/my-personal-project"
}
```

**`.gitignore`:**

```
# personal tilt settings
tilt_option.json
```

Team members who do not create the file fall back to the shared registry. Tilt uses content-based image tags, so concurrent pushes from different developers do not overwrite each other.

## Special Registry Configurations

### Split URLs (different host inside vs. outside the cluster)

When the registry hostname resolves differently from the laptop than from inside [[kubernetes]] (e.g. `localhost:5000` vs. `registry:5000`):

```python
default_registry(
    'localhost:5000',
    host_from_cluster='registry:5000'
)
```

Tilt pushes using the outer host and injects the inner host into the deploy YAML.

### AWS ECR — `single_name` parameter

ECR requires a repository to exist before an image can be pushed. To avoid creating one repository per image name, funnel all images into a single repository using the `single_name` parameter:

```python
default_registry(
  'aws_account_id.dkr.ecr.region.amazonaws.com',
  single_name='my-team-name/dev')
```

Per-developer variant (reads an env var so each developer gets their own path):

```python
default_registry(
  'aws_account_id.dkr.ecr.region.amazonaws.com',
  single_name='%s/dev' % os.environ.get('AWS_USERNAME'))
```

## Summary of `default_registry` Parameters

| Parameter           | Purpose                                                   |
| ------------------- | --------------------------------------------------------- |
| _(positional)_      | Registry host as seen from the local machine              |
| `host_from_cluster` | Registry host as seen from inside the cluster (split-URL) |
| `single_name`       | Push all images into one repository (ECR workaround)      |
