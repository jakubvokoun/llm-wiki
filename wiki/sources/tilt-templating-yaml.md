---
title: "Modifying YAML for Dev with Tilt"
tags: [tilt, kubernetes, yaml]
sources: [tilt-templating-yaml]
updated: 2026-07-01
---

# Modifying YAML for Dev with Tilt

Reference: [[tilt]] docs on patching and templating Kubernetes YAML for local development environments.

## What Tilt Applies Automatically

When you call `k8s_yaml('deployment.yaml')` in a [[tiltfile]], Tilt silently applies three mutations before deploying:

- Adds label `app.kubernetes.io/managed-by: tilt` to every resource.
- Sets `pullPolicy: IfNotPresent` or `pullPolicy: Never` on all containers when using a local cluster (prevents unnecessary remote pulls).
- Injects a fully-resolved image tag (the digest produced by `docker_build`).

### Inspecting what Tilt deployed

```sh
tilt get kubernetesapply                        # list all YAML-applying resources
tilt get kubernetesapply docs-site -o yaml      # show spec.yaml + status.resultYAML
```

`spec.yaml` is what you gave Tilt; `status.resultYAML` is what came back from the cluster.

## In-Tiltfile Patching

For one-off tweaks that don't warrant a full templating tool, use the built-in YAML codec:

| Function                      | Purpose                               |
| ----------------------------- | ------------------------------------- |
| `read_yaml_stream(path)`      | Read a file from disk → list of dicts |
| `decode_yaml_stream(string)`  | Decode a YAML string → list of dicts  |
| `encode_yaml_stream(objects)` | Encode a list of dicts → YAML string  |

**Example — set namespace on every object:**

```python
objects = read_yaml_stream('deployment.yaml')
for o in objects:
    o['metadata']['namespace'] = 'my-ns'
k8s_yaml(encode_yaml_stream(objects))
```

This pattern is used by the community [`namespace` extension](https://github.com/tilt-dev/tilt-extensions/tree/master/namespace).

## Connecting External YAML Tools

Any script or tool that emits YAML can be wired in via `local()`:

```python
k8s_yaml(local('./generate-yaml.sh'))
```

Tilt runs the script at startup, registers the output, and redeploys when watched files change.

Two built-in wrappers handle the most common tools:

### `kustomize(dir)`

Runs `kustomize build` on the given directory and returns YAML.

```python
k8s_yaml(kustomize('.'))
```

See [[tiltfile]] API docs and the Tilt blog post _"Are You My Kustomize?"_ for interop details.

### `helm(chart_path, ...)`

Runs `helm template` on the given chart directory (or a remote chart) and returns YAML.

```python
k8s_yaml(helm('./charts/myapp', name='myapp', namespace='dev'))
```

See [[tilt-helm]] for the full Helm guide. Both `kustomize()` and `helm()` are thin wrappers around `local()` with dependency-watching ergonomics.

### Custom tools as extensions

Tools not built in can be packaged as [Tilt Extensions](https://docs.tilt.dev/extensions.html) and shared. Extensions follow the same `local()` pattern under the hood.

## When YAML Is Not Enough

Some tools (Pulumi, Helm with chart hooks, remote Artifact Hub packages) don't emit a static pile of YAML — they manage ordering, health checks, and post-deploy hooks themselves.

For these, use `k8s_custom_deploy` instead of `k8s_yaml`:

```python
k8s_custom_deploy(
    'my-release',
    apply_cmd='helm upgrade --install my-release ./chart',
    delete_cmd='helm uninstall my-release',
    deps=['./chart'],
)
```

The community [`helm_resource` extension](https://github.com/tilt-dev/tilt-extensions/tree/master/helm_resource) wraps this for Helm.

## Decision Guide

| Scenario                       | Recommended approach                                      |
| ------------------------------ | --------------------------------------------------------- |
| One-off field tweak            | `read_yaml_stream` / `encode_yaml_stream` in [[tiltfile]] |
| Kustomize overlays             | `kustomize('.')`                                          |
| Helm chart templating          | `helm('./chart')` — see [[tilt-helm]]                     |
| Arbitrary shell script         | `local('./script.sh')`                                    |
| Tool manages its own lifecycle | `k8s_custom_deploy`                                       |
