---
title: "From Skaffold to Tilt: Comparison and Migration"
tags: [tilt, skaffold, migration]
sources: [tilt-skaffold]
updated: 2026-07-01
---

# From Skaffold to Tilt: Comparison and Migration

Source: [Tilt docs — From Skaffold to Tilt](https://docs.tilt.dev/skaffold.html)

## Why Switch

Tilt positions itself as an upgrade to [[skaffold]] for local Kubernetes development. Two headline differences:

- **UI**: Tilt's terminal UI shows all service statuses at a glance; errors cannot scroll off-screen. You can drill into logs for a single service or view the global firehose.
- **Configuration language**: Tilt uses [[starlark]] (a Python subset) instead of YAML. Simple configs stay short; complex configs become expressible without workarounds.

## Concept Mapping

Skaffold concepts map almost directly onto Tilt:

| Skaffold concept              | Tilt equivalent                                    |
| ----------------------------- | -------------------------------------------------- |
| `build.artifacts[].image`     | `docker_build('<image>', '<context>')` in Tiltfile |
| `build.artifacts[].context`   | second arg to `docker_build`                       |
| `deploy.kubectl.manifests[]`  | `k8s_yaml([...])` in Tiltfile                      |
| `skaffold.yaml` (YAML config) | `Tiltfile` ([[tiltfile]], Starlark)                |

## Migration Example

A two-service Skaffold config:

```yaml
apiVersion: skaffold/v1alpha5
kind: Config
build:
  artifacts:
    - image: gcr.io/windmill-public-containers/servantes/snack
      context: snack
    - image: gcr.io/windmill-public-containers/servantes/spoonerisms
      context: spoonerisms
deploy:
  kubectl:
    manifests:
      - deployments/snack.yaml
      - deployments/spoonerisms.yaml
```

Becomes this [[tiltfile]]:

```python
k8s_yaml(['deployments/snack.yaml', 'deployments/spoonerisms.yaml'])
docker_build('gcr.io/windmill-public-containers/servantes/snack', 'snack')
docker_build('gcr.io/windmill-public-containers/servantes/spoonerisms', 'spoonerisms')
```

Key observations:

- `k8s_yaml()` replaces `deploy.kubectl.manifests` — takes a list of [[kubernetes]] manifest paths.
- `docker_build('<image>', '<context>')` replaces each `build.artifacts` entry — image name first, build context second.
- No explicit `apiVersion` or `kind` needed; the [[tiltfile]] is executable [[starlark]], not declarative YAML.

## Next Steps After Migration

After translating the base config, the Tilt docs point to the _Write a Tiltfile Guide_ for further customisation: live-update rules, resource dependencies, port-forwards, and more — all expressed in [[starlark]].
