---
title: "Zarf v1alpha1 Package Schema Reference"
tags: [zarf, schema, yaml, kubernetes, airgap]
sources: [zarf-schema-v1alpha1-package.md]
updated: 2026-04-23
---

# Zarf v1alpha1 Package Schema Reference

Source: [docs.zarf.dev](https://docs.zarf.dev/schema/v1alpha1-package/)

## Summary

Complete field reference for `zarf.yaml`. The `ZarfPackage` root element requires at least one
component; all other top-level fields are optional.

## Top-level structure

```yaml
apiVersion: zarf.dev/v1alpha1
kind: ZarfPackageConfig # or ZarfInitConfig
metadata: ...
variables: [...]
constants: [...]
components: [...] # required, min 1
```

## ZarfMetadata

| Field                    | Required | Notes                                                      |
| ------------------------ | -------- | ---------------------------------------------------------- |
| `name`                   | yes      | Lowercase alphanumeric package identifier                  |
| `version`                | no       | Author-defined; required for OCI publishing                |
| `architecture`           | no       | `arm64`, `amd64`                                           |
| `description`            | no       | Human-readable summary                                     |
| `annotations`            | no       | OCI image-spec compliant custom metadata                   |
| `yolo`                   | no       | Deploy without cluster initialization (connected env only) |
| `allowNamespaceOverride` | no       | Allow namespace customization at deploy time               |
| `uncompressed`           | no       | Toggle tarball compression                                 |

## ZarfComponent

| Field          | Notes                                                  |
| -------------- | ------------------------------------------------------ |
| `name`         | Required; component identifier                         |
| `required`     | Mandatory installation (cannot be deselected)          |
| `default`      | Pre-selected in interactive mode                       |
| `charts`       | Helm chart deployments                                 |
| `manifests`    | Raw Kubernetes YAML deployed via Helm wrapper          |
| `images`       | Container images to bundle                             |
| `repos`        | Git repositories to bundle                             |
| `files`        | Arbitrary filesystem artifacts                         |
| `only`         | Deployment filter conditions (OS, cluster arch, etc.)  |
| `actions`      | Lifecycle command hooks (onCreate, onDeploy, onRemove) |
| `healthChecks` | Post-deploy resource readiness validation              |

## Variables vs Constants

**InteractiveVariable** (`variables[].`): prompted at deploy time

```yaml
variables:
  - name: DB_PASSWORD # uppercase alphanumeric
    prompt: true
    sensitive: true # redacted from logs
    default: "changeme"
    pattern: "^[a-z0-9]+$" # regex validation
    type: raw # or "file"
```

**Constant** (`constants[].`): static values baked in at build time

```yaml
constants:
  - name: APP_VERSION
    value: "1.2.3"
    autoIndent: true # multiline YAML support
```

Template syntax: `###ZARF_VAR_DB_PASSWORD###` / `###ZARF_CONST_APP_VERSION###`

## ZarfChart

```yaml
charts:
  - name: my-chart # Zarf chart identifier
    url: https://charts.example.com
    version: 1.0.0
    releaseName: my-release
    namespace: my-namespace
    valuesFiles: [values.yaml]
    serverSideApply: auto # "true" | "false" | "auto"
```

## ZarfManifest

```yaml
manifests:
  - name: my-manifests
    namespace: my-namespace
    files: [deploy.yaml, service.yaml]
    kustomizations: [./kustomize]
    template: true # enable Go-template processing
```

## ZarfFile

```yaml
files:
  - source: ./scripts/setup.sh # local path or remote URL
    target: /opt/app/setup.sh
    executable: true
    shasum: sha256:abc123
    extractPath: ./inner/file # for archives
    template: true
```

## ZarfComponentAction

```yaml
actions:
  onDeploy:
    before:
      - cmd: echo "deploying"
        description: "Pre-deploy hook"
        maxRetries: 3
        maxTotalSeconds: 60
        shell:
          windows: pwsh
          linux: bash
        setValues:
          - name: MY_VAR
```

## ZarfBuildData (auto-generated)

Recorded by Zarf at package creation:
`version`, `timestamp`, `architecture`, `user`, `terminal`, `differential`, `signed`,
`versionRequirements`

## Related

- [Zarf Packages](../concepts/zarf-packages.md)
- [Zarf](../entities/zarf.md)
- [Tutorial 0 — Creating a Package](zarf-creating-package.md)
- [Tutorial 9 — Differential Packages](zarf-package-create-differential.md)
