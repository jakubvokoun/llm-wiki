---
title: "OWASP Kubernetes Security Cheat Sheet"
tags: [owasp, kubernetes, containers, security, rbac, network-policy]
sources: [owasp-kubernetes-security.md]
updated: 2026-04-15
---

# OWASP Kubernetes Security Cheat Sheet

Comprehensive security guidance across the Kubernetes cluster lifecycle: hosts, components, build, deploy, and runtime phases.

## Key Takeaways

Kubernetes security is multi-layered — each layer (host, control plane, workload, runtime) must be hardened independently. Defense in depth is essential because a compromise at any layer can cascade.

## Control Plane Hardening

- **etcd**: Restrict access to API server only; TLS for all communication; encrypt at rest. etcd holds all cluster state including secrets.
- **API server**: Use OIDC or managed cloud auth (never static tokens or basic auth); enable audit logging; RBAC only.
- **Dashboard**: Never expose publicly; use RBAC; don't use default admin service accounts.
- **Sensitive ports**: Restrict network access to API server (6443), etcd (2379-2380), kubelet (10250), scheduler/controller (10251-10252).
- **Kubelet**: Disable anonymous access (`--anonymous-auth=false`); enable RBAC auth mode.

## RBAC

- Least privilege — grant minimum required permissions
- Prefer namespace-scoped `Role` over cluster-scoped `ClusterRole`
- Avoid ClusterAdmin except for cluster admins
- Audit with `kubectl auth can-i --list`
- See [concepts/rbac](../concepts/rbac.md)

## Build Phase

- Only use authorized images from trusted registries
- Scan images in CI/CD for vulnerabilities
- Use minimal/distroless base images; multi-stage builds
- Never run as root in container images
- Enforce image policy via `ImagePolicyWebhook` admission controller

## Deploy Phase (Pod Security)

Security context best practices:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 10000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
```

**Pod Security Standards** (replaced deprecated PodSecurityPolicies):

- `Privileged`: No restrictions (system workloads only)
- `Baseline`: Prevents known privilege escalations
- `Restricted`: Follows all security best practices

Enforce via `pod-security.kubernetes.io/enforce` namespace label.

## Network Policies

- Default K8s: all pods can reach all pods — deny all, then whitelist
- Use `NetworkPolicy` resources with CNI support (Calico, Cilium, Weave)
- Implement namespace-level isolation

## Secrets

- Prefer volume mounts over env vars (env vars visible in `kubectl describe`)
- Enable encryption at rest for `Secret` resources in etcd
- Use external secret stores: Vault, AWS Secrets Manager, Azure Key Vault
- Detect exposed secrets with git-secrets, truffleHog

## Admission Controllers / OPA

- Use OPA/Gatekeeper for centralized policy enforcement
- Common uses: registry allowlisting, label requirements, security context enforcement, resource quotas
- Also usable for service mesh authorization and application-level auth

## Runtime

- Enable Pod Security Admission with `restricted` profile
- Use Falco or Sysdig for runtime anomaly detection
- Container sandboxing: gVisor or Kata Containers for multi-tenant clusters
- Seccomp profiles to restrict syscalls; disable DCCP/SCTP kernel modules
- Monitor pod network traffic; compare runtime activity against baseline
- If breached: scale suspicious pods to 0 immediately; rotate all credentials

## Supply Chain

- Sign images with Cosign/Sigstore
- Verify signatures at deployment via admission webhook
- SLSA framework for provenance
- See [concepts/supply-chain-security](../concepts/supply-chain-security.md)

## Related Pages

- [concepts/kubernetes-security](../concepts/kubernetes-security.md)
- [concepts/container-security](../concepts/container-security.md)
- [concepts/rbac](../concepts/rbac.md)
- [concepts/network-policy](../concepts/network-policy.md)
- [concepts/pod-security](../concepts/pod-security.md)
- [concepts/admission-controllers](../concepts/admission-controllers.md)
- [concepts/service-mesh](../concepts/service-mesh.md)
- [concepts/supply-chain-security](../concepts/supply-chain-security.md)
