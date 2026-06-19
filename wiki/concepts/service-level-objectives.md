---
title: "Service Level Objectives (SLI / SLO / SLA)"
tags: [sre, slo, sli, sla, reliability, monitoring]
sources: [sre-book-service-level-objectives.md]
updated: 2026-04-24
---

# Service Level Objectives (SLI / SLO / SLA)

## Definitions

| Term | Full name | Definition |
| --- | --- | --- |
| SLI | Service Level Indicator | Quantitative measure of a service behavior (latency p99, error rate, availability %) |
| SLO | Service Level Objective | Target value or range for an SLI; sets user expectations; no contractual consequence |
| SLA | Service Level Agreement | Contract with users including explicit consequences (financial or otherwise) for misses |

Quick test: _"what happens if the target is missed?"_ — no answer → SLO; explicit consequence → SLA.

## SLI Selection by Service Type

| Service type      | Primary SLIs                         |
| ----------------- | ------------------------------------ |
| User-facing       | availability, latency, throughput    |
| Storage           | latency, availability, durability    |
| Big data/pipeline | throughput, end-to-end latency       |
| All systems       | correctness (right answer returned?) |

Not every metric is an SLI. Choose a handful of representative indicators that reflect what users care about.

## Measurement: Percentiles Over Averages

Averages mask tail latency. Use **percentiles**:

- **p50** — typical case
- **p99 / p99.9** — plausible worst-case; user studies show people prefer slightly slower-but-consistent systems

Avoid assuming normal distribution. Timeouts create hard upper bounds; p50 and mean often diverge significantly.

## Setting SLO Targets

- **Don't anchor to current performance** — may require heroic effort to sustain
- **Keep simple** — complex aggregations obscure signals
- **Avoid absolutes** ("always", "infinite") — unattainable and expensive
- **Fewer is better** — only SLOs that win prioritization conversations
- **Iterate** — start loose, tighten as system behavior is understood

## Error Budgets

100% reliability is the wrong target. Define an allowable miss rate (the _error budget_ = 1 − SLO). Budget consumption drives release cadence — when budget is exhausted, slow down deployments. See [Error Budgets](error-budgets.md).

## Safety Margin and Non-Overachievement

- Keep an **internal SLO tighter** than the advertised one — buffer to respond to chronic issues before users notice
- **Don't overachieve**: users depend on _actual_ behavior, not stated SLO. Overperformance creates informal obligations. Google's Chubby team synthesizes planned outages to stay at—not above—their SLO

## Control Loop

```
monitor SLIs → compare to SLOs → decide → act
```

Without the SLO, there is no trigger for action.

## SLI Templates (Standardize)

Reusable defaults reduce per-SLI specification work:

- Aggregation interval: "averaged over 1 min"
- Aggregation region: "all tasks in a cluster"
- Measurement frequency: "every 10 s"
- Request inclusion: "HTTP GETs from black-box monitoring"
- Data acquisition: "measured at server, time to last byte"

## Related Pages

- [Error Budgets](error-budgets.md)
- [Site Reliability Engineering](site-reliability-engineering.md)
- [Prometheus Alerting](prometheus-alerting.md)
- [Observability](observability.md)
- [Runbooks](runbooks.md)
- [Google SRE: Service Level Objectives (source)](../sources/sre-book-service-level-objectives.md)
