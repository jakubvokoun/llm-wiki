---
title: "Zarf Packages"
tags: [zarf, airgap, kubernetes, supply-chain, packaging]
sources:
  [
    zarf-creating-package.md,
    zarf-deploying-packages.md,
    zarf-retro-arcade.md,
    zarf-package-signing.md,
    zarf-publish-and-deploy.md,
    zarf-package-create-differential.md,
    zarf-schema-v1alpha1-package.md,
    zarf-data-injections-migration.md,
    zarf-airgap-demos.md,
  ]
updated: 2026-04-23
---

# Zarf Packages

Self-contained `.tar.zst` archives that bundle everything needed to deploy a Kubernetes application in an airgapped (offline) environment: container images, Helm charts, manifests, files, and runtime configuration.

## Package Contents

| Resource type      | Description                                                                                       |
| ------------------ | ------------------------------------------------------------------------------------------------- |
| Container images   | Pre-pulled; re-served from Zarf's internal registry                                               |
| Helm charts        | Templated at deploy time with Zarf variables                                                      |
| K8s manifests      | Raw YAML files applied to the cluster                                                             |
| Files              | Arbitrary files placed on nodes or in containers                                                  |
| Actions            | Shell commands run before/after component deploy                                                  |
| ~~dataInjections~~ | **Deprecated** in v1alpha1; removed in v1beta1; replace with OCI image volumes or init containers |

## Package Lifecycle

```
create              → bundle all dependencies (needs internet)
create --differential → bundle only what changed vs reference package
sign                → sign the tarball with cosign.key (optional)
transfer            → USB/S3/SCP to airgap boundary
init                → bootstrap Zarf in the cluster (one-time)
deploy              → deploy components from the tarball (verify sig if --key provided)
deploy --adopt-existing-resources → take over pre-existing K8s workloads
remove              → zarf package remove <name> --confirm
```

## OCI Registry Deployment

Packages can be published to any OCI Distribution Spec-compatible registry and then deployed directly without a local download. `metadata.version` must be set in `zarf.yaml` before publishing; HTTP-only registries require `--plain-http`.

```bash
zarf package publish <pkg>.tar.zst oci://<registry>  # upload to registry
zarf package inspect oci://<registry>/<pkg>           # examine remote package
zarf package deploy oci://<registry>/<pkg>            # deploy from registry
zarf package pull oci://<registry>/<pkg>              # download for reuse
```

The `--key` flag verifies the Cosign signature before any deployment happens:

```bash
zarf package deploy oci://ghcr.io/zarf-dev/packages/dos-games:1.3.0 \
  --key=https://zarf.dev/cosign.pub
```

## Package Signing

Zarf uses [Cosign](https://github.com/sigstore/cosign) for package signing. `zarf tools gen-key` wraps Cosign key generation.

```bash
zarf tools gen-key                      # → cosign.key (private) + cosign.pub (public)
zarf package sign <pkg>.tar.zst \
  --signing-key cosign.key             # sign after build
zarf package verify <pkg>.tar.zst \
  --key cosign.pub                     # verify standalone
zarf package deploy <pkg>.tar.zst \
  --key cosign.pub --verify --confirm  # enforce sig at deploy time
```

`--verify` on deploy causes an immediate abort if the signature check fails — prevents deploying tampered packages.

## `zarf.yaml` Keys

```yaml
kind: ZarfPackageConfig
metadata:
  name: <string>
  version: <semver>
variables:
  - name: MY_VAR
    prompt: true
    sensitive: false
    default: "value"
components:
  - name: <string>
    required: <bool>
    charts: [...]
    manifests: [...]
    images: [...]
    files: [...]
    actions: [...]
```

## Variable Templating

Zarf replaces `###ZARF_VAR_NAME###` tokens in chart value files, manifests, and inline files at deploy time.

```yaml
# In values file
dbPassword: ###ZARF_VAR_DB_PASSWORD###
```

`sensitive: true` variables are redacted from all Zarf log output.

## Image Discovery

`zarf dev find-images` templates out referenced Helm charts and manifests to extract all image references — essential for building complete airgap bundles.

## Zarf Agent

A mutating admission webhook deployed in the cluster that rewrites image references from their public registry origins to Zarf's internal registry. Intentionally ignores `default` and `kube-system` namespaces — use explicit namespaces in all components.

## SBOM

Every Zarf package automatically includes a Software Bill of Materials (SBOM) listing all container images and their layers. View with `zarf package inspect`.

## Security Properties

- Pinned versions at build time; not resolved at deploy time
- Package signing + verification prevents tampering
- Sensitive variables never stored in the package tarball
- SBOM enables vulnerability auditing offline

## See Also

- [Zarf](../entities/zarf.md)
- [Supply Chain Security](supply-chain-security.md)
- [Kubernetes Security](kubernetes-security.md)
- [Container Security](container-security.md)
- [Tutorial 2 — Deploying Packages](../sources/zarf-deploying-packages.md)
- [Tutorial 3 — Retro Arcade (OCI deploy)](../sources/zarf-retro-arcade.md)
- [Tutorial 5 — Package Signing](../sources/zarf-package-signing.md)
- [Tutorial 6 — Publish & Deploy with OCI](../sources/zarf-publish-and-deploy.md)
- [Tutorial 8 — Resource Adoption](../sources/zarf-resource-adoption.md)
- [Tutorial 9 — Differential Packages](../sources/zarf-package-create-differential.md)
- [v1alpha1 Package Schema Reference](../sources/zarf-schema-v1alpha1-package.md)
- [Best Practice — Data Injections Migration](../sources/zarf-data-injections-migration.md)
- [Best Practice — Offline Live Demos](../sources/zarf-airgap-demos.md)
- [Analysis — Using Tilt with Zarf / Helm Kubernetes Deployments](../analyses/tilt-with-zarf-helm-deployments.md)
