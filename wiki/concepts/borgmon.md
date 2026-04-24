---
title: "Borgmon"
tags: [monitoring, timeseries, alerting, google, prometheus, sre]
sources: [sre-book-practical-alerting.md]
updated: 2026-04-24
---

# Borgmon

Google's internal time-series-based monitoring system, built in 2003 to complement the Borg scheduler. Borgmon is the architectural predecessor to Prometheus and established the paradigm of mass metric collection + centralized rule evaluation that dominates modern monitoring.

## Core Innovation

**Previous approach**: Custom check scripts per target → alert/report, separate from visualization.

**Borgmon's approach**:

1. Collect metrics from all targets via HTTP `/varz` endpoint (plain text, `key value` pairs)
2. Store as time-series in an in-memory arena with labels
3. Evaluate algebraic rules over time-series to compute derived metrics
4. Generate alerts from rules; route via Alertmanager

This decouples the size of the system being monitored from the size of the alerting rules — the key insight that makes monitoring scale sublinearly.

## varz Format

```
http_requests 37
errors_total 12
http_responses map:code 200:25 404:0 500:12
```

Schemaless textual interface → very low barrier to adding instrumentation. A single variable declaration in code is sufficient.

## Time-Series Model

Time-series are named by **labelsets** (`key=value` pairs):

```
{var=http_requests,job=webserver,instance=host0:80,service=web,zone=us-west}
```

Required labels: `var`, `job`, `service`, `zone`. Additional labels come from target names, the target itself (map-valued variables), Borgmon config, or rules.

Time-series arena: fixed-size in-memory block with garbage collection (expires oldest entries). Typical: ~12-hour horizon at ~24 bytes/data-point. Older data archived to external TSDB.

## Rule Language

Rules are algebraic expressions creating new time-series from existing ones. Naming convention: `level:metric:operations` (e.g., `dc:http_errors:rate10m`).

Rules run in a parallel threadpool (where dependencies allow). Centralized rule evaluation means same rule set can apply to thousands of targets without duplication.

## Alerting

Alert rules have:

- Boolean expression over time-series
- Minimum firing duration (`for 2m`) to suppress transient flapping
- Message templates with context (`%trigger_value%`)
- Labels for routing (`severity=page`)

Alerts go to **Alertmanager** (separate service) which handles inhibition, deduplication, and fan-in/fan-out.

## Monitoring Topology

Borgmon can collect from other Borgmon. Standard hierarchy:

- Per-datacenter Borgmon: scrapes all local jobs
- Two+ global Borgmon: top-level aggregation and diversity
- Large services: additional sharding at datacenter level

Upper tiers filter data from lower tiers — global Borgmon doesn't store per-task time-series.

## White-Box vs Black-Box

Borgmon is a **white-box** monitoring tool (inspects internal state via varz). Google complements it with **Prober** (black-box: sends protocol checks, validates responses, exports time-series) to catch user-visible failures that don't appear in internal metrics.

## Prometheus Connection

Prometheus (open source, ~2012) is the most direct descendant of Borgmon:

| Feature           | Borgmon          | Prometheus                            |
| ----------------- | ---------------- | ------------------------------------- |
| Metric format     | `/varz` text     | `/metrics` OpenMetrics                |
| Rule language     | Borgmon DSL      | PromQL                                |
| Storage           | In-memory + TSDB | TSDB (on-disk)                        |
| Service discovery | BNS              | Multiple adapters                     |
| Alertmanager      | Internal         | Prometheus Alertmanager (open source) |

Also influenced: Riemann, Heka, Bosun.

## Related Pages

- [Prometheus](../entities/prometheus.md)
- [Prometheus Instrumentation](prometheus-instrumentation.md)
- [Prometheus Alerting](prometheus-alerting.md)
- [Alertmanager](alertmanager.md)
- [Observability](observability.md)
- [SRE Book Practical Alerting](../sources/sre-book-practical-alerting.md)
