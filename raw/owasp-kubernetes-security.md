# Kubernetes Security Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html

## Overview

Kubernetes is a portable, extensible open-source platform for managing containerized workloads and services. Components: Control Plane (API server, etcd, scheduler, controller manager) and Nodes (kubelet, kube-proxy, container runtime).

## Section 1: Securing Kubernetes Hosts

### Updating Kubernetes
- Keep cluster updated to latest stable release (3 minor versions maintained)
- Vulnerabilities often fixed in newer versions only
- Subscribe to kubernetes-security-announce mailing list

## Section 2: Securing Kubernetes Components

### Securing the Kubernetes Dashboard
- Avoid exposing the dashboard publicly
- Use RBAC to limit dashboard permissions
- Do not use default admin service accounts for the dashboard

### Restricting Access to etcd
- etcd stores all cluster state including secrets
- Restrict access to etcd — only API server should communicate with it
- Use TLS for etcd communication
- Separate etcd for cluster use vs application use
- Encrypt etcd at rest

### Controlling Network Access to Sensitive Ports

| Component | Ports |
|-----------|-------|
| API server | 6443 or 443 |
| etcd | 2379-2380 |
| Scheduler | 10251 |
| Controller Manager | 10252 |
| Kubelet | 10250, 10255 |
| NodePort services | 30000-32767 |

Restrict access to these ports using network controls.

### Controlling Access to the Kubernetes API

Kubernetes API authorization flow: Authentication → Authorization → Admission Control

**Recommended external authentication options:**
- OpenID Connect (OIDC) with enterprise IdP
- Managed cloud provider auth (EKS IAM, GKE Google Identity)

**Not recommended built-in auth:**
- Static token files
- Bootstrap tokens
- HTTP basic auth
- Service account tokens for user auth

### Implementing RBAC

- Use RBAC to control access to cluster resources
- Principle of least privilege — grant minimum required permissions
- Avoid ClusterAdmin role except for cluster administrators
- Prefer Roles (namespace-scoped) over ClusterRoles where possible
- Regularly audit RBAC permissions
- Use `kubectl auth can-i` for auditing

### Limiting Access to Kubelets
- Enable kubelet authentication (X.509 client certs or API bearer tokens)
- Enable kubelet authorization (RBAC or Webhook mode)
- Disable anonymous access to kubelet (--anonymous-auth=false)
- Restrict kubelet API access with network controls

## Section 3: Build Phase

### Container Images
- Only use images from authorized/trusted registries
- Scan images for vulnerabilities in CI pipeline
- Use minimal/distroless base images
- Keep images up-to-date with security patches
- Use multi-stage builds to reduce image size and attack surface
- Never run as root in containers

### CI Pipeline Security
- Integrate image vulnerability scanning into CI/CD
- Use admission webhook to enforce image policies (ImagePolicyWebhook)
- Sign images and verify signatures at deployment time

## Section 4: Deploy Phase

### Namespace Isolation
- Use namespaces to isolate resources and teams
- Apply ResourceQuotas and LimitRanges per namespace
- Apply RBAC per namespace

### Pod Security Context
Key security context settings:
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 10000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
    add: ["NET_BIND_SERVICE"]  # only if needed
```

### Pod Security Standards (PSS)
Three policy levels:
- **Privileged**: No restrictions (for system/infrastructure workloads)
- **Baseline**: Minimal restrictions, prevents known privilege escalations
- **Restricted**: Heavily restricted, follows security best practices

Enforced via Pod Security Admission controller (replaced deprecated PodSecurityPolicies).

### Service Mesh
Advantages: automatic mTLS, observability, traffic management, policy enforcement.
Disadvantages: operational complexity, performance overhead.

### OPA (Open Policy Agent) / Admission Control
- Centralized policy management for K8s admission control
- Use cases: resource quotas, image registry enforcement, label requirements, security context enforcement
- OPA also used for application authorization and service mesh authorization

### Network Policies
- Default: all pods can communicate with all other pods
- Use NetworkPolicy to restrict ingress/egress between pods
- Implement deny-all default policy, then whitelist needed traffic
- Supported by CNI plugins (Calico, Cilium, Weave, etc.)

### Secrets
- Don't store secrets in environment variables (visible in `kubectl describe`)
- Mount secrets as volumes where possible
- Enable encryption at rest for Kubernetes Secrets
- Consider external secret stores: AWS Secrets Manager, HashiCorp Vault, Azure Key Vault
- Detect exposed secrets with tools like git-secrets, truffleHog

## Section 5: Runtime Phase

### Pod Security Admission
Enforce PSS at namespace level with `pod-security.kubernetes.io/enforce: restricted` labels.

### Container Runtime Security
- Use runtime security tools: Falco, Sysdig, Aqua Security
- Monitor for anomalous behavior (unexpected process execution, file access, network connections)

### Container Sandboxing
- Use gVisor or Kata Containers for additional isolation
- Especially important for multi-tenant clusters

### Prevent Unwanted Kernel Module Loading
- Disable unnecessary kernel modules (DCCP, SCTP)
- Use seccomp profiles to restrict syscalls

### Monitoring and Incident Response
- Compare runtime activity across pods of the same deployment (baseline + anomaly detection)
- Monitor network traffic for unexpected communication patterns
- If compromised: scale suspicious pods to 0 immediately
- Rotate all infrastructure credentials frequently

### Logging
- Enable API server audit logging (define audit policies)
- Audit log levels: None, Metadata, Request, RequestResponse
- Container logging: stdout/stderr captured by kubelet
- Node logging: systemd journal
- Cluster logging: ship to centralized system (EFK, Loki, etc.)

## Section 5: Managed Kubernetes on Cloud

- AWS EKS: Use IAM for K8s auth, enable control plane logging, use security groups
- GKE: Enable Workload Identity, Binary Authorization, Container-Optimized OS
- Azure AKS: Use Azure AD integration, Azure Policy add-on

## Section 6: Supply Chain Security

- Use only trusted base images from verified registries
- Scan all images in CI/CD
- Sign images (Cosign/Sigstore)
- Use SLSA framework for provenance
- Verify image signatures at deployment via admission webhook

## Final Thoughts

1. Embed security into the container lifecycle as early as possible (shift-left)
2. Use Kubernetes-native security controls to reduce operational risk (PSS, RBAC, NetworkPolicy, SecretEncryption)
3. Leverage Kubernetes context to prioritize remediation (namespace, labels, ownership)

## References

- CIS Kubernetes Benchmark
- NSA/CISA Kubernetes Hardening Guidance
- NIST SP 800-190 Application Container Security Guide
- Kubernetes official security documentation
