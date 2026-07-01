---
title: "Using Helm with Tilt"
tags: [tilt, helm, kubernetes]
sources: [tilt-helm]
updated: 2026-07-01
---

# Using Helm with Tilt

Tilt supports Helm out of the box. Two primary workflows cover most teams:
installing existing off-the-shelf charts, and iterating on a chart you are
actively developing.

## Installing existing charts — `helm_resource`

Use the `helm_resource` extension for charts you are consuming but not modifying.

```python
# Tiltfile
load('ext://helm_resource', 'helm_resource', 'helm_repo')
helm_repo('bitnami', 'https://charts.bitnami.com/bitnami')
helm_resource('mysql', 'bitnami/mysql', resource_deps=['bitnami'])
```

Under the hood:

- `tilt up` runs `helm install` for the chart.
- After install, Tilt discovers the installed objects and tracks their logs,
  events, and health checks in the UI.

`helm_resource` supports additional flags for `helm install`, file-change
redeploys, and injecting locally built images. Find chart repos on
[Artifact Hub](https://artifacthub.io/).

**Best for:** operators, databases, and other third-party services you want
running in your dev cluster without needing to debug the install.

## Developing your own chart — `helm()` built-in

The built-in `helm()` function runs `helm template` on a local chart directory
and returns the rendered YAML blob, which you pass to `k8s_yaml()` for
deployment.

```python
k8s_yaml(helm('./charts/my-chart'))
```

Tilt watches the chart directory and re-deploys automatically on any file change.

### `helm()` options

```python
yaml = helm(
  'path/to/chart/dir',
  name='release-name',        # equivalent to helm --name
  namespace='my-namespace',   # equivalent to helm --namespace
  values=['./path/to/chart/dir/values-dev.yaml'],
  set=['service.port=1234', 'ingress.enabled=true'],
)
k8s_yaml(yaml)
```

**Best for:** charts you own — Tilt validates YAML, splits it into individual
resources, and auto-injects locally built images. See [[tilt-templating-yaml]]
for more on how Tilt handles YAML.

**Limitations:** `helm()` uses Tilt's deployment engine, so
[Helm chart hooks](https://helm.sh/docs/topics/charts_hooks/) are skipped. It
is offline-only; remote charts must be downloaded first.

## Remote charts via `helm_remote` extension

The `helm_remote` extension downloads a chart and renders it through `helm()`
locally:

```python
load('ext://helm_remote', 'helm_remote')
helm_remote('mysql',
            repo_name='bitnami',
            repo_url='https://charts.bitnami.com/bitnami')
```

## Sub-charts and dependencies

Run `helm dep update` outside Tilt to download chart dependencies. Then add a
`.tiltignore` to prevent Tilt from reloading every time Helm touches the
vendor directories:

```
**/charts
**/tmpcharts
```

Or scoped to a specific chart path:

```
path/to/your/chart/charts
path/to/your/chart/tmpcharts
```

## Advanced: plugin API recipes

For scenarios beyond `helm()`, use Tilt's plugin API — `local()` for shell
commands and `watch_file()` for change detection — to shell out to `helm`
directly. See [[tiltfile]] for how these functions integrate into the
[[tilt]] configuration model.

### Re-implementing `helm()` manually

```python
k8s_yaml(local('helm template path/to/chart/dir'))
watch_file('path/to/chart/dir')
```

### `--set` flags

```python
k8s_yaml(local('helm template --set key1=val1,key2=val2 path/to/chart/dir'))
watch_file('path/to/chart/dir')
```

### Values file

```python
k8s_yaml(local('helm template -f ./values.yaml path/to/chart/dir'))
watch_file('path/to/chart/dir')
watch_file('values.yaml')
```

### Helmfile integration

```python
def helmfile(file):
  watch_file(file)
  return local("helmfile -f %s template" % file)

k8s_yaml(helmfile("k8s/staging/helmfile.yaml"))
```

## Choosing an approach

| Scenario                        | Recommended approach                  |
| ------------------------------- | ------------------------------------- |
| Third-party chart, no edits     | `helm_resource` extension             |
| Own chart, local iteration      | `helm()` built-in + `k8s_yaml()`      |
| Remote chart, rendered locally  | `helm_remote` extension               |
| Hooks, cluster-aware installs   | `helm_resource` (full `helm install`) |
| Custom tooling (helmfile, etc.) | `local()` + `watch_file()` plugin API |

## References

- Source: [tilt.dev/helm](https://docs.tilt.dev/helm.html)
- Related: [[tilt]], [[tiltfile]], [[kubernetes]], [[tilt-templating-yaml]]
- Example repos:
  [tilt-helm-demo](https://github.com/tilt-dev/tilt-helm-demo),
  [tilt-helmfile-demo](https://github.com/tilt-dev/tilt-helmfile-demo)
