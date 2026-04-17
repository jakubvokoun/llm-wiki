---
title: "Network Policy (Kubernetes)"
tags: [kubernetes, network, security, network-policy, cni]
sources: [owasp-kubernetes-security.md]
updated: 2026-04-15
---

# Network Policy (Kubernetes)

Kubernetes `NetworkPolicy` objects control ingress and egress traffic between pods and namespaces.

## Default Behavior

Without NetworkPolicy: **all pods can reach all other pods** in the cluster. This flat network is a major security risk — a compromised pod can reach any other pod.

## NetworkPolicy Basics

NetworkPolicies are enforced by CNI (Container Network Interface) plugins. Not all CNI plugins support NetworkPolicy — supported ones include Calico, Cilium, Weave Net, Antrea.

### Recommended Pattern: Deny-All + Explicit Whitelist

```yaml
# Step 1: Deny all ingress/egress in a namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  podSelector: {} # matches all pods
  policyTypes:
    - Ingress
    - Egress
```

```yaml
# Step 2: Allow specific traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-to-db
  namespace: production
spec:
  podSelector:
    matchLabels:
      role: database
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: api
      ports:
        - protocol: TCP
          port: 5432
```

## Scope

NetworkPolicies select pods using `podSelector` and sources/destinations using `podSelector`, `namespaceSelector`, and `ipBlock`.

## Limitations

- No application-layer (L7) filtering — only L3/L4 (IP/port)
- For L7 policies (HTTP path, headers), use a service mesh (Istio, Linkerd)

## Related Concepts

- [kubernetes-security](kubernetes-security.md)
- [service-mesh](service-mesh.md)
- [container-security](container-security.md)

## Sources

- [OWASP Kubernetes Security Cheat Sheet](../sources/owasp-kubernetes-security.md)
