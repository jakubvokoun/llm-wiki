---
title: "Tilt: Local vs Remote Service Architectures"
tags: [tilt, kubernetes, developer-experience, devops]
sources: [tilt-local-vs-remote]
updated: 2026-07-01
---

# Tilt: Local vs Remote Service Architectures

[[tilt]] is agnostic about where your services run — local or remote clusters both support live-update. The choice of architecture affects iteration speed, data access, cluster maintenance burden, and team tooling requirements.

## The Three Architectures

### All Local

Every service runs in a local [[kubernetes]] cluster (e.g. Kind, k3d, Minikube — see [[tilt-choosing-clusters]]).

**When it fits:**

- Teams that want full reset capability ("blow it away and start fresh")
- Services with no special CPU, GPU, or data requirements
- Dev environments that need to be hermetic and reproducible

**Tilt support:** `local_resource` lets local processes (e.g. a natively-run database) interoperate with services running inside the local cluster.

---

### Hybrid (most common)

A mix of where services live, typically:

| Layer                                                       | Where it runs                  |
| ----------------------------------------------------------- | ------------------------------ |
| Hosted/shared services (databases, message queues)          | Remote / cloud-managed         |
| Pre-built dependencies (installed from image or Helm chart) | Local cluster                  |
| Services under active development                           | Local cluster with live-update |

**When it fits:**

- Services with CPU or data requirements that exceed a laptop (keep those remote)
- Services that need hermetic reset capability (keep those local)
- Teams that want flexibility without full remote cluster overhead

This is Tilt's recommended default for most teams.

---

### All Remote

Every service runs in a shared remote dev cluster.

**Prerequisite questions — answer yes to at least one before going all-remote:**

1. **CPU-bound:** Services require GPU or hardware unavailable on a laptop
2. **Data-bound:** Dev data cannot be pulled locally (volume, security, compliance)
3. **Cluster-bound:** Services must be colocated with a hosted dependency, or testing across cluster types is required

**Operational caveat:** A remote dev cluster requires a DevOps team to configure, maintain, and support. Tilt does not recommend all-remote without that capacity. Even when one bottleneck justifies remote placement, a hybrid approach (only that service remote, others local) is worth considering first.

---

## Enhancements for Remote Workflows

Once services run remotely, two common enhancements become relevant.

### Remote Builds

Build images inside [[kubernetes]] rather than on the developer's machine, using Kaniko or Docker BuildX. Tilt's `custom_build` supports this:

```python
custom_build(
  'gcr.io/tilt/image-name',
  'docker buildx build --platform=linux/amd64 -t $EXPECTED_REF --push .',
  ['./'],
  skips_local_docker=True,
  disable_push=True,
)
```

**Known friction points:**

- Configuring build jobs in the cluster
- Routing between build jobs and the image registry
- Effective layer caching
- Sending only changed context (diff uploads), not full re-uploads each time

Remote builds are worth pursuing for CPU-constrained laptops or large images, but teams frequently find them harder to stabilize than expected.

### Local/Remote Networking

Software-defined networking tools bridge local and remote clusters, enabling traffic to flow between them:

| Tool                   | Mechanism                                                             |
| ---------------------- | --------------------------------------------------------------------- |
| **Istio multicluster** | Service mesh routing across clusters                                  |
| **Inlets**             | Public load balancer proxying traffic into a local cluster            |
| **Telepresence**       | Replaces a remote service with a proxy that routes to a local process |

These tools complement Tilt — use them to connect other clusters to the cluster Tilt is targeting.

---

## Decision Summary

| Constraint                            | Recommended architecture                                                  |
| ------------------------------------- | ------------------------------------------------------------------------- |
| No special requirements               | All local                                                                 |
| Mixed requirements                    | Hybrid (default recommendation)                                           |
| CPU/GPU/data/cluster constraints      | Hybrid with constrained service remote, or all-remote with DevOps support |
| Shared remote cluster, no DevOps team | Avoid — maintenance cost is high                                          |

## Related Pages

- [[tilt]] — overview of the Tilt dev tool
- [[tilt-choosing-clusters]] — selecting a local cluster runtime (Kind, k3d, Minikube, Docker Desktop)
- [[kubernetes]] — the container orchestration platform underlying all cluster approaches
