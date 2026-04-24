---
title: "IT Monitoring: An Introductory Guide With 5 Monitoring Strategies (SUSE)"
tags: [monitoring, observability, sre, devops, infrastructure]
sources: [suse-observability-monitoring-strategies.md]
updated: 2026-04-24
---

# IT Monitoring: An Introductory Guide With 5 Monitoring Strategies (SUSE)

Source: SUSE blog, by Andreas Prins.

## Key Metrics

Four universal monitoring metrics:

| Metric                   | Purpose                                |
| ------------------------ | -------------------------------------- |
| **Response time**        | Detect slowdowns; optimize performance |
| **Throughput**           | Ensure system handles required load    |
| **Error rate**           | Identify and fix problems              |
| **Resource utilization** | Prevent overload (CPU, memory)         |

## Five Monitoring Strategies

### 1. Business-Critical Apps Monitoring

Start here. Identify apps essential to business and customer experience. Ask: which app failures cause the most harm, and what KPIs matter most?

### 2. Performance Monitoring

Track system loads, response times, resource usage, logs, and data anomalies for your critical apps. APM tooling automates this.

### 3. Infrastructure Monitoring

Monitor the infrastructure supporting critical apps: network issues, bandwidth, configuration drift, unusual traffic patterns.

### 4. Security Monitoring

Continuously monitor security posture. Key metrics: false positive rate, time-to-detect (MTTD), time-to-address (MTTI), open-source CVE exposure.

### 5. Change Monitoring

Track changes to system configurations, code deployments, and app lifecycles. Also monitor VCS commit cadence and CI/CD pipeline health.

## Best Practices

- Build dashboards that provide a holistic view; avoid monitoring sprawl across multiple siloed tools
- Build high-quality alerts in code to minimize **MTTD** (mean time to detect) and **MTTI** (mean time to isolate)
- Document previous incidents and outcomes; build monitors _before_ incidents happen
- Automate responses to alerts — notify teams automatically, trigger workflows
- Continuously measure whether monitoring KPIs are being met; adjust KPIs if unrealistic

## Monitoring vs Observability

Monitoring answers: "Is it working? Is performance acceptable?"

Monitoring does **not** answer:

- _Why_ is the system not working?
- _What_ change caused the incident?
- _How_ did the change propagate through component interdependencies?
- _How_ can I proactively prevent incidents?

**Observability** is the natural next step — it provides root-cause pinpointing and proactive prevention beyond the binary pass/fail of monitoring.

## Related Pages

- [Observability](../concepts/observability.md)
- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Kubernetes Observability](../concepts/kubernetes-observability.md)
- [Security Logging](../concepts/security-logging.md)
