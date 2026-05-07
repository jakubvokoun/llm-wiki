# Concepts

## What is UDS Core?

UDS Core is a curated collection of platform capabilities packaged as a single deployable Zarf package. It establishes a secure, compliant baseline for cloud-native systems, particularly those operating in highly regulated or air-gapped environments.

> At its heart, UDS Core answers a fundamental question for teams building on Kubernetes: *what secure platform layer do I need before I deploy my application?* UDS Core is that layer.

## How UDS Core is structured

UDS Core is organized into **functional layers**, discrete Zarf packages grouped by capability.

| Layer | What it provides |
| --- | --- |
| `core-crds` | Standalone UDS CRDs (Package, Exemption, ClusterConfig); no dependencies, deploy before base when pre-core components need policy exemptions |
| `core-base` | **Required.** [Istio](https://istio.io/), UDS Operator, [Pepr](https://github.com/defenseunicorns/pepr) Policy Engine |
| `core-identity-authorization` | [Keycloak](https://www.keycloak.org/) + [Authservice](https://github.com/istio-ecosystem/authservice) (SSO) |
| `core-metrics-server` | [Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server) |
| `core-runtime-security` | [Falco](https://falco.org/) + [Falcosidekick](https://github.com/falcosecurity/falcosidekick) |
| `core-logging` | [Vector](https://vector.dev/) + [Loki](https://grafana.com/oss/loki/) |
| `core-monitoring` | [Prometheus](https://prometheus.io/) + [Grafana](https://grafana.com/oss/grafana/) + [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) + [Blackbox Exporter](https://github.com/prometheus/blackbox_exporter) |
| `core-backup-restore` | [Velero](https://velero.io/) |

## The UDS Operator

The UDS Operator is the control plane for UDS Core. The key integration point is the **UDS `Package` custom resource (CR)**. Teams create a `Package` CR declaring networking intent, SSO requirements, and monitoring needs. The operator reconciles the CR and creates all necessary platform resources automatically.

It watches for `Package`, `Exemption`, and `ClusterConfig` custom resources. When a `Package` CR is created or updated, the operator:

* Generates Istio `VirtualService` and `AuthorizationPolicy` resources to control traffic
* Creates Kubernetes `NetworkPolicy` resources to enforce network boundaries
* Configures Keycloak clients for SSO-protected services
* Sets up an Authservice SSO flow to protect mission applications that don't natively implement OIDC
* Creates `ServiceMonitor`, `PodMonitor`, and blackbox probe resources for Prometheus to scrape application metrics

This automation means platform teams don't need to write low-level Istio or Kubernetes networking configuration for each application, nor manually configure SSO for each app. The `Package` CR drives all of it from a single declaration.

## The Policy Engine

The UDS Policy Engine (built on [Pepr](https://github.com/defenseunicorns/pepr)) runs as admission webhooks alongside the operator. It enforces a security baseline across all workloads: preventing privileged containers, enforcing non-root execution, restricting volume types, and more. Policies run as both mutations (automatically correcting safe defaults) and validations (blocking unsafe configurations). For the full list of enforced policies, see the [Policy Engine](/core/reference/operator--crds/policy-engine/) reference.

When a workload legitimately needs an exemption, teams create an `Exemption` CR to declare the exemption explicitly, keeping the audit trail clear.
