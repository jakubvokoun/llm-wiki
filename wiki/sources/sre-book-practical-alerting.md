---
title: "SRE Book — Chapter 10: Practical Alerting from Time-Series Data"
tags: [sre, monitoring, alerting, borgmon, prometheus, timeseries, google]
sources: [sre-book-practical-alerting.md]
updated: 2026-04-24
---

# SRE Book — Chapter 10: Practical Alerting from Time-Series Data

Written by Jamie Wilkinson, edited by Kavita Guliani.

Describes Google's internal monitoring system Borgmon — the direct predecessor to Prometheus — and the time-series-based alerting paradigm that replaced traditional check scripts.

## The Problem with Traditional Monitoring

Traditional approach: custom scripts that check responses and alert, wholly separated from visual display of trends. Problems at scale:

- Too noisy at machine granularity (single-machine failures are not actionable)
- Check scripts don't retain history
- No rich computation over time-series

## Borgmon: The Architecture

Borgmon (2003) was built to complement Borg (Google's job scheduler). It:

1. Standardizes metrics collection via HTTP `/varz` endpoint (text format, space-separated `key value` pairs)
2. Stores data in an in-memory **time-series arena** (~24 bytes/point; 12-hour horizon for ~17 GB/million series at 1-min interval)
3. Periodically archives to external **TSDB** (Time-Series Database) for long-term storage
4. Evaluates **rules** (algebraic expressions over time-series) to create new derived time-series
5. Sends **Alert RPCs** to Alertmanager when alert rules are true for a minimum duration

## varz Format

```
http_requests 37
errors_total 12

# Map-valued (with labels):
http_responses map:code 200:25 404:0 500:12
```

Borgmon fetches `/varz` on each target at predefined intervals. Also records synthetic variables: was name resolved? did target respond? did health check pass?

## Time-Series Model

Each time-series is named by a **labelset** (`key=value` pairs). Required labels:

| Label     | Meaning                            |
| --------- | ---------------------------------- |
| `var`     | Variable name                      |
| `job`     | Type of server being monitored     |
| `service` | Loosely defined collection of jobs |
| `zone`    | Physical location (datacenter)     |

A query without all labels returns all matching time-series as a **vector**.

## Rule Evaluation

Rules are algebraic expressions creating new time-series. Google naming convention: `level:metric:operations` (e.g., `task:http_requests:rate10m`).

```
{var=task:http_requests:rate10m,job=webserver} =
  rate({var=http_requests,job=webserver}[10m]);

{var=dc:http_requests:rate10m,job=webserver} =
  sum without instance({var=task:http_requests:rate10m,job=webserver})
```

**Counter vs Gauge**: Prefer counters (monotonically non-decreasing) — they don't lose meaning between sampling intervals. Gauges show current state and may miss activity between samples.

**Aggregation**: Sum of rates (not rate of sums) — defends against counter resets and missing data.

## Alerting

Alerting rules include:

- A boolean expression over time-series
- A **minimum duration** (`for 2m`) to avoid flapping
- Template variables for contextual details (`%trigger_value%`)
- Labels to route (e.g., `severity=page`)

```
{var=dc:http_errors:ratio_rate10m,job=webserver} > 0.01
  and by job, error
{var=dc:http_errors:rate10m,job=webserver} > 1
  for 2m
  => ErrorRatioTooHigh
    details "webserver error ratio at %trigger_value%"
    labels { severity=page };
```

Alerts go to **Alertmanager** which handles: inhibition, deduplication, fan-in/fan-out.

## Sharding the Monitoring Topology

Borgmon can collect from other Borgmon. Typical deployment:

- One Borgmon per datacenter (scraping all jobs)
- Two or more global Borgmon (aggregation + diversity)
- Large services: scraping-only shards → DC aggregation → global

Upper-tier Borgmon filter data to avoid filling their arena with per-task time-series.

## White-Box vs Black-Box Monitoring

| Type          | What it sees                                     | Limitation                                      |
| ------------- | ------------------------------------------------ | ----------------------------------------------- |
| **White-box** | Internal state; exported metrics                 | Misses DNS failures, requests that never arrive |
| **Black-box** | External behavior (Prober sends protocol checks) | Less granular; slower to identify root cause    |

Prober = Google's black-box monitoring tool. Validates response payloads, exports histograms of response times. Can target frontend domain or backends independently to localize failures.

## Configuration and Templating

- Rules are separate from target definitions → same rules apply to many targets
- Language templates (macros) enable reusable rule libraries
- CI service validates, packages, and ships config to all Borgmon in production
- Two library classes: variable schema (per code library) and aggregation topology (per service structure)

## Legacy and Influence

Borgmon's paradigm (time-series as first-class data, mass collection, rich rule evaluation) became the foundation for:

- **Prometheus** (most direct successor; shares rule language concepts)
- **Riemann**, **Heka**, **Bosun** (open-source contemporaries)

> Ensuring that the cost of maintenance scales sublinearly with the size of the service is key to making monitoring maintainable.

## Related Pages

- [Borgmon](../concepts/borgmon.md)
- [Prometheus](../entities/prometheus.md)
- [Prometheus Instrumentation](../concepts/prometheus-instrumentation.md)
- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Alertmanager](../concepts/alertmanager.md)
- [Observability](../concepts/observability.md)
- [Four Golden Signals](../concepts/four-golden-signals.md)
