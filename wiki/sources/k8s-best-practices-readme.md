---
title: "Kubernetes Best Practices 101 (diegolnasc/kubernetes-best-practices)"
tags: [kubernetes, containers, best-practices, gitops, observability, hpa, pdb]
sources: [k8s-best-practices-readme.md]
updated: 2026-04-16
---

# Kubernetes Best Practices 101

Community guide covering the full K8s production lifecycle: cluster setup, workload configuration, networking, secrets, observability, and deployment.

## Key Takeaways

### Cluster

- Size CIDR ranges upfront — GCP reserves double IPs per node; calculate pods/node → CIDR
- Private clusters: nodes and API server off-internet; separate environments (dev/prod) in different VPCs
- Use IaC (Terraform/CloudFormation/Ansible) for all infrastructure

### Cost Optimization

- Node-pools by workload type (high-CPU, high-memory, spot); enable cluster autoscaler
- Committed use discounts; cheap regions for non-latency-sensitive batch jobs
- Spot/preemptible node pools for non-critical workloads

### Security

- PSP removed K8s 1.25 → use Pod Security Admission (PSA) with namespace labels
- Enforce `restricted` PSS for all new workloads
- RBAC: prefer namespace `Role` over `ClusterRole`; dedicate service accounts per app; audit regularly
- See [Kubernetes Security](../concepts/kubernetes-security.md) and [Pod Security](../concepts/pod-security.md)

### Probes

Three types of health probes:

| Probe     | Purpose            | On Failure               |
| --------- | ------------------ | ------------------------ |
| Liveness  | Is app healthy?    | Restart container        |
| Readiness | Ready for traffic? | Remove from endpoints    |
| Startup   | Finished starting? | Block liveness/readiness |

Use startup probe for slow-starting apps (ML models, legacy) to avoid premature restarts.

### Resources

- Always set `requests` and `limits` on every container
- Memory: set `requests == limits` (non-compressible; OOMKill on excess)
- CPU: set `requests` only — no CPU limits to avoid unnecessary throttling

### Autoscaling

- HPA (horizontal) for stateless services: target utilization = `(high-bound - safety) / (high-bound + growth)`
- VPA (vertical) in recommendation mode to calibrate requests
- `behavior` field in HPA controls scale-up/down velocity and prevents flapping

### Pod Disruption Budget

- Required for production: guarantees min availability during node drains, upgrades, evictions
- `minAvailable` for critical services; only protects against _voluntary_ disruptions

### Graceful Shutdown

K8s termination sequence: `Terminating → preStop hook → SIGTERM → grace period → SIGKILL`

- Implement preStop hook + `sleep 5-10` to let load balancer drain connections
- Handle SIGTERM in app code; set `terminationGracePeriodSeconds` appropriately

### Secrets

| Option                    | Security                                 | Complexity |
| ------------------------- | ---------------------------------------- | ---------- |
| K8s Secrets               | base64, needs encryption-at-rest enabled | Low        |
| Sealed Secrets            | encrypted in Git, decrypted in cluster   | Low        |
| External Secrets Operator | syncs from AWS/GCP/Vault                 | Medium     |
| HashiCorp Vault           | full-featured                            | High       |
| Cloud KMS                 | GCP/AWS key management                   | Medium     |

### Observability (Three Pillars)

- **Metrics**: Prometheus + Grafana; ServiceMonitor CRD for scraping
- **Logs**: Loki / ELK Stack; structured JSON to stdout/stderr
- **Traces**: Jaeger / Tempo / Zipkin; use OpenTelemetry for vendor-agnostic instrumentation
- Include correlation IDs across all pillars

### Deployment Strategies

- **RollingUpdate**: zero downtime, no traffic control between versions
- **Recreate**: fast rollback, causes downtime
- **Blue-Green**: two parallel envs, instant traffic switch; use service mesh or Knative
- **Canary**: gradual traffic shift; use Argo Rollouts, Flagger, Istio, or Linkerd

### GitOps

Git is single source of truth for all manifests. Tools: Argo CD, Flux. Benefits: audit trail, self-healing, easy rollback via `git revert`. See [GitOps](../concepts/gitops.md).

## Production Checklist

- [ ] Pod Security Standards applied (restricted profile)
- [ ] Non-root containers, read-only filesystem, dropped capabilities
- [ ] RBAC: least-privilege service accounts per app
- [ ] CPU requests set, memory requests == limits
- [ ] Liveness + readiness probes configured
- [ ] HPA with proper utilization target
- [ ] PDB defined for production workloads
- [ ] Network policies: deny-all default + explicit whitelist
- [ ] Secrets not in plain text / Git
- [ ] Metrics/logs/traces instrumented
- [ ] Standard labels on all resources
- [ ] Graceful shutdown (preStop + SIGTERM handling)
- [ ] Images from trusted registries, tagged by SHA

## Sources

- [Raw: k8s-best-practices-readme.md](../../raw/k8s-best-practices-readme.md)
