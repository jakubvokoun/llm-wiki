---
title: "UDS Core — Logging"
tags: [uds-core, vector, loki, logging, log-aggregation, siem, alerting]
sources: [uds-core-logging.md]
updated: 2026-05-07
---

# UDS Core — Logging

UDS Core provides centralized log aggregation using Vector and Loki. Every workload's logs are collected, shipped to durable storage, and made queryable through Grafana.

## Why centralized logging?

Pod logs are ephemeral — when a pod restarts, its logs disappear. Centralized logging:

- **Persists** logs independently of workload lifecycle
- **Correlates** events across multiple services during incidents
- **Audits** authentication events, policy violations, and system changes
- **Alerts** on error patterns before they surface as user-visible failures

## Logging pipeline

| Component   | Role                                                                                   |
| ----------- | -------------------------------------------------------------------------------------- |
| **Vector**  | DaemonSet log collector; enriches with K8s metadata; ships to Loki                     |
| **Loki**    | Indexes log metadata (not content); stores chunks in object storage; queried via LogQL |
| **Grafana** | Query interface; same instance as metrics dashboards for log/metric correlation        |

## What gets collected

By default, UDS Core collects:

- All container stdout/stderr from every pod in the cluster
- Node logs (`/var/log/*`) and Kubernetes audit logs where available

No opt-in required — any container writing to stdout/stderr is automatically captured.

## Log-based alerting

Loki Ruler evaluates LogQL expressions on a schedule (similar to Prometheus recording rules), enabling:

- **Alert rules** — trigger Alertmanager when a pattern appears (e.g., repeated auth failures)
- **Recording rules** — convert log queries into Prometheus metrics for dashboards

Log-based alerting fills the gap metrics cannot: some failure modes are only visible in log content.

## Storage

Loki stores chunks in S3-compatible object storage in production. Retention policies control how long logs are kept.

## External SIEM integration

Vector can forward logs to Elasticsearch, Splunk, S3 buckets, or any HTTP endpoint in addition to or instead of Loki. Common in environments with existing SIEM infrastructure.

## Related pages

- [Security Logging](../concepts/security-logging.md)
- [Observability](../concepts/observability.md)
- [Grafana](../entities/grafana.md)
- [UDS Core — Runtime Security](uds-core-runtime-security.md)
