---
title: "Service Mesh"
tags: [service-mesh, microservices, mtls, security, istio, linkerd, kubernetes]
sources: [owasp-kubernetes-security.md, owasp-microservices-security.md]
updated: 2026-04-15
---

# Service Mesh

A service mesh is a dedicated infrastructure layer for managing service-to-service communication, providing observability, traffic management, and security without changing application code.

## How It Works

A sidecar proxy (e.g., Envoy) is injected alongside each service container. All traffic flows through the sidecar, which handles:

- Mutual TLS (mTLS) — automatic certificate issuance and rotation
- Traffic routing and load balancing
- Observability (metrics, tracing, logs)
- Access policy enforcement (L7)

## Security Benefits

- **Automatic mTLS**: Every service-to-service call is encrypted and mutually authenticated with no code changes
- **L7 policy**: Traffic policies based on HTTP method, path, headers (beyond NetworkPolicy's L3/L4)
- **Access control**: Restrict which services can call which endpoints
- **Observability**: Full call graph visibility for anomaly detection
- **Zero trust enablement**: Makes zero-trust networking practical at scale

## Trade-offs

| Pros                         | Cons                                |
| ---------------------------- | ----------------------------------- |
| Automatic encryption (mTLS)  | Added operational complexity        |
| L7 traffic policy            | Resource overhead (sidecar per pod) |
| Deep observability           | Latency overhead (proxy hop)        |
| Decoupled security from code | Learning curve for teams            |

## Popular Implementations

- **Istio**: Full-featured; uses Envoy sidecar; high complexity
- **Linkerd**: Lighter-weight; Rust-based proxy; simpler ops
- **Consul Connect**: HashiCorp's mesh; works across K8s and VMs
- **AWS App Mesh**: Managed Envoy-based mesh for AWS

## Relationship to Kubernetes

Service meshes complement Kubernetes NetworkPolicy:

- NetworkPolicy: L3/L4 allow/deny by IP/port
- Service mesh: L7 policy by service identity, HTTP attributes
- mTLS from service mesh provides cryptographic service identity (stronger than IP-based)

## Related Concepts

- [kubernetes-security](kubernetes-security.md)
- [microservices-security](microservices-security.md)
- [zero-trust](zero-trust.md)
- [network-policy](network-policy.md)

## Sources

- [OWASP Kubernetes Security Cheat Sheet](../sources/owasp-kubernetes-security.md)
- [OWASP Microservices Security Cheat Sheet](../sources/owasp-microservices-security.md)
