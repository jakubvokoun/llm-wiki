---
title: "Zarf Tutorial 2 — Deploying Zarf Packages"
tags: [zarf, kubernetes, deploy, airgap]
sources: [zarf-deploying-packages.md]
updated: 2026-04-23
---

# Zarf Tutorial 2 — Deploying Zarf Packages

Official Zarf tutorial covering `zarf package deploy`: deploying a built package (WordPress) to an initialized cluster.

## Key Takeaways

- `zarf package deploy` without a path argument opens interactive selector (tab to navigate)
- Zarf displays package SBOMs and definition before deployment for review
- Variables are prompted interactively at deploy time (press Enter for defaults)
- `zarf connect <service>` sets up port-forwarding and opens browser
- `zarf package list` shows all installed packages; `zarf package remove <name> --confirm` uninstalls
- `zarf package inspect` shows SBOM details without deploying

## Commands

```bash
zarf package deploy                            # interactive selector
zarf package deploy <file>.tar.zst --confirm  # non-interactive
zarf connect wordpress                         # port-forward + open browser
zarf package list                             # list installed packages
zarf package remove wordpress --confirm       # uninstall
zarf package inspect <file>.tar.zst           # view SBOM + definition
```

## Troubleshooting

| Error                          | Cause                   | Fix                     |
| ------------------------------ | ----------------------- | ----------------------- |
| Unable to connect to cluster   | kubectl misconfigured   | Fix kubeconfig; re-init |
| Secrets "zarf-state" not found | Cluster not initialized | Run `zarf init` first   |

## See Also

- [Zarf](../entities/zarf.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [Zarf Tutorial 1 — Initializing a K8s Cluster](zarf-initializing-k8s-cluster.md)
