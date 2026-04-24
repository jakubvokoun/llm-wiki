---
title: "Prometheus — When to use the Pushgateway"
tags: [prometheus, pushgateway, batch-jobs, monitoring]
sources: [prometheus-pushing.md]
updated: 2026-04-24
---

# When to use the Pushgateway

The Pushgateway is an intermediary allowing metrics push from jobs that cannot
be scraped by Prometheus's pull model.

## The three pitfalls

1. **Single point of failure** — multiple pushers route through one service; becomes a bottleneck
2. **Loses `up` metric** — no automatic instance health monitoring via scrape `up`
3. **Never forgets series** — stale metrics persist forever unless manually deleted via the API;
   instance renames/removals leave ghost series

The stale-series problem is fundamental: the Pushgateway lifecycle is decoupled
from the pushing processes, unlike pull scraping where disappeared targets
auto-disappear.

## Only valid use case

**Service-level batch jobs** — jobs not semantically tied to a specific machine
or instance (e.g. a job that deletes stale users for the whole service).

Metrics for such jobs should **not** include machine or instance labels to
decouple their lifecycle from the Pushgateway's cache.

## Alternative strategies

| Scenario                   | Recommended alternative                          |
| -------------------------- | ------------------------------------------------ |
| Behind firewall or NAT     | PushProx (reverse-proxy for Prometheus scraping) |
| Machine-bound batch jobs   | Node Exporter textfile collector                 |
| General metrics collection | Pull scraping (move Prometheus inside network)   |

## See also

- [Prometheus Pushgateway Concept](../concepts/prometheus-pushgateway.md)
- [Prometheus Instrumentation Practices](prometheus-instrumentation.md)
- [Prometheus](../entities/prometheus.md)
