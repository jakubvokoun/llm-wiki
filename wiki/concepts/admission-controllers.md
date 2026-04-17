---
title: "Admission Controllers (Kubernetes)"
tags: [kubernetes, security, admission, opa, gatekeeper, policy]
sources: [owasp-kubernetes-security.md]
updated: 2026-04-15
---

# Admission Controllers (Kubernetes)

Admission controllers intercept Kubernetes API requests after authentication/authorization but before persistence, enabling policy enforcement and mutation.

## How They Work

Request flow: `kubectl` → API server → **Authentication** → **Authorization (RBAC)** → **Admission Control** → etcd

Two types:

- **Mutating**: Modify the object (e.g., inject sidecar, add labels)
- **Validating**: Accept or reject the object based on policy

## Built-in Admission Controllers

| Controller           | Purpose                                          |
| -------------------- | ------------------------------------------------ |
| `PodSecurity`        | Enforces Pod Security Standards (replaced PSP)   |
| `ImagePolicyWebhook` | Validates images against external policy service |
| `LimitRanger`        | Enforces resource limits on pods                 |
| `ResourceQuota`      | Enforces namespace-level resource quotas         |
| `NamespaceLifecycle` | Prevents creation in terminating namespaces      |

## OPA / Gatekeeper (Policy-as-Code)

Open Policy Agent (OPA) with the Gatekeeper webhook provides flexible, custom admission policies written in Rego.

Common use cases:

- **Image registry allowlisting**: Only allow images from `registry.example.com/*`
- **Required labels**: All deployments must have `team` and `env` labels
- **Security context enforcement**: Containers must set `runAsNonRoot: true`
- **Resource limits**: All pods must specify CPU/memory limits
- **Service mesh injection**: Require sidecar injection annotations

Example constraint template:

```
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8srequiredlabels
      violation[{"msg": msg}] {
        required := input.parameters.labels
        provided := {label | input.review.object.metadata.labels[label]}
        missing := required - provided
        count(missing) > 0
        msg := sprintf("Missing labels: %v", [missing])
      }
```

## Webhooks

Custom admission webhooks (MutatingWebhookConfiguration, ValidatingWebhookConfiguration) allow integrating any external service into the admission pipeline. Used by: OPA/Gatekeeper, Kyverno, Istio sidecar injection, cert-manager.

## Related Concepts

- [kubernetes-security](kubernetes-security.md)
- [pod-security](pod-security.md)
- [rbac](rbac.md)

## Sources

- [OWASP Kubernetes Security Cheat Sheet](../sources/owasp-kubernetes-security.md)
