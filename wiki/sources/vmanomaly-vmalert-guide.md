---
title: "VictoriaMetrics — Anomaly Detection and Alerting Setup (vmanomaly + vmalert)"
tags:
  [
    victoriametrics,
    vmanomaly,
    vmalert,
    anomaly-detection,
    machine-learning,
    alerting,
  ]
sources: [vmanomaly-vmalert-guide.md]
updated: 2026-05-22
---

# VictoriaMetrics — Anomaly Detection and Alerting Setup

End-to-end guide for deploying `vmanomaly` (ML-based anomaly detection) integrated with `vmalert` for alerting. Enterprise feature — requires a license key.

## Architecture

```
node-exporter → vmagent → VictoriaMetrics
                                ↓
                          vmanomaly  (reads metrics, writes anomaly_score)
                                ↓
                          vmalert    (alerts on anomaly_score > threshold)
                                ↓
                          alertmanager → notifications
```

## What Is vmanomaly?

vmanomaly continuously scans VictoriaMetrics time series and detects anomalies using configurable ML models:

- **anomaly_score** (0 to +∞): 0–1 = normal; >1 = anomalous
- **yhat**: predicted expected value
- **yhat_lower** / **yhat_upper**: predicted boundary range
- **y**: original query result

Multiple model types and schedulers per config file (since v1.10.0/v1.11.0).

## vmanomaly Configuration

```yaml
schedulers:
  periodic:
    infer_every: "1m" # how often to generate anomaly scores
    fit_every: "1h" # how often to retrain model
    fit_window: "2d" # training data range (use 2×seasonal cycle minimum)

models:
  prophet:
    class: "prophet"
    args:
      interval_width: 0.98
      weekly_seasonality: False
      yearly_seasonality: False

reader:
  datasource_url: "http://victoriametrics:8428/"
  sampling_period: "60s"
  queries:
    node_cpu_rate:
      expr: "sum(rate(node_cpu_seconds_total[5m])) by (mode, instance, job)"

writer:
  datasource_url: "http://victoriametrics:8428/"

monitoring:
  pull:
    addr: "0.0.0.0"
    port: 8490
```

## vmalert Configuration

```yaml
groups:
  - name: AnomalyExample
    rules:
      - alert: HighAnomalyScore
        expr: "anomaly_score > 1.0"
        labels:
          severity: warning
        annotations:
          summary: Anomaly Score exceeded 1.0 — abnormal behavior detected
```

The threshold (1.0) can be adjusted via Grafana visualization comparing `anomaly_score` with `yhat_lower`/`yhat_upper` boundaries.

## Docker Compose Services

- **victoriametrics**: TSDB + storage
- **vmagent**: scraping (10s interval for node-exporter, vmalert, vmanomaly)
- **vmanomaly**: anomaly detection engine (port 8490)
- **vmalert**: rule evaluation (port 8880)
- **alertmanager**: notification routing (port 9093)
- **grafana**: visualization (port 3000)
- **node-exporter**: CPU/hardware metrics source (port 9100)

## Data Analysis

Example metric: `sum(rate(node_cpu_seconds_total[5m])) by (mode, instance, job)` — 8 time series (one per CPU mode). vmanomaly fits a separate model instance per time series.

Output metric format:

```
anomaly_score{for="node_cpu_rate", instance="node-exporter:9100", mode="idle"} 0.85
```

## Key Tuning Notes

- Initial period produces many anomaly_score > 1 (insufficient training data)
- Full model quality requires ~2 weeks of data (2× weekly seasonality)
- Threshold selection: plot anomaly_score alongside yhat_lower/yhat_upper to calibrate
- vmanomaly exposes `/metrics` endpoint (port 8490) for self-monitoring via Prometheus

## Related

- [VictoriaMetrics vmalert](../sources/victoriametrics-vmalert.md)
- [VictoriaMetrics entity](../entities/victoriametrics.md)
- [Alertmanager concept](../concepts/alertmanager.md)
- [SRE Alerting on SLOs](../sources/sre-alerting-on-slos.md)
