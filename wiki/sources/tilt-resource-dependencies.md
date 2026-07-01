---
title: "Tilt Resource Dependencies and Startup Order"
tags: [tilt, dependencies, startup-order, readiness]
sources: [tilt-resource-dependencies]
updated: 2026-07-01
---

# Tilt Resource Dependencies and Startup Order

Reference: [Tilt docs — Resource Dependencies](https://docs.tilt.dev/resource_dependencies.html)

## Default Startup Behaviour

Tilt discovers resources from the [[tiltfile]] and brings them up as fast as safely possible:

- `local_resource` definitions run **first**, one at a time (serial), to avoid collisions on local output.
- Image builds and deploys for `k8s_resource` and `dc_resource` run **up to 3 in parallel** by default.
- Tilt makes educated guesses about safe parallelism from the YAML; application-level ordering requires explicit configuration.

List all resources Tilt knows about:

```
tilt get uiresources
```

## Declaring Dependencies with `resource_deps`

All three resource-configuration functions accept a `resource_deps` argument:

| Function         | Target                  |
| ---------------- | ----------------------- |
| `k8s_resource`   | Kubernetes workloads    |
| `dc_resource`    | Docker Compose services |
| `local_resource` | Local jobs and servers  |

Example — `frontend` waits for `database`:

```python
k8s_resource('frontend', resource_deps=['database'])
```

Effects of `resource_deps`:

1. `frontend` is not deployed until `database` has been **ready at least once** since `tilt up`.
2. `tilt up frontend` implicitly brings up all **transitive dependencies** of `frontend`.

> `resource_deps` only affects the **first build** after `tilt up`. Once any version of a dependency has been ready, downstream resources are unblocked for the rest of Tilt's lifetime. It ensures _some_ instance exists, not a _current_ one.

## Readiness Definitions

A resource is considered ready based on its type:

| Resource type              | Default "ready" condition                                      |
| -------------------------- | -------------------------------------------------------------- |
| `k8s_resource` (pod-based) | Pod running, all containers ready (Kubernetes readiness probe) |
| `k8s_resource` (Job)       | Job completed                                                  |
| `dc_resource`              | Container started (health checks not observed)                 |
| `local_resource`           | Command succeeded at least once                                |

### Kubernetes Readiness

Tilt honours built-in [Kubernetes readiness probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes) automatically.

For objects that do **not** create pods (e.g. certain CRDs), Tilt cannot determine readiness from pod state. Use `pod_readiness='ignore'` to mark the resource ready as soon as it is applied to the cluster:

```python
k8s_resource('frontend', pod_readiness='ignore')
```

For custom resource definitions, per-Kind default readiness settings can be configured — see the Tilt Custom Resource Definition guide.

### Local Resource Readiness Probes

[[tilt-local-resource]] supports readiness probes modelled on the Kubernetes API. Configure them via the `readiness_probe` parameter of `local_resource`. See the local resource guide for probe options (HTTP, exec, etc.).

## Controlling Parallelism

Default: up to **3** concurrent image builds/deploys for `k8s_resource` and `dc_resource`.

Override with `update_settings`:

```python
# Allow 10 concurrent updates
update_settings(max_parallel_updates=10)

# Force serial deploys
update_settings(max_parallel_updates=1)
```

`local_resource` commands are serial by default. Opt in to parallel execution explicitly:

```python
local_resource(name, cmd, allow_parallel=True)
```

## Relationship to the Tilt Control Loop

`resource_deps` gates the **initial** startup sequence inside the [[tilt-control-loop]]. After the first ready signal, the control loop treats dependencies as unblocked and responds to file-watch events normally — dependency ordering does not re-apply on subsequent rebuilds.

## Key API Surface

- `k8s_resource('name', resource_deps=[...], pod_readiness='ignore'|'wait')`
- `dc_resource('name', resource_deps=[...])`
- `local_resource(name, cmd, resource_deps=[...], allow_parallel=True, readiness_probe=...)`
- `update_settings(max_parallel_updates=N)`
