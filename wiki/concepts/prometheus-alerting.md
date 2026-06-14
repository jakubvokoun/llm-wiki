---
title: "Prometheus Alerting"
tags:
  [
    prometheus,
    alerting,
    monitoring,
    observability,
    SRE,
    vmalert,
    victoriametrics,
  ]
sources: [prometheus-alerting.md, victoriametrics-alerting-best-practices.md]
updated: 2026-04-24
---

# Prometheus Alerting

Guidelines for writing effective Prometheus alerting rules.

## Core principle

Alert on **end-user pain** (high latency, error rates, availability), not on internal causes. Pages must be actionable — if there is nothing to do, there should be no page.

## Alert naming

Community convention: **CamelCase** names (e.g. `HighLatency`, `BatchJobFailed`).

## Alert types by system

| System type       | What to alert on                                     |
| ----------------- | ---------------------------------------------------- |
| Online serving    | Latency and error rate high in the stack (one level) |
| Offline/streaming | Pipeline lag causing user impact                     |
| Batch jobs        | Job not succeeded within 2× full run duration        |
| Capacity          | Running low; human intervention needed before outage |

## Metamonitoring

Monitor the monitoring stack itself. Prefer symptom-based blackbox end-to-end tests (Pushgateway → Prometheus → Alertmanager → notification) over individual component healthchecks. Supplement with external blackbox monitoring.

## Rule expression tips

- **Lookbehind window:** use at least 4× the scrape interval. Instant queries default to a 5-minute lookback; data points outside that window cause false negatives.
- Aggregate to the right granularity — `max(...) by(job)` instead of per-pod to reduce alert cardinality.

## The `for` param

Prevents flapping: alert fires only after the expression is true for the full `for` duration.

- Set `for` **greater than the lookbehind window** (e.g. `[5m]` window → `for: 10m`).
- Longer `for` = more detection latency; balance against response urgency.

## The `keep_firing_for` param (vmalert)

Keeps an alert active for a specified duration after the expression clears. Prevents premature resolution due to brief data gaps or momentary threshold dips.

## Labels vs annotations

- **Labels** drive routing — avoid dynamic values (e.g. `$value`) that change the label set and reset the `for` duration.
- **Annotations** carry human-readable context (`summary`, `description`, dashboard links) — safe to template with `$value`/`$labels`.

## Noise reduction

- Aggregate by region/service instead of per-replica.
- SLO-based error budgets: alert when budget burns too fast, not on every error.
- Alertmanager inhibition rules: silence downstream alerts when a root-cause alert fires.

## Alert quality checklist

- Symptom-based (not cause-based)
- Actionable — a human can do something right now
- Linked to a dashboard for root cause investigation
- `for` duration set (≥ 5 minutes — see [Zen of Prometheus](prometheus-zen.md)), greater than lookbehind window
- Minimal — no page storm for a single underlying failure
- Labels contain only static routing values, not dynamic metric values

## Related

- [Prometheus Alerting Source](../sources/prometheus-alerting.md)
- [VictoriaMetrics Alerting Best Practices Source](../sources/victoriametrics-alerting-best-practices.md)
- [Awesome Prometheus Alerts](../sources/awesome-prometheus-alerts.md) — 954 ready alert rules across 93 services
- [Prometheus Instrumentation](prometheus-instrumentation.md)
- [Prometheus Recording Rules](prometheus-recording-rules.md)
- [Prometheus Zen](prometheus-zen.md)
- [Prometheus](../entities/prometheus.md)
- [VictoriaMetrics](../entities/victoriametrics.md)
