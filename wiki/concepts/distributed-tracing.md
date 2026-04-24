---
title: "Distributed Tracing"
tags: [observability, tracing, microservices, opentelemetry, sre]
sources: [group107-infrastructure-monitoring-best-practices.md]
updated: 2026-04-24
---

# Distributed Tracing

Distributed tracing tracks a single request's complete journey through all microservices and components, enabling engineers to pinpoint latency and errors across service boundaries — something metrics and logs alone cannot do in distributed systems.

## Core Concepts

- **Trace** — the complete record of a single request's lifecycle across all services
- **Span** — a single unit of work within a trace (one service operation); spans have duration, status, and metadata
- **Parent span** — the root operation (e.g., incoming HTTP request)
- **Child spans** — downstream calls (DB queries, cache lookups, third-party API calls, inter-service RPC)
- **Trace context** — a propagated header (`traceparent` in W3C format) that links spans across service boundaries

## Tracing vs Metrics vs Logs

| Data Type | Question answered         | Granularity   | Volume |
| --------- | ------------------------- | ------------- | ------ |
| Metrics   | What is slow?             | Aggregated    | Low    |
| Logs      | What happened?            | Event-level   | High   |
| Traces    | Where is it slow and why? | Request-level | Medium |

Traces are most valuable when **correlated** with logs (jump from slow span → relevant log events) and metrics (see which span contributes to latency percentiles).

## OpenTelemetry

**OpenTelemetry (OTel)** — CNCF standard for instrumentation APIs and SDKs. Avoids vendor lock-in:

- Single instrumentation → multiple backends (Jaeger, Zipkin, Datadog, Grafana Tempo)
- Provides trace, metric, and log collection in a unified SDK
- Use `ServiceMonitor` / OTel Collector for Kubernetes environments

## Sampling Strategies

Tracing 100% of traffic in production is expensive. Two approaches:

| Strategy       | Decision point   | Advantage                                    | Limitation                         |
| -------------- | ---------------- | -------------------------------------------- | ---------------------------------- |
| **Head-based** | Start of request | Low overhead, predictable cost               | Can miss rare errors               |
| **Tail-based** | End of request   | Capture all errors and high-latency requests | Higher overhead (buffer all spans) |

Typical rates: 1–10% of traffic. Always capture 100% of errors.

## Implementation Best Practices

- Use **OTel** SDKs for all new services; avoid vendor-specific instrumentation
- Propagate trace context through all service calls (HTTP headers, message queue metadata)
- Correlate traces with structured logs: include `trace_id` and `span_id` in all log entries
- Implement **tail-based sampling** for error capture; supplement with head-based for volume control
- Monitor trace **completeness** — dropped spans indicate instrumentation gaps

## Related Pages

- [Observability](../concepts/observability.md)
- [Application Performance Monitoring](../concepts/application-performance-monitoring.md)
- [Kubernetes Observability](../concepts/kubernetes-observability.md)
- [Microservices Security](../concepts/microservices-security.md)
- [Security Logging](../concepts/security-logging.md)
