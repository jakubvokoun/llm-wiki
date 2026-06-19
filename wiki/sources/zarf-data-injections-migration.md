---
title: "Zarf Best Practice — Migrating Away from Data Injections"
tags: [zarf, airgap, kubernetes, deprecation, oci]
sources: [zarf-data-injections-migration.md]
updated: 2026-04-23
---

# Zarf Best Practice — Migrating Away from Data Injections

`dataInjections` is deprecated in the v1alpha1 schema and will not exist in v1beta1. This guide covers the two replacement patterns.

## Why Deprecated

| Problem             | Detail                                                      |
| ------------------- | ----------------------------------------------------------- |
| Poor UX             | Confusing adoption path for users                           |
| Host dependency     | Shells out to `tar`; brittle across environments            |
| Ephemeral storage   | Data is lost on pod restart unless written to a PVC         |
| Better alternatives | OCI images are a K8s-native solution that fits Zarf's model |

## Migration Overview

1. Package your data as an OCI image (both approaches share this step).
2. Add the image to the `images:` list in `zarf.yaml` (removes `dataInjections:` block).
3. Update the pod spec to consume the image — either as an OCI volume or via an init container.

## Step 1: Package Data as OCI Image

```dockerfile
# For read-only OCI volumes: FROM scratch is sufficient (no shell needed)
FROM alpine:3.18
COPY your-data-file /your-data/your-data-file
```

```bash
docker build -t your-registry/your-data:tag .
docker push your-registry/your-data:tag
```

## Step 2: Update zarf.yaml

```yaml
# Before (deprecated)
dataInjections:
  - source: my-folder
    target:
      namespace: my-app
      selector: app=my-app
      container: data-loader
      path: /data
    compress: true

# After: just list the image; no dataInjections block
images:
  - ghcr.io/my-app:1.0.0
  - your-registry/your-data:tag
```

## Step 3A: OCI Volume Source (Preferred — K8s 1.35+, Zarf v0.70.0+)

```yaml
volumes:
  - name: data
    image:
      reference: your-registry/your-data:tag
containers:
  - name: my-app
    volumeMounts:
      - name: data
        mountPath: /mount-path
```

Data is mounted directly; no copy step. Pod restart re-mounts from the image.

## Step 3B: Init Container (Fallback — Any K8s Version)

```yaml
initContainers:
  - name: data-loader
    image: your-registry/your-data:tag
    command: ["sh", "-c"]
    args:
      - cp /your-data/your-data-file /data/my-app-data-location
    volumeMounts:
      - mountPath: /data
        name: data
volumes:
  - name: data
    emptyDir: {} # data repopulated on each pod restart from the init container
```

## See Also

- [Zarf](../entities/zarf.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [v1alpha1 Package Schema Reference](zarf-schema-v1alpha1-package.md)
