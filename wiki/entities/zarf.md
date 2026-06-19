---
title: "Zarf"
tags: [zarf, airgap, kubernetes, deployment, supply-chain, defense-unicorns]
sources:
  [
    zarf-creating-package.md,
    zarf-initializing-k8s-cluster.md,
    zarf-deploying-packages.md,
    zarf-retro-arcade.md,
    zarf-creating-k8s-cluster.md,
    zarf-package-signing.md,
    zarf-publish-and-deploy.md,
    zarf-custom-init-packages.md,
    zarf-resource-adoption.md,
    zarf-package-create-differential.md,
    zarf-schema-v1alpha1-package.md,
    zarf-airgap-demos.md,
    zarf-data-injections-migration.md,
    zarf-upgrading-zarf.md,
  ]
updated: 2026-04-23
---

# Zarf

Open-source tool by Defense Unicorns for packaging and deploying Kubernetes applications into airgapped (disconnected) environments. Bundles images, Helm charts, manifests, and config into self-contained `.tar.zst` archives that deploy without internet access.

## Core Workflow

```
[internet] zarf package create → .tar.zst
           ↓ (transfer via USB/S3/etc.)
[airgap]   zarf init → zarf package deploy
```

## Key Concepts

| Concept           | Description                                                   |
| ----------------- | ------------------------------------------------------------- |
| Zarf Package      | Self-contained tarball with all app dependencies              |
| `zarf.yaml`       | Package definition: kind, metadata, variables, components     |
| Components        | Unit of deployment: charts, manifests, images, files, actions |
| Zarf Init Package | Special package that bootstraps the Zarf infrastructure       |
| Zarf Agent        | Mutating webhook that rewrites image refs for airgap registry |
| Variables         | Runtime config injected via `###ZARF_VAR_NAME###` templates   |
| Connect Services  | K8s services exposing port-forwards via `zarf connect`        |

## Package Schema

`kind` values:

- `ZarfPackageConfig` — standard application package
- `ZarfInitConfig` — cluster bootstrapping package

Components support: `charts`, `manifests`, `images`, `files`, `actions`. `dataInjections` exists in v1alpha1 but is **deprecated** and removed in v1beta1 — migrate to OCI image volumes or init containers.

## Security Considerations

- **Supply chain**: packages bundled with pinned image digests + versions
- **Sensitive variables**: marked `sensitive: true`; redacted from logs; injected at deploy-time only
- **Namespace isolation**: Zarf Agent ignores `default`/`kube-system`; always use explicit namespaces
- **SBOM**: Zarf generates Software Bill of Materials for every package
- **Package signing**: supports signing and verification of packages

## Cluster Bootstrap

The init-package includes an optional `k3s` component that provisions a k3s cluster on bare Linux (requires true root). After init only root has cluster access; copy `/root/.kube/config` for normal users.

```bash
zarf init --components="k3s" --confirm   # provision k3s + bootstrap Zarf
zarf destroy --confirm                   # teardown cluster + Zarf
```

## Custom Init Packages

Build from the Zarf git repository to swap hardened/enterprise-vetted images or remove components:

```bash
git checkout vX.X.X
zarf package create . --set AGENT_IMAGE_TAG=vX.X.X
```

Use `--registry-override` or `zarf-config.toml` to pull from enterprise pull-through mirrors. The init package is a composed package — remove import entries from root `zarf.yaml` to slim it.

## Package Operations

```bash
zarf package deploy                                      # interactive selector
zarf package deploy oci://ghcr.io/org/pkg:tag --key=...  # OCI + cosign verify
zarf package publish <pkg>.tar.zst oci://<registry>      # publish to OCI registry
zarf package pull oci://<registry>/<pkg>                 # download from registry
zarf package list                                        # list installed packages
zarf package remove <name> --confirm                     # uninstall
zarf connect <service>                                   # port-forward + open browser
```

## Package Signing (Cosign)

```bash
zarf tools gen-key                  # generate cosign.key + cosign.pub
zarf package sign <pkg>.tar.zst \
  --signing-key cosign.key          # sign post-build
zarf package verify <pkg>.tar.zst \
  --key cosign.pub                  # standalone verify
zarf package deploy <pkg>.tar.zst \
  --key cosign.pub --verify --confirm  # deploy with enforced verification
```

## Development Commands

```bash
zarf dev find-images      # discover images from charts/manifests
zarf dev lint <dir>       # validate zarf.yaml schema
zarf package create .     # build package → .tar.zst
zarf package inspect      # inspect package contents + SBOM
```

## Upgrading

Keep the CLI binary and init package at the same version.

```bash
zarf tools download-init   # fetch matching init package
zarf init --confirm        # re-initialize cluster (reads zarf-state secret for existing config)
zarf tools update-creds    # update stored registry/git credentials post-init
```

## Offline Live Demos

Build the package on a connected machine → transfer file → disable networking → deploy on stage. See [Best Practice — Offline Live Demos](../sources/zarf-airgap-demos.md).

## See Also

- [Zarf Packages](../concepts/zarf-packages.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [Kubernetes Security](../concepts/kubernetes-security.md)
- [Tutorial 0 — Creating a Package](../sources/zarf-creating-package.md)
- [Tutorial 1 — Initializing a Cluster](../sources/zarf-initializing-k8s-cluster.md)
- [Tutorial 2 — Deploying Packages](../sources/zarf-deploying-packages.md)
- [Tutorial 3 — Retro Arcade (OCI deploy)](../sources/zarf-retro-arcade.md)
- [Tutorial 4 — Creating a K8s Cluster](../sources/zarf-creating-k8s-cluster.md)
- [Tutorial 5 — Package Signing](../sources/zarf-package-signing.md)
- [Tutorial 6 — Publish & Deploy with OCI](../sources/zarf-publish-and-deploy.md)
- [Tutorial 7 — Custom Init Packages](../sources/zarf-custom-init-packages.md)
- [Tutorial 8 — Resource Adoption](../sources/zarf-resource-adoption.md)
- [Tutorial 9 — Differential Packages](../sources/zarf-package-create-differential.md)
- [v1alpha1 Package Schema Reference](../sources/zarf-schema-v1alpha1-package.md)
- [Best Practice — Offline Live Demos](../sources/zarf-airgap-demos.md)
- [Best Practice — Data Injections Migration](../sources/zarf-data-injections-migration.md)
- [Best Practice — Upgrading Zarf](../sources/zarf-upgrading-zarf.md)
