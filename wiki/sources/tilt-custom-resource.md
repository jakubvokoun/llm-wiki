---
title: "Managing Kubernetes Custom Resources in Tilt"
tags: [tilt, kubernetes, crd]
sources: [tilt-custom-resource]
updated: 2026-07-01
---

# Managing Kubernetes Custom Resources in Tilt

[[tilt]] understands built-in Kubernetes primitives (Deployments, Jobs, StatefulSets) out of the
box. For custom resource definitions (CRDs) — whether your own or from operators like KubeDB — you
need to give Tilt a small amount of guidance in your [[tiltfile]].

## Three things Tilt needs to know

### 1. Is the resource independent?

By default, all unrecognized CRDs land in a single "uncategorized" bucket. Use `k8s_resource` to
give a CRD object its own named pane with separate logs and status:

```python
k8s_resource(new_name='my-postgres-server', objects=['postgres-name'])
```

### 2. Does it contain images?

Use `k8s_kind` with an `image_json_path` (JSONPath expression) so Tilt can find and inject the
image reference into the custom resource:

```python
k8s_kind('UselessMachine', image_json_path='{.spec.image}')
```

The path can point to any field in the spec — it does not have to be a conventional `image` field.

### 3. Does it create pods?

Tilt follows owner references automatically in most cases. When it cannot, set `pod_readiness`
explicitly on `k8s_kind`:

| Value      | Meaning                                                |
| ---------- | ------------------------------------------------------ |
| `'wait'`   | Resource has pods; Tilt waits for them to become ready |
| `'ignore'` | Resource has no pods; healthy when no pods appear      |

```python
k8s_kind('UselessMachine', image_json_path='{.spec.image}', pod_readiness='wait')
k8s_kind('UselessMachine', image_json_path='{.spec.image}', pod_readiness='ignore')
```

If owner references are absent, supply a label selector per resource:

```python
k8s_resource(new_name='postgres',
             extra_pod_selectors=[{'kubedb.com/name': 'quick-postgres'}])
```

Once name, image location, and pod selector are configured, the CRD behaves like any built-in: Tilt
fetches logs and wires up port-forwards automatically.

## Installing CRD operators

[[kubernetes]] operators must be present in the cluster before their CRDs can be applied. Three
patterns for bootstrapping them inside Tilt:

### `local()` / `local_resource()`

`local()` runs a shell script synchronously on every [[tiltfile]] reload — simple but blocking:

```python
local('./install-my-crd-operator.sh')
```

For parallelism, use `local_resource` with `allow_parallel=True`, then declare dependencies with
`resource_deps` so downstream resources wait:

```python
local_resource(
  name='my-crd-operator',
  cmd='./install-my-crd-operator.sh',
  allow_parallel=True)

k8s_resource(name='custom-resource', resource_deps=['my-crd-operator'])
```

### `k8s_custom_deploy()`

For full health-monitoring and log visibility, use `k8s_custom_deploy`. The `apply_cmd` script must
print the resulting YAML to stdout so Tilt can track created objects:

```python
k8s_custom_deploy(
  name='my-crd-operator',
  apply_cmd='./install-my-crd-operator.sh',
  delete_cmd='./teardown-my-crd-operator.sh')
```

See the [Knative extension](https://github.com/tilt-dev/tilt-extensions/blob/master/knative/Tiltfile)
for a real-world example.

## Advanced: second-order pod image injection

Some frameworks spawn pods that themselves create further pods. Two strategies for injecting images
into these second-order pods:

### Custom resource injection

Point `image_json_path` at any field, including non-standard ones:

```python
k8s_kind('UselessMachine', image_json_path='{.spec.imageToDeploy}')
```

### Environment variable injection

Add an env var in the container spec with the image name as value:

```yaml
env:
  - name: IMAGE_TO_DEPLOY
    value: my-image
```

Then tell `docker_build` to match env vars:

```python
docker_build('my-image', '.', match_in_env_vars=True)
```

Tilt replaces the plain tag with the content-addressed reference it built. The framework reads the
env var and spawns pods using the precise digest. Used by the Airflow example with
`KubernetesPodOperator`.

## Reference examples

| Project                | Technique demonstrated                                                      |
| ---------------------- | --------------------------------------------------------------------------- |
| KubeDB Postgres        | `extra_pod_selectors` for operator-managed pods                             |
| ElasticSearch + Kibana | Multi-resource CRD setup                                                    |
| Airflow                | `match_in_env_vars` image injection (no CRD)                                |
| Prometheus             | `resource_deps` + pod selectors for ordered CRD install                     |
| Knative                | `k8s_custom_deploy` + extension helpers (`knative_install`, `knative_yaml`) |
