---
title: "Tiltfile Snippets Reference"
tags: [tilt, tiltfile, kubernetes, docker]
sources: [tilt-snippets]
updated: 2026-07-01
---

A curated collection of ready-to-use [[tiltfile]] recipes from the official [[tilt]] docs. Each snippet covers a common workflow pattern with the key function names preserved for quick lookup.

## Image Building

### `docker_build()`

| Snippet                                               | What it does                                                                |
| ----------------------------------------------------- | --------------------------------------------------------------------------- |
| `docker_build("img", "dir")`                          | Build a [[docker]] image from a directory (equivalent to `docker build -t`) |
| `docker_build("img", "dir", dockerfile_contents=...)` | Build from an inline Dockerfile string instead of a file on disk            |

```python
# Inline Dockerfile example
dockerfile = """
FROM nginx:latest
COPY . /usr/share/nginx/html
"""
docker_build("companyname/assets", "./assets", dockerfile_contents=dockerfile)
```

Add `live_update=[sync("./src", "/app")]` to enable [[tilt-live-update]] without a full rebuild.

## Kubernetes Deployment

### `k8s_yaml()` — Load manifests

```python
k8s_yaml('k8s/app.yaml')                                    # single file
k8s_yaml(['k8s/secrets.yaml', 'k8s/configmaps.yaml'])       # list of files
k8s_yaml(kustomize('kustomize_dir'))                         # Kustomize output
k8s_yaml(helm('chart_dir'))                                  # Helm chart output
k8s_yaml(local('./foo.py'))                                  # custom command output
```

All forms feed YAML into the [[kubernetes]] cluster.

### `k8s_resource()` — Configure resources

```python
# Port-forward
k8s_resource(workload='frontend', port_forwards=9000)

# Associate objects (secrets, volumes)
k8s_resource(workload='frontend', objects=['frontend:secret', 'frontend:volume'])

# Group objects into a named resource and declare dependencies
k8s_resource(objects=['my-ns:namespace', 'kafka:crd'], new_name='cluster-setup')
k8s_resource('myapp', resource_deps=['cluster-setup'])
```

### `k8s_custom_deploy()` — Inject into unmanaged deployments

For deploying into resources not managed by Tilt (e.g. shared clusters). Pair with `docker_build()` for [[tilt-live-update]]:

```python
docker_build("myappimage", "myapp", live_update=[sync("./myapp", "/app")])
k8s_custom_deploy(
    "myapp",
    apply_cmd="kubectl set image deployment/myapp *=$TILT_IMAGE_0 > /dev/null && kubectl get deployment/myapp -o yaml",
    delete_cmd="echo Myapp managed outside of Tilt",
    image_deps=["myappimage"],
)
```

## Extensions

Load [[tilt-extensions]] with `load('ext://<name>', ...)`.

### `deployment` extension — zero-YAML deploy

```python
load('ext://deployment', 'deployment_create')
docker_build('myapp', './myapp', live_update=[sync('./myapp', '/app')])
deployment_create('myapp')

# Or with extra options
deployment_create('redis', ports='6379', readiness_probe={'exec': {'command': ['redis-cli', 'ping']}})
```

### `secret` extension

```python
load('ext://secret', 'secret_create_generic', 'secret_from_dict')
secret_create_generic('pgpass', from_file='.pgpass=./.pgpass')
k8s_yaml(secret_from_dict("secrets", inputs={'SOME_TOKEN': os.getenv('SOME_TOKEN')}))
```

### `configmap` extension

```python
load('ext://configmap', 'configmap_create')
configmap_create('grafana-config', from_file=['grafana.ini=./grafana.ini'])
k8s_yaml(configmap_from_dict('app-env', inputs={'HOST': '0.0.0.0', 'PORT': '5000'}))
```

### `min_k8s_version` / `max_k8s_version` extension

```python
load("ext://min_k8s_version", "min_k8s_version", "max_k8s_version")
min_k8s_version("1.18.3")
max_k8s_version("1.22.0")
```

## Docker Compose

```python
docker_compose('./docker-compose.yml')

# With inline overrides
services = {'app': {'environment': {'DEBUG': 'true'}}}
docker_compose(['docker-compose.yml', encode_yaml({'services': services})])
```

See [[docker]] for Compose file format.

## Local Resources

`local_resource()` runs commands on the host machine, not in a container.

| Pattern                     | Snippet                                                                                                           |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Re-run on dependency change | `local_resource('yarn', cmd='yarn install', deps=['package.json'])`                                               |
| Build + serve (go)          | `local_resource('srv', cmd='go build ./cmd/myserver', serve_cmd='./myserver --port=8001', deps=['cmd/myserver'])` |
| Install + serve (node)      | `local_resource('js', cmd='yarn install', serve_cmd='yarn start', deps=['package.json'])`                         |
| Tail K8s API server logs    | `local_resource('kube-logs', serve_cmd='kubectl logs -f -n kube-system <pod>')`                                   |
| socat tunnel to remote DB   | `local_resource('socat', serve_cmd='socat TCP-LISTEN:3306,...')`                                                  |
| Manual Makefile task        | `local_resource('task', cmd='make mytask', trigger_mode=TRIGGER_MODE_MANUAL, auto_init=False)`                    |

### `require_tool()` — gate on installed CLI tools

A helper pattern (not built-in) to abort Tiltfile load when a required binary is missing:

```python
def require_tool(tool, msg=None):
    tool = shlex.quote(tool)
    if not msg:
        msg = '%s is required but was not found in PATH' % tool
    local(command='command -v %s >/dev/null 2>&1 || { echo >&2 "%s"; exit 1; }' % (tool, msg), quiet=True)

require_tool("helm")
```

## Update / Trigger Control

All resource types (`k8s_resource`, `local_resource`, `dc_resource`) accept `auto_init` and `trigger_mode`:

| Mode                       | `auto_init` | `trigger_mode`        | Behaviour                                                    |
| -------------------------- | ----------- | --------------------- | ------------------------------------------------------------ |
| Full manual                | `False`     | `TRIGGER_MODE_MANUAL` | Only starts/updates when triggered via UI                    |
| Start once, ignore changes | `True`      | `TRIGGER_MODE_MANUAL` | Starts automatically; updates only on manual trigger         |
| Wait for first file change | `False`     | `TRIGGER_MODE_AUTO`   | Skips initial launch; starts after first watched-file change |

```python
k8s_resource("my-resource", auto_init=False, trigger_mode=TRIGGER_MODE_MANUAL)
```

## Miscellaneous

### Version constraints

```python
version_settings(check_updates=True, constraint='>=0.23.7')   # minimum Tilt version
```

### Per-developer local overrides

```python
# add local.tiltfile to .gitignore
if os.path.exists('local.tiltfile'):
    load_dynamic('local.tiltfile')
```

### Handle `tilt down`

```python
if config.tilt_subcommand == 'down':
    print('Goodbye world!')
```
