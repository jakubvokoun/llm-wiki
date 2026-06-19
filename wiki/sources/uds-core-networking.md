---
title: "UDS Core — Networking & Service Mesh"
tags:
  [uds-core, istio, service-mesh, mtls, zero-trust, networking, ambient-mode]
sources: [uds-core-networking.md]
updated: 2026-05-07
---

# UDS Core — Networking & Service Mesh

UDS Core uses [Istio](../entities/istio.md) as its service mesh. The mesh is not optional infrastructure — it is the security boundary that makes zero-trust networking practical without requiring application teams to manage TLS certificates or write network policies by hand.

## Why a service mesh?

Traditional K8s network security relies on IP-based `NetworkPolicy` rules, which break down at scale (dynamic IPs, hard-to-audit policies, no automatic east-west encryption). Istio solves this via a transparent proxy layer:

- **mTLS for all in-cluster traffic** — every connection authenticated and encrypted; workload identity via SPIFFE certificates derived from K8s service accounts
- **Authorization policies** — deny-all by default; opened only through explicit `Package` CR declarations
- **Ingress/egress control** — all external traffic flows through Istio gateways

## Ambient vs. sidecar mode

| Mode              | Proxy location                          | Resource overhead | L7 policy               |
| ----------------- | --------------------------------------- | ----------------- | ----------------------- |
| Ambient (default) | Node-level ztunnel + optional waypoints | Lower (shared)    | Requires waypoint proxy |
| Sidecar           | Per-pod Envoy sidecar                   | Higher (per pod)  | Always available        |

**Ambient mode** is the default. It reduces overhead, allows upgrading the data plane without restarting application pods, and is Istio's long-term investment direction. When Authservice is enabled, the operator automatically provisions a waypoint proxy for L7 policy enforcement.

## Ingress gateways

| Gateway         | Required | Purpose                                                                       |
| --------------- | -------- | ----------------------------------------------------------------------------- |
| **Tenant**      | Yes      | End-user application traffic; TLS termination                                 |
| **Admin**       | Yes      | Admin interfaces (Grafana, Keycloak admin console); separate controls         |
| **Passthrough** | No       | TLS passed to application for its own termination; must be explicitly enabled |

The Tenant/Admin gateway split exists because each has a different threat model: Admin should be restricted to trusted networks; Tenant is the public ingress.

## Application traffic flow

### Ingress via `expose` block

```yaml
spec:
  network:
    expose:
      - service: my-app-service
        selector:
          app: my-app
        host: my-app
        gateway: tenant
        port: 8080
```

The UDS Operator generates an Istio `VirtualService` and `AuthorizationPolicy`. Application teams never write Istio YAML directly.

### Egress via `allow` block

```yaml
spec:
  network:
    allow:
      - direction: Egress
        remoteHost: api.example.com
        port: 443
```

Egress is deny-all by default. Requiring explicit declarations makes external dependencies auditable and prevents data exfiltration via unknown outbound connections.

## Authorization policy model

Istio in UDS Core defaults to **deny-all ingress**. Traffic is permitted only when an explicit `ALLOW` policy exists. Platform components (Prometheus scraping, log collection) have pre-configured allow policies.

## Trust and certificate management

UDS Core includes a trust bundle mechanism that propagates CA certificates to platform components (including Keycloak), ensuring TLS-dependent flows work in air-gapped environments with internally-issued certificates.

## Related pages

- [Service Mesh](../concepts/service-mesh.md)
- [Zero Trust Architecture](../concepts/zero-trust.md)
- [UDS Package CR](../concepts/uds-package-cr.md)
- [Istio](../entities/istio.md)
- [Network Policy](../concepts/network-policy.md)
