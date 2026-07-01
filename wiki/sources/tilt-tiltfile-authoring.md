---
title: "Writing Your First Tiltfile"
tags: [tilt, tiltfile, kubernetes, docker]
sources: [tilt-tiltfile-authoring]
updated: 2026-07-01
---

# Writing Your First Tiltfile

A [[tiltfile]] is the configuration entry point for [[tilt]]. It is written in [[starlark]], a simplified
dialect of Python. Tilt watches the `Tiltfile` for changes and re-executes it on every save,
enabling an interactive, iterative setup workflow.

A minimal Tiltfile has three concerns — **Deploy**, **Build**, and **Watch** — expressed through
three core API functions.

## Complete Example

```python
# Deploy: register Kubernetes manifests
k8s_yaml('app.yaml')

# Build: declare container images
docker_build('companyname/frontend', 'frontend')
docker_build('companyname/backend', 'backend')

# Watch: expose a port from a running pod
k8s_resource('frontend', port_forwards=8080)
```

## Step 1 — Deploy: `k8s_yaml`

`k8s_yaml` registers [[kubernetes]] objects for Tilt to deploy. It is the only mandatory call.

```python
# Single file
k8s_yaml('app.yaml')

# Multiple files (list or repeated calls both work)
k8s_yaml(['foo.yaml', 'bar.yaml'])

# Generated YAML — run an arbitrary command
k8s_yaml(local('gen_k8s_yaml.py'))

# Built-in helpers for popular tools
k8s_yaml(kustomize('config_dir'))
k8s_yaml(helm('chart_dir'))
```

Once registered, Tilt displays the objects in its UI and manages their lifecycle through the
[[tilt-control-loop]].

## Step 2 — Build: `docker_build`

`docker_build` maps an image name (as it appears in your manifests) to a local build context.
Tilt builds the image, injects the resulting image ID into the [[kubernetes]] objects, and
redeploys — automatically on every source-file save.

```python
# Equivalent to: docker build -t companyname/frontend ./frontend
docker_build('companyname/frontend', 'frontend')
```

Add one `docker_build` call per container image under active development. Images not listed here
are pulled from a registry as normal by [[docker]] / the cluster runtime.

## Step 3 — Watch: `k8s_resource` (optional)

`k8s_resource` customises how Tilt interacts with a named resource. Its most common use is
stable port-forwarding to a running pod, whether the cluster is local or remote.

```python
# Forward host port 9000 to the 'frontend' resource
k8s_resource('frontend', port_forwards='9000')

# The first argument must match the resource name shown in the Tilt UI
# (i.e. the name of the pod-owning k8s object passed to k8s_yaml).
# Use new_name= to rename it:
k8s_resource('frontend', new_name='web', port_forwards=8080)
```

Multiple ports can be forwarded by passing a list to `port_forwards`.

## Startup Flow

1. Run `tilt up` in the project root (where `Tiltfile` lives).
2. Press `space` to open the Tilt browser UI.
3. Edit the `Tiltfile` and save — Tilt re-executes immediately.
4. Edit any source file watched by a `docker_build` call — Tilt rebuilds and redeploys.

## Key API Functions

| Function                       | Purpose                                |
| ------------------------------ | -------------------------------------- |
| `k8s_yaml(path_or_cmd)`        | Register manifests to deploy           |
| `docker_build(image, context)` | Declare a container image build        |
| `k8s_resource(name, ...)`      | Configure port-forwards, labels, deps  |
| `local(cmd)`                   | Run a shell command and capture output |
| `kustomize(dir)`               | Generate YAML via Kustomize            |
| `helm(dir)`                    | Generate YAML via Helm                 |
| `print(msg)`                   | Debug output (appears in Tilt UI)      |

## Language: Starlark

Tiltfiles are [[starlark]] programs — a deterministic, side-effect-free subset of Python used in
Bazel. Standard Python constructs (loops, conditionals, functions, string ops) work; imports and
mutable global state do not.

## See Also

- [[tilt]] — overview of the Tilt dev tool
- [[tiltfile]] — Tiltfile concepts and advanced patterns
- [[tilt-control-loop]] — how Tilt reconciles state after each Tiltfile execution
- [[kubernetes]] — cluster context Tilt deploys into
- [[docker]] — image builder invoked by `docker_build`
- [[starlark]] — the language Tiltfiles are written in
