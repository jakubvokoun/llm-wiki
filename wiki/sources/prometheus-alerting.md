---
title: "Prometheus Alerting Best Practices"
tags: [prometheus, alerting, monitoring, observability, SRE]
sources: [prometheus-alerting.md]
updated: 2026-04-24
---

# Prometheus Alerting Best Practices

Official Prometheus guidance on writing effective alerts. Based on Rob Ewaschuk's _My Philosophy on Alerting_ from his time at Google.

## Core philosophy

Alert on **symptoms** (end-user pain), not causes. Keep alerting simple. Provide good consoles to allow pinpointing causes. Avoid pages where there is nothing to do.

## Naming

Community convention: **CamelCase** for alert names (e.g. `HighErrorRate`, `BatchJobFailed`). No strict restriction; any Unicode is valid.

## What to alert on

### Online serving systems

- Alert on **high latency and error rates** as high up the stack as possible
- Only page on latency at **one level** of the stack — if user-facing latency is fine, no need to page on a slow lower-level component
- Page on **user-visible errors**; add separate pages only for severe non-visible failures (e.g. significant revenue loss)
- Use separate alerts for request types with very different characteristics

### Offline processing

- Key metric: **pipeline lag** — how long data takes to get through the system
- Page when lag becomes high enough to cause user impact

### Batch jobs

- Page if the job has not succeeded recently enough to cause user-visible problems
- Threshold: at least **2× the full run duration** (e.g. 4h job running every 4h → 10h threshold)
- If a single failure is unacceptable, run the job more frequently; a single failure should not require human intervention

### Capacity

- Not immediate impact, but requires human intervention to prevent a near-future outage

### Metamonitoring

- Alert on the monitoring infrastructure itself: Prometheus, Alertmanager, Pushgateway
- Prefer **symptom-based blackbox end-to-end tests** over individual component checks (e.g. "alert flows from Pushgateway → Prometheus → Alertmanager → email" beats three separate component alerts)
- Supplement internal monitoring with external blackbox monitoring as a fallback

## Key takeaway

> Alert on symptoms, not causes. Have as few alerts as possible. Link alerts to consoles so the cause can be pinpointed quickly.

## See also

- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Prometheus Instrumentation Practices](prometheus-instrumentation.md)
- [Prometheus](../entities/prometheus.md)
