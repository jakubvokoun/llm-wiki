---
title: "Pepr"
tags:
  [
    product,
    kubernetes,
    admission-control,
    policy-engine,
    defense-unicorns,
    typescript,
  ]
sources: [uds-core-concepts-overview.md, uds-core-policy-engine.md]
updated: 2026-05-07
---

# Pepr

Pepr is a Kubernetes admission controller framework built by [Defense Unicorns](defense-unicorns.md). It runs as admission webhooks and enables policy enforcement via TypeScript modules.

## Role in UDS Core

Pepr serves as the UDS Core Policy Engine. It runs alongside the UDS Operator and enforces a security baseline aligned with Kubernetes Pod Security Standards (restricted profile), plus Istio-specific controls.

**Mutations** — automatically correct safe defaults before admission:

- Sets `allowPrivilegeEscalation: false` if undefined
- Sets `runAsNonRoot: true` and defaults `runAsUser`/`runAsGroup`/`fsGroup` to `1000`
- Sets `capabilities.drop: ["ALL"]` on all containers

**Validations** — block unsafe configurations:

- No privileged containers
- No host namespaces (PID/IPC/network)
- No NodePort services
- Drop all capabilities; only approved additions allowed
- Restricted seccomp profile (`RuntimeDefault` or `Localhost`)
- Istio-specific: blocks sidecar config overrides, traffic interception bypasses, ambient mesh bypasses, and non-Istio pods running as UID/GID 1337

## Exemption CR

When a workload legitimately needs to bypass a policy, an `Exemption` CR is created in the `uds-policy-exemptions` namespace. The exempted resource is annotated with `uds-core.pepr.dev/uds-core-policies.<POLICY>: exempted`.

## Related pages

- [UDS Core Policy Engine](../sources/uds-core-policy-engine.md)
- [UDS Core](uds-core.md)
- [Admission Controllers](../concepts/admission-controllers.md)
