---
title: "Observability"
tags: [observability, monitoring, sre, devops, borgmon, prometheus, google]
sources:
  [
    suse-observability-monitoring-strategies.md,
    sre-book-introduction.md,
    sre-book-practical-alerting.md,
  ]
updated: 2026-04-24
---

# Observability

Observability is the ability to understand the internal state of a system from its external outputs. It goes beyond traditional monitoring by answering _why_ a system is failing, not just _whether_ it is failing.

## Monitoring vs Observability

| Dimension         | Monitoring                             | Observability                                 |
| ----------------- | -------------------------------------- | --------------------------------------------- |
| Question answered | "Is it working?"                       | "Why isn't it working?"                       |
| Scope             | Known failure modes                    | Unknown failure modes                         |
| Approach          | Threshold alerts on predefined metrics | Exploratory analysis of logs/traces/metrics   |
| Root cause        | Limited                                | Pinpoints root cause through correlation      |
| Proactive         | Reactive (alert after failure)         | Proactive (detect degradation before failure) |

## Three Pillars

1. **Metrics** — numeric measurements over time (Prometheus, Datadog, etc.)
2. **Logs** — timestamped event records with structured context
3. **Traces** — distributed request flows across service boundaries (Jaeger, Tempo)

Together these enable root-cause analysis without having to reproduce the issue.

## Key SRE Metrics

- **MTTD** (Mean Time to Detect) — time from incident start to alert firing
- **MTTI** (Mean Time to Isolate) — time from alert to identifying the root cause
- **MTTR** (Mean Time to Recover) — time from detection to resolution

## Monitoring Strategies

From the SUSE guide, five common strategies to build out progressively:

1. Business-critical app monitoring (start here)
2. Application performance monitoring (APM)
3. Infrastructure monitoring
4. Security monitoring
5. Change monitoring (config drift, CI/CD pipeline health)

## Google SRE monitoring output types

From the SRE book: software should interpret monitoring, not humans. Three valid outputs:

| Output     | Urgency         | Meaning                                                       |
| ---------- | --------------- | ------------------------------------------------------------- |
| **Alert**  | Immediate       | Human must act now                                            |
| **Ticket** | Within days     | Human needed, system can wait                                 |
| **Log**    | None (forensic) | Recorded for diagnosis; nobody reads unless prompted to do so |

## White-Box vs Black-Box Monitoring

From Google's Borgmon experience:

| Type          | What it inspects                            | Catches                                | Misses                           |
| ------------- | ------------------------------------------- | -------------------------------------- | -------------------------------- |
| **White-box** | Internal state via exported metrics (varz)  | Component-level issues; queues; causes | DNS failures; pre-server crashes |
| **Black-box** | External behavior (Prober: protocol checks) | User-visible failures                  | Internal component state         |

Both are necessary. White-box provides granularity for root-cause analysis; black-box catches what users actually experience. Use both, pointed at frontend and backends independently, to localize failures.

## Historical Context: Borgmon → Prometheus

The modern time-series monitoring paradigm was pioneered by Google's **Borgmon** (2003), which shifted from check scripts to:

- Mass metric collection via HTTP endpoints
- Time-series storage with labeled dimensions
- Rich algebraic rule evaluation for alerts and dashboards

Prometheus (2012, open source) is the most direct descendant. See [Borgmon](borgmon.md).

## Related Pages

- [Kubernetes Observability](../concepts/kubernetes-observability.md)
- [Prometheus Instrumentation](../concepts/prometheus-instrumentation.md)
- [Security Logging](../concepts/security-logging.md)
- [DORA Metrics](../concepts/dora-metrics.md)
- [SUSE](../entities/suse.md)
- [Borgmon](../concepts/borgmon.md)
- [Troubleshooting](../concepts/troubleshooting.md)
- [Google SRE: Monitoring Distributed Systems (source)](../sources/sre-book-monitoring-distributed-systems.md)
- [Group107: Infrastructure Monitoring Best Practices (source)](../sources/group107-infrastructure-monitoring-best-practices.md)
