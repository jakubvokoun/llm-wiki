---
title: "Kubernetes Observability"
tags:
  [kubernetes, observability, metrics, logs, traces, prometheus, opentelemetry]
sources: [k8s-best-practices-readme.md]
updated: 2026-04-16
---

# Kubernetes Observability

The three pillars of observability in K8s environments: Metrics, Logs, and Traces. Good observability is required for debugging, alerting, and capacity planning.

## The Three Pillars

| Pillar      | Purpose                                                       | Common Tools                   |
| ----------- | ------------------------------------------------------------- | ------------------------------ |
| **Metrics** | Quantitative data over time (latency, error rate, saturation) | Prometheus, Grafana, Datadog   |
| **Logs**    | Event records for debugging and audit                         | Loki, ELK Stack, Cloud Logging |
| **Traces**  | Request flow across services (distributed tracing)            | Jaeger, Tempo, Zipkin          |

## Metrics: Prometheus + Grafana

Standard K8s observability stack. Prometheus scrapes metrics; Grafana visualizes.

```yaml
# ServiceMonitor tells Prometheus how to scrape your app
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
    - port: metrics
      path: /metrics
      interval: 30s
```

App requirements:

- Expose `/metrics` endpoint in Prometheus text format
- Set up alerting rules (PrometheusRule CRD)
- Create Grafana dashboards for key business and technical metrics

## Logs

- Write structured JSON to **stdout/stderr** — never to files inside the container
- Centralize with Loki (lightweight, label-indexed) or ELK (heavier, full-text search)
- Include correlation IDs in every log entry to link with traces
- Security log events should flow to SIEM — see [Security Logging](security-logging.md)

## Traces (Distributed Tracing)

- Instrument with [OpenTelemetry](https://opentelemetry.io/) (vendor-agnostic SDK)
- Propagate trace context across service calls (W3C TraceContext header)
- Store in Jaeger, Grafana Tempo, or Zipkin

## Instrumentation Best Practices

- Use **OpenTelemetry** for all three pillars — single SDK, multiple backends
- Include `correlation_id` / `trace_id` in logs and metrics labels to correlate across pillars
- Add standard K8s labels (`app`, `version`, `namespace`) as metric labels for filtering
- Set up alerting for SLOs (latency p99, error rate, availability)

## Related Concepts

- [Security Logging](security-logging.md)
- [Kubernetes Security](kubernetes-security.md)
- [Service Mesh](service-mesh.md)

## Sources

- [Kubernetes Best Practices 101](../sources/k8s-best-practices-readme.md)
