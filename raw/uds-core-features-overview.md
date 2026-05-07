# Core Features

UDS Core's capabilities are organized into functional areas, each addressing a distinct platform concern. Together, they form an integrated security and observability stack that application teams can rely on without needing to assemble and wire up individually.

Each page explains *what* the feature does and *why* it is built the way it is. For configuration steps, see the corresponding How-to Guides.

## Networking & Service Mesh

mTLS, traffic management, ingress/egress control via Istio. The security boundary that makes zero-trust networking practical.

## Identity & Authorization

SSO, OIDC, and group-based authorization via Keycloak and Authservice, without requiring each application to implement its own auth flow.

## Logging

Centralized log aggregation, durable storage, and log-based alerting via Vector and Loki.

## Monitoring & Observability

Metrics collection, pre-built dashboards, and integrated alerting via Prometheus, Grafana, Alertmanager, and Prometheus Blackbox Exporter.

## Runtime Security

Runtime threat detection inside running containers via Falco, identifying malicious behavior that static configuration controls cannot catch.

## Backup & Restore

Scheduled backup and recovery of Kubernetes resources and persistent volume data via Velero.

## Policy & Compliance

Admission control and pod security enforcement via Pepr, with explicit exemption management for auditable exceptions.
