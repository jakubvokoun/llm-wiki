---
title: "Awesome Prometheus Alert Rules"
tags: [prometheus, alerting, alertmanager, copy-pasteable, rules, exporters]
sources: [awesome-prometheus-alerts.md]
updated: 2026-05-22
---

# Awesome Prometheus Alert Rules

A community-curated collection of 954 copy-pasteable Prometheus alerting rules across 112 exporters and 13 categories. Source: samber/awesome-prometheus-alerts on GitHub.

## Coverage by Category

| Category                      | Services | Rules |
| ----------------------------- | -------- | ----- |
| Basic resource monitoring     | 13       | 153   |
| Databases                     | 16       | 184   |
| Message brokers               | 5        | 52    |
| Proxies, LBs & service meshes | 8        | 75    |
| Runtimes                      | 6        | 35    |
| Data engineering              | 3        | 30    |
| Orchestrators                 | 5        | 77    |
| CI/CD                         | 5        | 56    |
| Network and security          | 12       | 70    |
| Storage                       | 4        | 21    |
| Cloud providers               | 4        | 33    |
| Observability                 | 9        | 153   |

## Popular Services

- **Basic**: Prometheus self-monitoring (28), Host & hardware (35, node-exporter), Docker containers (9, cAdvisor), Blackbox (9)
- **Databases**: MySQL (14), PostgreSQL (20), Redis (12), MongoDB (17), Elasticsearch (19), Cassandra (30), ClickHouse (19)
- **Message brokers**: RabbitMQ (21), Kafka (4), NATS (13)
- **Orchestrators**: Kubernetes (37, kube-state-metrics), etcd (13), OpenStack (20)
- **CI/CD**: GitLab CI (30), Jenkins (8), ArgoCD (2), FluxCD (4)
- **Network/security**: Cilium (31), HaProxy (30), SSL/TLS (4), Keycloak (6), Vault (4)
- **Observability**: Thanos (45), Grafana Mimir (49), Grafana Tempo (18), Cortex (6), Loki (4)

## Usage

Rules are designed to be copy-pasted into Prometheus alerting rule files. Each rule is paired with the exporter that exposes the required metrics.

## Related

- [Prometheus Alerting Rules config reference](../sources/prometheus-alerting-rules.md)
- [Prometheus Alerting best practices](../sources/prometheus-alerting.md)
- [Alertmanager concept](../concepts/alertmanager.md)
- [Prometheus entity](../entities/prometheus.md)
