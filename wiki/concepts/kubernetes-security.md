---
title: "Kubernetes Security"
tags: [kubernetes, containers, security, rbac, network-policy, pod-security]
sources: [owasp-kubernetes-security.md]
updated: 2026-04-15
---

# Kubernetes Security

Multi-layered security for Kubernetes clusters, covering control plane, workload, and runtime phases.

## Defense in Depth Layers

1. **Host security** — patch nodes; harden OS; subscribe to CVE alerts
2. **Control plane** — secure etcd, API server, kubelet, dashboard
3. **RBAC** — least privilege for users, service accounts, pipelines
4. **Build** — trusted images, vulnerability scanning, minimal base images
5. **Deploy** — security contexts, Pod Security Standards, network policies
6. **Runtime** — anomaly detection, audit logging, incident response

## Control Plane Hardening

- **etcd**: TLS only; API server access only; encrypt at rest — etcd holds all cluster state including secrets
- **API server**: OIDC auth (or managed cloud auth); RBAC; audit logging; disable anonymous auth
- **Dashboard**: Never expose publicly; RBAC restricted; no default admin service accounts
- **Kubelet**: `--anonymous-auth=false`; RBAC auth mode
- **Sensitive ports**: Restrict with network controls (API: 6443, etcd: 2379-2380, kubelet: 10250)

## RBAC

Prefer `Role` (namespace) over `ClusterRole`. Avoid ClusterAdmin. Audit with `kubectl auth can-i --list`. See [rbac](rbac.md).

## Pod Security

```yaml
securityContext:
  runAsNonRoot: true
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
```

**Pod Security Standards** (enforce via namespace label):

- `Privileged` — no restrictions (system workloads)
- `Baseline` — prevents known privilege escalations
- `Restricted` — all security best practices enforced

See [pod-security](pod-security.md).

## Network Policies

Default: all pods can reach all pods. Use `NetworkPolicy` to implement:

1. Deny-all default policy per namespace
2. Explicit whitelist rules for needed traffic

Requires CNI plugin support (Calico, Cilium, Weave). See [network-policy](network-policy.md).

## Secrets

- Volume mounts preferred over env vars
- Encryption at rest enabled in etcd
- External secret stores: Vault, AWS Secrets Manager, Azure Key Vault
- Detect exposed secrets: git-secrets, truffleHog

## Admission Controllers / OPA

Centralized policy enforcement at admission time. Uses: image registry allowlisting, required labels, security context enforcement, resource quotas. See [admission-controllers](admission-controllers.md).

## Runtime Security

- Pod Security Admission enforcing `restricted` profile
- Runtime anomaly detection: Falco, Sysdig
- Sandboxing: gVisor / Kata Containers for multi-tenant clusters
- Seccomp profiles; disable DCCP/SCTP
- Scale suspicious pods to 0 on suspected breach; rotate all credentials

## Supply Chain

Sign images with Cosign/Sigstore; verify at deployment. SLSA provenance. See [supply-chain-security](supply-chain-security.md).

## Related Concepts

- [container-security](container-security.md)
- [rbac](rbac.md)
- [pod-security](pod-security.md)
- [network-policy](network-policy.md)
- [admission-controllers](admission-controllers.md)
- [service-mesh](service-mesh.md)
- [supply-chain-security](supply-chain-security.md)

## Sources

- [OWASP Kubernetes Security Cheat Sheet](../sources/owasp-kubernetes-security.md)
