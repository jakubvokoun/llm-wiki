---
title: "Tiltfile Concepts"
tags: [tilt, tiltfile, starlark, kubernetes]
sources: [tilt-tiltfile-concepts]
updated: 2026-07-01
---

# Tiltfile Concepts

Source: [docs.tilt.dev/tiltfile_concepts.html](https://docs.tilt.dev/tiltfile_concepts.html)

A conceptual reference for [[tiltfile]] authoring, grouped by theme. Complements the API
reference by explaining _why_ to choose each function and how the pieces fit together.

## Execution Model

Tiltfiles are written in [[starlark]], a Python dialect. [[tilt]] executes the Tiltfile once on
startup. Functions like `k8s_yaml` and `docker_build` **register** information rather than act
immediately — Tilt assembles the final configuration after the entire file has run.

Tilt also records every file read during execution and watches those files. When a watched file
changes the Tiltfile is re-executed (not on every source file change — only files explicitly
read). See [[tilt-control-loop]] for how re-execution feeds back into the build/deploy cycle.

Because the Tiltfile is a program, familiar constructs (loops, functions, arrays, conditionals)
are all available — making Tilt more extensible than static config formats.

Relative paths in a Tiltfile are resolved relative to the Tiltfile's own location.

## Deploy — `k8s_yaml`

The first call in most Tiltfiles loads [[kubernetes]] YAML:

```python
# single file
k8s_yaml('app.yaml')

# multiple files, one call
k8s_yaml(['foo.yaml', 'bar.yaml'])

# multiple calls are additive
k8s_yaml('baz.yaml')
k8s_yaml('quux.yaml')

# generated YAML via built-in helpers
k8s_yaml(kustomize('config_dir'))
k8s_yaml(helm('chart_dir'))
```

`kustomize()` and `helm()` are thin wrappers around `local()`, which runs arbitrary shell
commands and returns their stdout as a `Blob`.

Custom generators work the same way:

```python
text = local('./foo.py')   # Blob containing YAML
k8s_yaml(text)
```

When a generator reads files that Tilt doesn't know about, declare them explicitly so the
watcher picks them up:

```python
read_file('config/base.yaml')
read_file('data/versions.txt')
k8s_yaml(local('./foo.py'))
```

List comprehensions make multi-service setups concise:

```python
def microservice_yaml(name):
    read_file('config/%s.yaml' % name)
    return local('./config/generate.py %s' % name)

services = ['frontend', 'backend', 'users', 'graphql']
[k8s_yaml(microservice_yaml(s)) for s in services]
```

Extensions (via `load()`) let you share custom generator functions across projects.

### `Blob` type

`k8s_yaml` (and similar functions) accept either a **file path** (plain `str`) or **inline
data** (a `Blob`). `local()` and `read_file()` return `Blob`s automatically. If you build a
YAML string manually, wrap it:

```python
k8s_yaml(blob(yaml_str))   # tells Tilt: treat this as data, not a path
```

## Build — `docker_build`

`docker_build` maps directly onto `docker build` flags:

```python
# docker build -t companyname/frontend ./frontend
docker_build("companyname/frontend", "frontend")

# custom Dockerfile
docker_build("companyname/frontend", "frontend",
             dockerfile="frontend/Dockerfile.dev")

# build args
docker_build("companyname/frontend", "frontend",
             build_args={"target": "local"})
```

Arguments can be combined freely. The image name must match the image referenced in your
[[kubernetes]] workload YAML — that is how Tilt links a build to a deployment. See [[docker]]
for general image build concepts.

## Resources

A **resource** is Tilt's unit of work: a bundle that may include a Docker image build, YAML to
apply, status, and logs. Tilt assembles resources automatically after Tiltfile execution:

- Every Kubernetes object that creates pods becomes a workload resource.
- Matching `docker_build` directives and affiliated objects (e.g. Services) are attached to
  that workload automatically.
- `local_resource()` calls each become their own resource directly.

### Configuring Resources — `k8s_resource`

Use `k8s_resource` to override automatic assembly:

```python
# rename
k8s_resource(workload='redis:deployment', new_name='redis')
```

### Port Forwarding

```python
# single port (host == container)
k8s_resource('frontend', port_forwards=9000)

# host:container mapping
k8s_resource('frontend', port_forwards='9000:8000')

# multiple forwards, with UI labels
k8s_resource('frontend', port_forwards=[
    port_forward(9000, 8000, "app"),
    port_forward(9001, 8001, "debugger"),
])
```

### Grouping Non-Workload Objects

Attach a Secret or Volume to an existing resource, or create a resource from non-workload
objects:

```python
# attach objects to an existing workload
k8s_resource('frontend', objects=['frontend:secret', 'frontend:volume'])

# new resource from non-workload objects (new_name required)
k8s_resource(
    objects=['my-ns:namespace', 'kafka:crd', 'some-ingress:ingress'],
    new_name='cluster-setup',
)
```

### Kubernetes Object Selectors

Objects are referenced with a Tilt-specific colon-separated selector:

```
$NAME[:$KIND[:$NAMESPACE]]
```

Examples: `redis`, `redis:deployment`, `redis:deployment:default`. The selector must uniquely
identify one object among all objects Tilt knows about; use more qualifiers to disambiguate
(e.g. when both a Deployment and a Service share the same name).

### Resource Labels / Groups

Labels group resources in the web UI into collapsible sections with aggregate status:

```python
k8s_resource('frontend', labels=['web'])
k8s_resource('backend',  labels=['api', 'core'])
local_resource('migrate', cmd='make migrate', labels=['core'])
```

`k8s_resource()`, `local_resource()`, and `dc_resource()` all accept `labels`. A resource with
multiple labels appears under each group. Groups are displayed alphabetically.

## Key Functions at a Glance

| Function                    | Purpose                                                |
| --------------------------- | ------------------------------------------------------ |
| `k8s_yaml(paths/blob)`      | Register Kubernetes YAML to apply                      |
| `kustomize(dir)`            | Generate YAML via kustomize (returns Blob)             |
| `helm(dir)`                 | Generate YAML via Helm (returns Blob)                  |
| `local(cmd)`                | Run shell command, return stdout as Blob               |
| `read_file(path)`           | Read file, return as Blob; registers file with watcher |
| `docker_build(img, ctx)`    | Declare a [[docker]] image build                       |
| `k8s_resource(...)`         | Configure/rename a resource, set port_forwards, labels |
| `port_forward(h, c, label)` | Named port-forward spec for `k8s_resource`             |
| `local_resource(...)`       | Declare a local command as a Tilt resource             |
| `blob(str)`                 | Wrap a string as Blob (data, not file path)            |
