---
title: "Pod Security (Kubernetes)"
tags: [kubernetes, security, pod, security-context, pss, capabilities]
sources: [owasp-kubernetes-security.md, linux-capabilities-man7.md]
updated: 2026-04-16
---

# Pod Security (Kubernetes)

Controls that restrict what containers in a pod can do at the OS level.

## Security Context

Applied at pod or container level in the pod spec:

```yaml
securityContext:
  runAsNonRoot: true # Don't run as root
  runAsUser: 10000 # Specific UID
  readOnlyRootFilesystem: true # No writes to container filesystem
  allowPrivilegeEscalation: false # No setuid/setgid
  capabilities:
    drop: ["ALL"] # Drop all Linux capabilities
    add: ["NET_BIND_SERVICE"] # Add only what's needed
  seccompProfile:
    type: RuntimeDefault # Enable seccomp filtering
```

## Pod Security Standards (PSS)

Three levels, enforced via the built-in Pod Security Admission controller:

| Level        | Description                          | Use For                                                        |
| ------------ | ------------------------------------ | -------------------------------------------------------------- |
| `privileged` | No restrictions                      | System/infrastructure workloads (e.g., CNI, monitoring agents) |
| `baseline`   | Prevents known privilege escalations | General workloads                                              |
| `restricted` | All security best practices enforced | Default for new workloads                                      |

### Enforcement via Namespace Labels

```yaml
# Enforce restricted policy; warn on baseline violations; audit privileged
metadata:
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/warn: baseline
    pod-security.kubernetes.io/audit: privileged
```

## History

PodSecurityPolicies (PSP) — the predecessor — were **deprecated in K8s 1.21** and **removed in 1.25**. PSS + Pod Security Admission controller replaced them.

For more fine-grained policies beyond PSS, use OPA/Gatekeeper admission webhooks. See [admission-controllers](admission-controllers.md).

## Related Concepts

- [kubernetes-security](kubernetes-security.md)
- [container-security](container-security.md)
- [admission-controllers](admission-controllers.md)
- [linux-capabilities](linux-capabilities.md) — what capabilities are and which ones to drop/add

## Sources

- [OWASP Kubernetes Security Cheat Sheet](../sources/owasp-kubernetes-security.md)
