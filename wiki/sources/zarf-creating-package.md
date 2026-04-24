---
title: "Zarf Tutorial 0 — Creating a Zarf Package"
tags: [zarf, airgap, kubernetes, deployment, supply-chain]
sources: [zarf-creating-package.md]
updated: 2026-04-23
---

# Zarf Tutorial 0 — Creating a Zarf Package

Official Zarf tutorial walking through the creation of a self-contained airgap package for deploying WordPress via Helm. Requires an internet connection at build time; deployment is fully offline.

## zarf.yaml Structure

```yaml
kind: ZarfPackageConfig # package kind for standard packages

metadata:
  name: wordpress # unique, unchanging package identifier
  version: 26.0.0 # optional; track across releases
  description: |
    "..."

variables: # runtime configuration (optional)
  - name: WORDPRESS_USERNAME
    description: "..."
    default: zarf
    prompt: true
  - name: WORDPRESS_PASSWORD
    prompt: true
    sensitive: true # kept out of logs

components:
  - name: wordpress
    description: "..."
    required: true
    charts:
      - name: wordpress
        url: oci://registry-1.docker.io/bitnamicharts/wordpress
        version: 26.0.0
        namespace: wordpress
        valuesFiles:
          - wordpress-values.yaml
    images:
      - docker.io/bitnamilegacy/wordpress:6.8.2-debian-12-r4
      - docker.io/bitnamilegacy/mariadb:12.0.2-debian-12-r0
    manifests:
      - name: connect-services
        namespace: wordpress
        files:
          - connect-services.yaml
```

## Development Commands

| Command                           | Purpose                                            |
| --------------------------------- | -------------------------------------------------- |
| `zarf dev find-images`            | Discover all images referenced by charts/manifests |
| `zarf dev lint <dir>`             | Validate `zarf.yaml` against the schema            |
| `zarf package create .`           | Build the package (outputs `.tar.zst`)             |
| `zarf package create . --confirm` | Skip confirmation prompt                           |

## Variable Templating

Variables defined in the `variables` section are injected into chart values files, manifests, and inline files with `###ZARF_VAR_NAME###` syntax:

```yaml
# wordpress-values.yaml
wordpressUsername: ###ZARF_VAR_WORDPRESS_USERNAME###
wordpressPassword: ###ZARF_VAR_WORDPRESS_PASSWORD###
```

Values are prompted at deploy time (if `prompt: true`) or passed via `--set`.

## Sensitive Variables

- Mark with `sensitive: true` — Zarf redacts them from logs
- **Never** embed sensitive values in the package itself
- Be careful with `actions` and `files` that may expose them

## Namespace Best Practice

Always specify an explicit `namespace` for chart/manifest components. The Zarf Agent intentionally ignores resources in `default` and `kube-system` — resources in those namespaces won't be properly mutated for airgap operation.

## Zarf Connect Services

Kubernetes services labeled with `zarf.dev/connect-name` enable `zarf connect <name>` shortcuts after deployment:

```yaml
metadata:
  labels:
    zarf.dev/connect-name: wordpress-blog
  annotations:
    zarf.dev/connect-description: "The public facing WordPress blog site"
    zarf.dev/connect-url: "/wp-admin" # optional URL suffix
```

## Build Output

`zarf package create .` produces a tarball: `zarf-package-<name>-<arch>-<version>.tar.zst`

The package includes all images, Helm charts, manifests, and files bundled for offline deployment.

## See Also

- [Zarf](../entities/zarf.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [Kubernetes Security](../concepts/kubernetes-security.md)
