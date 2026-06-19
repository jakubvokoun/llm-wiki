---
title: "Zarf Best Practice — Offline Live Demos"
tags: [zarf, airgap, demo, kubernetes]
sources: [zarf-airgap-demos.md]
updated: 2026-04-23
---

# Zarf Best Practice — Offline Live Demos

How to run fully offline Kubernetes demos using Zarf — no Wi-Fi required on stage.

## Key Idea

Build a self-contained `.tar.zst` package on a connected machine before the event. On stage, disable networking and deploy using only the local file. Zarf's internal in-cluster registry serves images; Helm charts are vendored into the package.

## Three-Phase Workflow

### Phase 1 (Connected): Create

```bash
zarf package create .   # downloads charts + images; produces .tar.zst
```

- Explicitly list every image in the `images:` block — Zarf does not auto-discover from OCI charts.
- Pin `version:` fields to exact tested values for reproducibility.
- Pass `-a/--architecture` if building on a different arch than the demo machine.
- Inspect contents: `zarf package inspect definition <pkg>.tar.zst`

Add a `zarf.dev/connect-name` label to a Service to enable `zarf connect <name>` port-forwarding later:

```yaml
metadata:
  labels:
    zarf.dev/connect-name: podinfo-demo
  annotations:
    zarf.dev/connect-description: "The podinfo UI service"
```

### Phase 2 (Once Per Cluster): Init

```bash
zarf tools download-init && zarf init --confirm
```

Run once after cluster creation. Skip on subsequent demos with the same persistent cluster.

### Phase 3 (Disconnected): Deploy

```bash
# Turn Wi-Fi off, then:
zarf package deploy ./zarf-package-<name>-amd64-1.0.0.tar.zst --confirm
zarf connect podinfo-demo --local-port 9898
```

## Offline Readiness Checklist

- `zarf package create` succeeds on a connected build machine
- `zarf package inspect` lists expected images and charts
- Package file copied to demo machine (USB / internal network)
- Demo cluster running and `zarf init --confirm` already completed
- Optional: test full deploy with Wi-Fi off before the talk

## Reuse

- Publish the package to `ghcr.io` or a local network registry for workshop distribution.
- Add more components to the same `zarf.yaml` to build a multi-app demo in a single file.

## See Also

- [Zarf](../entities/zarf.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [Tutorial 0 — Creating a Package](zarf-creating-package.md)
- [Tutorial 1 — Initializing a Cluster](zarf-initializing-k8s-cluster.md)
- [Tutorial 2 — Deploying Packages](zarf-deploying-packages.md)
