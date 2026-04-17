---
title: "Role-Based Access Control (RBAC)"
tags: [rbac, security, authorization, kubernetes, iam, abac, rebac]
sources: [owasp-kubernetes-security.md, owasp-authorization.md]
updated: 2026-04-16
---

# Role-Based Access Control (RBAC)

RBAC grants permissions to identities based on their role, following the principle of least privilege.

## Core Concept

Permissions are not assigned directly to users/services. Instead:

1. Roles are defined with specific permissions
2. Roles are bound to subjects (users, groups, service accounts)

This makes permission management scalable and auditable.

## Kubernetes RBAC

Kubernetes RBAC uses four API objects:

- `Role` — permissions within a single namespace
- `ClusterRole` — permissions across the entire cluster
- `RoleBinding` — binds Role to subject within namespace
- `ClusterRoleBinding` — binds ClusterRole to subject cluster-wide

### Best Practices

- **Prefer `Role` over `ClusterRole`** — limit blast radius
- **Avoid ClusterAdmin** except for cluster administrators
- **Least privilege**: grant only verbs (get, list, watch, create, update, delete) on specific resources needed
- **Audit regularly**: `kubectl auth can-i --list --as <user>` and `kubectl auth can-i --list -n <namespace> --as system:serviceaccount:<ns>:<sa>`
- **Avoid wildcards**: `resources: ["*"]` or `verbs: ["*"]` should be treated as red flags
- **Service accounts**: create dedicated service accounts per workload; don't use the default service account

### Example (least privilege)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: pod-reader
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "watch", "list"]
```

## Beyond Kubernetes

RBAC is a general access control pattern used in:

- Cloud IAM (AWS IAM roles, GCP IAM roles)
- Databases (PostgreSQL roles)
- CI/CD platforms
- Microservices authorization layers

## Limitations vs ABAC/ReBAC

OWASP Authorization Cheat Sheet recommends preferring ABAC or ReBAC over RBAC for application development:

| Problem                   | Description                                                                 |
| ------------------------- | --------------------------------------------------------------------------- |
| Role explosion            | As system grows, roles multiply; hundreds of roles become hard to audit     |
| Coarse-grained            | Roles don't natively encode context (time of day, device, location)         |
| Multi-tenancy             | Poorly suited; requires per-tenant role duplication                         |
| Horizontal access control | Can't efficiently express "only the author can edit" without per-user roles |

RBAC remains appropriate for:

- Infrastructure access control (Kubernetes, cloud IAM)
- Simple applications with well-defined, stable role sets
- Cases where coarse-grained permission grouping is intentional

See [ABAC](abac.md) and [Authorization](authorization.md) for comparison.

## Related Concepts

- [Authorization](authorization.md)
- [ABAC](abac.md)
- [IDOR](idor.md)
- [Kubernetes Security](kubernetes-security.md)
- [Microservices Security](microservices-security.md)

## Sources

- [OWASP Kubernetes Security Cheat Sheet](../sources/owasp-kubernetes-security.md)
- [OWASP Authorization Cheat Sheet](../sources/owasp-authorization.md)
