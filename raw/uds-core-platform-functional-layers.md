# Functional Layers

UDS Core is published as a single `core` package that includes everything, but it is also available as **functional layers**, smaller Zarf packages grouped by capability. Layers let you deploy only the platform features your environment needs, which is useful for resource-constrained clusters, edge deployments, or environments that already provide some of these capabilities.

Removing layers from your deployment may affect your security and compliance posture and reduce platform functionality. Deploying individual layers should be the exception; only do so after carefully evaluating the trade-offs for your environment.

## Why layers exist

UDS Core intentionally ships an opinionated, tested baseline. But not every environment needs every capability. An edge node may lack the resources for full monitoring, or a cluster may already provide its own metrics server. Functional layers give teams a supported way to tailor the platform without forking it.

## Available layers

Every layer is published as an individual OCI Zarf package. All layers except `core-crds` require the `core-base` layer as a foundation.

| Layer | What it provides | Dependencies |
| --- | --- | --- |
| core-crds | Standalone UDS CRDs (Package, Exemption, ClusterConfig) | None |
| core-base | Istio, UDS Operator, Pepr Policy Engine | None (foundation for all other layers) |
| core-identity-authorization | Keycloak + Authservice (SSO) | Base |
| core-metrics-server | Kubernetes Metrics Server | Base |
| core-runtime-security | Falco + Falcosidekick | Base |
| core-logging | Vector + Loki | Base; optionally Monitoring for UI |
| core-monitoring | Prometheus + Grafana + Alertmanager + Blackbox Exporter | Base, Identity & Authorization |
| core-backup-restore | Velero | Base |
| core (standard) | All of the above combined | None (self-contained) |

## Layer selection criteria

Default to the full `core` package unless you have an explicit reason to use individual layers.

| Layer | When to include |
| --- | --- |
| **CRDs** | Deploy before Base if you have pre-existing cluster components that need UDS policy exemptions before the policy engine starts |
| **Base** | Required for all UDS deployments and all other layers |
| **Identity & Authorization** | Include if your deployment requires user authentication (direct login, SSO) |
| **Metrics Server** | Include if your cluster does not already provide its own metrics server; skip it if one is already present (e.g., EKS, AKS, or GKE managed metrics) |
| **Runtime Security** | Include for runtime threat detection via Falco |
| **Logging** | Include if you need centralized log aggregation and shipping |
| **Monitoring** | Include for metrics dashboards, alerting, and uptime monitoring |
| **Backup & Restore** | Include if the deployment manages critical data or must maintain state across failures |

The Monitoring layer includes Grafana, which requires the Identity & Authorization layer for login.

If your cluster already provides a metrics server, do **not** deploy the `core-metrics-server` layer. Running two metrics servers will cause conflicts.

## Dependency ordering

Layers form a dependency graph, not a strict linear sequence. Many layers are independent peers that only require `core-base`.

**Layer 0 (no dependencies):**
* `core-crds`: optional, deploy first only if pre-core components need policy exemptions

**Layer 1 (foundation):**
* `core-base`: required before all other layers

**Layer 2 (depend on Base only):**
* `core-identity-authorization`
* `core-metrics-server` (optional; skip if the cluster already provides a metrics server)
* `core-runtime-security`
* `core-logging`
* `core-backup-restore`

**Layer 3 (depend on Base + Identity & Authorization):**
* `core-monitoring`

## Pre-core infrastructure

Some environments, particularly on-prem and edge, need infrastructure components deployed before UDS Core. Load balancer controllers (e.g., MetalLB) and storage operators (e.g., MinIO Operator) are common examples.

If pre-core components need UDS policy exemptions, deploy the **CRDs layer** first. This lets you create `Exemption` custom resources alongside those packages before the policy engine in Base becomes active.

## UDS add-ons

Defense Unicorns offers add-on products that enhance and extend the UDS platform:

| Add-On | What it provides |
| --- | --- |
| **UDS UI** | A common operating picture for Kubernetes clusters and UDS deployments |
| **UDS Registry** | Artifact storage for UDS components and mission applications |
| **UDS Remote Agent** | Remote cluster management and deployment beyond UDS CLI |
