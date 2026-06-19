---
title: "UDS Core — Platform Security"
tags:
  [
    uds-core,
    defense-in-depth,
    supply-chain,
    zero-trust,
    airgap,
    compliance,
    nist,
    fedramp,
  ]
sources: [uds-core-platform-security.md]
updated: 2026-05-07
---

# UDS Core — Platform Security

UDS Core enforces security controls at every stage from software supply chain through runtime behavior. This page summarizes the full defense-in-depth model.

## Defense-in-depth layers

| Layer                     | What UDS Core does                                                                                                          |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Supply chain**          | Per-release CVE scanning + SBOMs; deterministic Zarf packaging                                                              |
| **Airgap delivery**       | No external runtime dependencies; Zarf carries all images + manifests                                                       |
| **Identity & SSO**        | Keycloak + Authservice; consistent auth regardless of app capability                                                        |
| **Zero-trust networking** | Default-deny NetworkPolicy; Istio STRICT mTLS; ALLOW-based AuthorizationPolicy; explicit egress; Admin/Tenant gateway split |
| **Admission control**     | Pepr blocks root, privileged, excess capabilities, host access; mutations apply safe defaults; controlled exemptions        |
| **Runtime security**      | Falco behavioral detection; alerts route to existing logging/metrics stack                                                  |
| **Observability & audit** | Vector → Loki (logs); Prometheus → Grafana (metrics); unified troubleshooting                                               |
| **Compliance**            | Controls address NIST 800-53, DISA STIG, FedRAMP baselines; ATO support artifacts available                                 |

## Key principles

- **Defaults are restrictive** — operators explicitly loosen controls; any reduction in the default security posture should be deliberate and documented
- **No external runtime dependencies** — fully air-gap-capable after deployment
- **Audit trail** — exemptions, network policies, and auth events are Kubernetes objects; visible in audit logs, governed by RBAC

## Compliance posture

UDS Core is designed for regulated environments including DoD, FedRAMP, and DISA STIG. Defense Unicorns provides technical documentation and control mapping artifacts for ATO processes.

## Related pages

- [Defense-in-Depth](../concepts/defense-in-depth.md)
- [Zero Trust Architecture](../concepts/zero-trust.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [UDS Core — Runtime Security](uds-core-runtime-security.md)
- [UDS Core — Policy & Compliance](uds-core-policy-compliance.md)
- [UDS Core — Networking](uds-core-networking.md)
