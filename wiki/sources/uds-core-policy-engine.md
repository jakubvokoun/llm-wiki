---
title: "UDS Core — Policy Engine Reference"
tags:
  [uds-core, pepr, policy-engine, mutations, validations, istio, pod-security]
sources: [uds-core-policy-engine.md]
updated: 2026-05-07
---

# UDS Core — Policy Engine Reference

UDS Core enforces security policies via [Pepr](../entities/pepr.md) admission webhooks,
aligned with Kubernetes Pod Security Standards (restricted profile) plus Istio-specific
controls.

## Exemptions

Specified by an `Exemption` CR. Exempted resources are annotated:
`uds-core.pepr.dev/uds-core-policies.<POLICY>: exempted`

Mutations can also be exempted using the same `Exemption` references.

## Mutations

| Mutation                      | Mutated Fields                                                       | Logic                                                                                                                                                             |
| ----------------------------- | -------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Disallow Privilege Escalation | `containers[].securityContext.allowPrivilegeEscalation`              | Set to `false` if undefined, unless container is privileged or has `CAP_SYS_ADMIN`                                                                                |
| Require Non-root User         | `securityContext.runAsUser`, `runAsGroup`, `fsGroup`, `runAsNonRoot` | Sets `runAsNonRoot: true` if undefined; defaults `runAsUser`/`runAsGroup`/`fsGroup` to `1000`; overridable with `uds/user`, `uds/group`, `uds/fsgroup` pod labels |
| Drop All Capabilities         | `containers[].securityContext.capabilities.drop`                     | Sets `capabilities.drop: ["ALL"]` for all containers                                                                                                              |

## Validations

| Policy Name                                   | Exemption Name                  | Description                                                                                                                                      |
| --------------------------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Disallow Host Namespaces                      | `DisallowHostNamespaces`        | **Pod/high** — PID, IPC, network host namespaces blocked                                                                                         |
| Disallow NodePort Services                    | `DisallowNodePortServices`      | **Service/medium** — NodePort uses host port; NetworkPolicy cannot control host ports                                                            |
| Disallow Privileged Escalation and Pods       | `DisallowPrivileged`            | **Pod/high** — `allowPrivilegeEscalation` must be `false`; `privileged` must be `false`                                                          |
| Disallow SELinux Options                      | `DisallowSELinuxOptions`        | **Pod/high** — SELinux options can escalate privileges                                                                                           |
| Drop All Capabilities                         | `DropAllCapabilities`           | **Pod/medium** — All capabilities must be dropped; required caps added back explicitly                                                           |
| Require Non-root User                         | `RequireNonRootUser`            | **Pod/high** — `runAsNonRoot: true` or `runAsUser > 0`                                                                                           |
| Restrict Capabilities                         | `RestrictCapabilities`          | **Pod/high** — Adding capabilities beyond default set blocked                                                                                    |
| Restrict External Names                       | `RestrictExternalNames`         | **Service/medium** — ExternalName services restricted to specified list                                                                          |
| Restrict hostPath Volume Writable Paths       | `RestrictHostPathWrite`         | **Pod/medium** — hostPath volumes must be mounted readOnly                                                                                       |
| Restrict Host Ports                           | `RestrictHostPorts`             | **Pod/high** — Only approved ports in container's `hostPort` field                                                                               |
| Restrict Proc Mount                           | `RestrictProcMount`             | **Pod/high** — Only "Default" procMount allowed                                                                                                  |
| Restrict Seccomp                              | `RestrictSeccomp`               | **Pod/high** — `seccompProfile.Type` must be `RuntimeDefault` or `Localhost`                                                                     |
| Restrict SELinux Type                         | `RestrictSELinuxType`           | **Pod/high** — `seLinuxOptions` type must be undefined or restricted to allowed list                                                             |
| Restrict Istio User                           | `RestrictIstioUser`             | **Pod/high** — Only trusted Istio components can run as UID/GID 1337                                                                             |
| Restrict Istio Sidecar Config Overrides       | `RestrictIstioSidecarOverrides` | **Pod/high** — Blocks dangerous sidecar annotations: `bootstrapOverride`, `discoveryAddress`, `proxyImage`, etc.                                 |
| Restrict Istio Traffic Interception Overrides | `RestrictIstioTrafficOverrides` | **Pod/high** — Blocks annotations/labels bypassing traffic interception including `sidecar.istio.io/inject`, `traffic.sidecar.istio.io/exclude*` |
| Restrict Istio Ambient Mesh Overrides         | `RestrictIstioAmbientOverrides` | **Pod/high** — Blocks `ambient.istio.io/bypass-inbound-capture`                                                                                  |
| Restrict Volume Types                         | `RestrictVolumeTypes`           | **Pod/medium** — Allowed: configMap, csi, downwardAPI, emptyDir, ephemeral, image, PVC, projected, secret. HostPath blocked.                     |

## Comparison with Big Bang Kyverno policies

### Policies in UDS Core only

| UDS Core Policy                 | Notes                                                 |
| ------------------------------- | ----------------------------------------------------- |
| `RestrictIstioUser`             | Blocks non-Istio pods from running as UID/GID 1337    |
| `RestrictIstioSidecarOverrides` | Blocks dangerous sidecar configuration annotations    |
| `RestrictIstioTrafficOverrides` | Blocks traffic interception bypass annotations/labels |
| `RestrictIstioAmbientOverrides` | Blocks ambient mesh bypass annotations                |

### Policies in Big Bang only (not yet in UDS Core)

| Big Bang Policy                           | Notes                                              |
| ----------------------------------------- | -------------------------------------------------- |
| restrict-sysctls                          | PSS Baseline                                       |
| restrict-apparmor                         | PSS Baseline                                       |
| restrict-host-path-mount                  | —                                                  |
| restrict-image-registries                 | In UDS, Zarf handles registry control              |
| require-image-signature                   | Disabled in Big Bang by default                    |
| restrict-external-ips                     | —                                                  |
| require-non-root-group                    | Partially mitigated by RequireNonRootUser mutation |
| disallow-auto-mount-service-account-token | Audit-only in Big Bang                             |

## Related pages

- [Pepr](../entities/pepr.md)
- [UDS Core — Policy & Compliance](uds-core-policy-compliance.md)
- [Admission Controllers](../concepts/admission-controllers.md)
- [Pod Security](../concepts/pod-security.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
