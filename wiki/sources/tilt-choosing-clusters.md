---
title: "Choosing a Local Dev Cluster for Tilt"
tags: [tilt, kubernetes, local-dev, docker]
sources: [tilt-choosing-clusters]
updated: 2026-07-01
---

A guide from the [[tilt]] docs on selecting a local [[kubernetes]] cluster for development. The choice affects image-push speed, cluster fidelity, resource overhead, and CI compatibility.

## Cluster comparison

| Cluster                    | Level        | Platform                | Container runtime        | Local registry                            | Startup    | Reset                  | Notes                                                            |
| -------------------------- | ------------ | ----------------------- | ------------------------ | ----------------------------------------- | ---------- | ---------------------- | ---------------------------------------------------------------- |
| **Kind**                   | Beginner     | Any (runs in Docker)    | containerd               | Yes (via ctlptl)                          | ~20 s      | Fast                   | Tilt team's default recommendation; CI-friendly                  |
| **Docker Desktop**         | Beginner     | macOS / Windows         | docker-shim              | No (images available in-cluster directly) | Slow       | Hard (full reset only) | Easiest entry point on macOS; resource-heavy                     |
| **MicroK8s**               | Beginner     | Linux (Ubuntu best)     | containerd               | Yes (`microk8s.enable registry`)          | Fast       | Slow / error-prone     | Native Linux performance; Snap dependency limits portability     |
| **Minikube**               | Intermediate | Any                     | Pluggable (VM or Docker) | Yes (via ctlptl)                          | Medium     | Medium                 | Most configurable; VM mode drains resources when idle            |
| **k3d**                    | Intermediate | Any (runs in Docker)    | containerd (k3s)         | Yes (built-in, Tilt-aware)                | <5 s       | Fast                   | Fastest startup; least widespread adoption                       |
| **Rancher Desktop**        | Intermediate | macOS / Linux / Windows | containerd or dockerd    | No (out-of-box)                           | Fast (k3s) | —                      | Open-source Docker Desktop alternative; evolving rapidly         |
| **Remote** (EKS/AKS/GKE)   | Advanced     | Cloud                   | Any                      | Remote registry required                  | —          | DevOps team required   | Blocked by default; must call `allow_k8s_contexts()` in Tiltfile |
| **Custom local** (K3s/K0s) | Advanced     | Linux (home lab)        | Any                      | Manual setup                              | —          | —                      | Must `allow_k8s_contexts()` and configure registry discovery     |

## Key decision factors

**Image push speed** is the biggest day-to-day variable. Clusters with a built-in local registry (Kind + ctlptl, MicroK8s, k3d, Minikube + ctlptl) keep pushes fast and avoid registry auth setup. Docker Desktop sidesteps this entirely — built images are immediately in-cluster — but at higher resource cost.

**Container runtime** matters for parity with production. Most modern options use containerd (Kind, MicroK8s, k3d, Rancher Desktop). Docker Desktop's docker-shim is heavier and less representative of prod.

**Cluster fidelity vs. simplicity**: Minikube offers the most knobs (Kubernetes version, runtime, controllers) but can overwhelm newcomers. Kind hits a sweet spot of low overhead and reasonable fidelity. k3d is fastest but strips optional/legacy Kubernetes features.

**Platform constraints**: MicroK8s is Linux-native (Ubuntu preferred). Kind, k3d, Minikube, and Rancher Desktop work cross-platform.

## Remote clusters

Tilt blocks remote clusters by default to prevent accidental deploys. To opt in, add to your Tiltfile:

```python
allow_k8s_contexts('my-cluster-name')
```

For teams sharing many dev clusters, disable the guard and validate externally:

```python
allow_k8s_contexts(k8s_context())
local('./validate-dev-cluster.sh')
```

Remote clusters suit large teams with dedicated dev infrastructure. They enable shared services (e.g. a dev database) and powerful cloud instances, but require a remote image registry and per-developer namespace isolation. See [[tilt-local-vs-remote]] for a broader comparison.

## Custom local cluster registry discovery

Tilt supports three protocols for auto-discovering a local registry on custom clusters:

1. **Kubernetes standard** — a `ConfigMap` named `local-registry-hosting` in the `kube-public` namespace (KEP 1755).
2. **Legacy annotations** — `tilt.dev/registry` and `tilt.dev/registry-from-cluster` node annotations.
3. **Manual** — `default_registry('...')` in the Tiltfile, optionally driven by an env var.

## Tilt team recommendations

- **Beginners / macOS**: Kind (with ctlptl for the local registry) or Docker Desktop
- **Linux / Ubuntu**: MicroK8s
- **Speed priority**: k3d
- **High fidelity / flexibility**: Minikube
- **Remote**: only for large teams with dedicated dev-infra support

## Related

- [[tilt]] — the dev tool these clusters are used with
- [[kubernetes]] — the orchestration layer
- [[docker]] — runtime underpinning Kind, k3d, and Docker Desktop
- [[tilt-local-vs-remote]] — broader local vs. remote dev trade-offs
