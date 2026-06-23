---
title: "openQA — Helm Chart README"
tags: [openqa, kubernetes, helm, deployment]
sources: [openqa-helm-readme.md]
updated: 2026-06-23
---

# openQA — Helm Chart README

README for the official [Helm](https://helm.sh/) chart that deploys [openQA](../entities/openqa.md) into [Kubernetes](../entities/kubernetes.md) (in `container/helm` of the openQA repo).

## Key Takeaways

- **Chart structure** — a parent `openqa` chart with two sub-charts: **`webui`** and **`worker`**. `helm dependency update openqa/` builds sub-chart manifests under `openqa/charts/`.
- **Prerequisites** — a Kubernetes cluster (k3s/minikube) and Helm.
- **Ingress via Gateway API** — uses the [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/) with an **Envoy Gateway** controller; CRDs installed once before provisioning. Chart creates a `Gateway` + `HTTPRoute` by default. For minikube, `minikube tunnel` assigns an external IP; map the gateway address to the `baseUrl` host (e.g. `openqa.internal`) in `/etc/hosts`. In cloud, the provider provisions the LoadBalancer automatically.
- **Quick access** — `kubectl port-forward svc/openqa 8080:80` needs no gateway setup.
- **Running a job** — `openqa-clone-job --from https://openqa.opensuse.org --host http://openqa.internal <JOB_ID>`, or `openqa-cli api -X POST jobs DISTRI=… …`.
- **Config** — override `openqa/values.yaml` (e.g. via `my_values.yaml -f`); the worker needs basic config per the docs.

## Related Pages

- [openQA](../entities/openqa.md) · [Architecture](../concepts/openqa-architecture.md) · [Kubernetes](../entities/kubernetes.md) · [Installing](openqa-installing.md)
