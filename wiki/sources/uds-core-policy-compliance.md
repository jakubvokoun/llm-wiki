---
title: "UDS Core — Policy & Compliance"
tags:
  [uds-core, pepr, admission-control, policy-engine, exemption, pod-security]
sources: [uds-core-policy-compliance.md]
updated: 2026-05-07
---

# UDS Core — Policy & Compliance

UDS Core enforces secure and compliant workload behavior through [Pepr](../entities/pepr.md), running as Kubernetes admission webhooks. Every resource submitted to the cluster passes through Pepr before being persisted.

## How policies work

| Policy type | What it does | Example |
| --- | --- | --- |
| **Mutation** | Automatically corrects setting to a safe default | Drop all capabilities, set `runAsNonRoot: true` |
| **Validation** | Blocks resource if it does not meet the policy | Disallow privileged containers, reject NodePort services |

Mutations run first and silently fix common misconfigurations. Validations run after mutations and reject resources that cannot be automatically corrected, returning a clear error.

## Key policies enforced

- **No privileged containers** — `privileged: true` is blocked
- **No root users** — `runAsNonRoot: true` or non-zero UID required
- **Capability drops** — containers must drop `ALL`; only specific allowed caps may be added
- **No host namespaces** — PID, IPC, network host sharing blocked
- **No NodePort services** — must use ClusterIP or service mesh gateway

## Exemptions

Some workloads legitimately need exemptions (e.g., privileged DaemonSets for node-level observability). The `Exemption` CR:

- Names exactly which policies to bypass and targets specific workloads by namespace and name
- Is stored as a Kubernetes object (appears in audit logs, requires RBAC to create)
- By default, restricted to the `uds-policy-exemptions` namespace for centralized audit

Use exemptions sparingly and with documented justification. Prefer fixing the workload.

## Related pages

- [Pepr](../entities/pepr.md)
- [UDS Core Policy Engine reference](uds-core-policy-engine.md)
- [Admission Controllers](../concepts/admission-controllers.md)
- [Pod Security](../concepts/pod-security.md)
- [Defense-in-Depth](../concepts/defense-in-depth.md)
