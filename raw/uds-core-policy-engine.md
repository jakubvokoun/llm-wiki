# UDS Policies

UDS Core enforces security policies via [Pepr](https://docs.pepr.dev/) admission webhooks. These policies align with the [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) (restricted profile) and add Istio-specific controls to prevent unauthorized overrides to service mesh behavior.

## Exemptions

Exemptions can be specified by an `Exemption` CR. If a resource is exempted, it will be annotated as `uds-core.pepr.dev/uds-core-policies.<POLICY>: exempted`.

## Mutations

Mutations can be exempted using the same Exemptions references as the validations.

| Mutation | Mutated Fields | Mutation Logic |
| --- | --- | --- |
| Disallow Privilege Escalation | `containers[].securityContext.allowPrivilegeEscalation` | Mutates `allowPrivilegeEscalation` to `false` if undefined, unless the container is privileged or `CAP_SYS_ADMIN` is added. |
| Require Non-root User | `securityContext.runAsUser`, `runAsGroup`, `fsGroup`, `runAsNonRoot` | Sets `runAsNonRoot: true` if undefined. Also defaults `runAsUser`, `runAsGroup`, and `fsGroup` to `1000` if undefined. These defaults can be overridden with the `uds/user`, `uds/group`, and `uds/fsgroup` pod labels. |
| Drop All Capabilities | `containers[].securityContext.capabilities.drop` | Ensures all capabilities are dropped by setting `capabilities.drop` to `["ALL"]` for all containers. |

## Validations

| Policy Name | Exemption Name | Policy Description |
| --- | --- | --- |
| Disallow Host Namespaces | `DisallowHostNamespaces` | **Pod** / **high** — Host namespaces (PID, IPC, network) allow access to shared information and can be used to elevate privileges. Pods should not be allowed access to host namespaces. |
| Disallow NodePort Services | `DisallowNodePortServices` | **Service** / **medium** — NodePort services use a host port to receive traffic from any source. A NetworkPolicy cannot be used to control traffic to host ports. |
| Disallow Privileged Escalation and Pods | `DisallowPrivileged` | **Pod** / **high** — `allowPrivilegeEscalation` must be `false` and `privileged` must be `false` or undefined. |
| Disallow SELinux Options | `DisallowSELinuxOptions` | **Pod** / **high** — SELinux options can be used to escalate privileges. |
| Drop All Capabilities | `DropAllCapabilities` | **Pod** / **medium** — All capabilities should be dropped; only those required may be added back. |
| Require Non-root User | `RequireNonRootUser` | **Pod** / **high** — Containers must have `runAsNonRoot: true` or `runAsUser > 0`. |
| Restrict Capabilities | `RestrictCapabilities` | **Pod** / **high** — Adding capabilities beyond the default set must not be allowed. |
| Restrict External Names | `RestrictExternalNames` | **Service** / **medium** — ExternalName services can redirect traffic to malicious endpoints; restricted to a specified list. |
| Restrict hostPath Volume Writable Paths | `RestrictHostPathWrite` | **Pod** / **medium** — hostPath volumes must be explicitly mounted in readOnly mode. |
| Restrict Host Ports | `RestrictHostPorts` | **Pod** / **high** — Only approved ports are defined in container's `hostPort` field. |
| Restrict Proc Mount | `RestrictProcMount` | **Pod** / **high** — Only "Default" procMount is allowed. |
| Restrict Seccomp | `RestrictSeccomp` | **Pod** / **high** — `seccompProfile.Type` must be `RuntimeDefault` or `Localhost`; not `Unconfined`. |
| Restrict SELinux Type | `RestrictSELinuxType` | **Pod** / **high** — `seLinuxOptions` type field must be undefined or restricted to the allowed list. |
| Restrict Istio User | `RestrictIstioUser` | **Pod** / **high** — Only trusted Istio components (waypoint pods, gateways, sidecars) can run as UID/GID 1337. |
| Restrict Istio Sidecar Configuration Overrides | `RestrictIstioSidecarOverrides` | **Pod** / **high** — Blocks dangerous Istio sidecar configuration annotations: `bootstrapOverride`, `discoveryAddress`, `proxyImage`, `proxy.istio.io/config`, `userVolume`, `userVolumeMount`. |
| Restrict Istio Traffic Interception Overrides | `RestrictIstioTrafficOverrides` | **Pod** / **high** — Blocks annotations and labels that bypass traffic interception controls including `sidecar.istio.io/inject`, `traffic.sidecar.istio.io/exclude*`, and `includeInbound/OutboundPorts`. |
| Restrict Istio Ambient Mesh Overrides | `RestrictIstioAmbientOverrides` | **Pod** / **high** — Blocks `ambient.istio.io/bypass-inbound-capture`. |
| Restrict Volume Types | `RestrictVolumeTypes` | **Pod** / **medium** — Allowed volume types: `configMap`, `csi`, `downwardAPI`, `emptyDir`, `ephemeral`, `image`, `persistentVolumeClaim`, `projected`, `secret`. HostPath volumes are not allowed. |

## Big Bang Kyverno policy comparison

UDS Core policies were partially inspired by Big Bang Kyverno policies created for the DoD Big Bang platform.

### Policies in UDS Core only

| UDS Core Policy | Notes |
| --- | --- |
| `RestrictIstioUser` | Blocks non-Istio pods from running as UID/GID 1337 |
| `RestrictIstioSidecarOverrides` | Blocks dangerous sidecar configuration annotations |
| `RestrictIstioTrafficOverrides` | Blocks traffic interception bypass annotations/labels |
| `RestrictIstioAmbientOverrides` | Blocks ambient mesh bypass annotations |

### Policies in Big Bang only (not yet in UDS Core)

| Big Bang Policy | Notes |
| --- | --- |
| restrict-sysctls | PSS Baseline |
| restrict-apparmor | PSS Baseline |
| restrict-host-path-mount | — |
| restrict-image-registries | In UDS, Zarf handles registry control at the packaging layer |
| require-image-signature | Disabled in Big Bang by default |
| restrict-external-ips | — |
| require-non-root-group | Partially mitigated by RequireNonRootUser mutation defaulting `runAsGroup` to 1000 |
| disallow-auto-mount-service-account-token | Audit-only in Big Bang |
