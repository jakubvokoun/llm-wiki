---
title: "Prometheus Pushgateway"
tags: [prometheus, pushgateway, batch-jobs, monitoring]
sources: [prometheus-pushing.md]
updated: 2026-04-24
---

# Prometheus Pushgateway

An intermediary service allowing metric **push** from jobs that cannot be scraped by Prometheus's pull model.

## When to use

**Only for service-level batch jobs** — jobs not tied to a specific machine or instance. The job's metrics should carry no machine or instance labels.

Example: a nightly cleanup job deleting stale users across the whole service.

## When NOT to use

| Situation                  | Problem                                      |
| -------------------------- | -------------------------------------------- |
| Multiple instances pushing | SPOF + bottleneck                            |
| Long-running services      | Loses `up` metric for health monitoring      |
| Machine-bound batch jobs   | Use Node Exporter textfile collector instead |
| General metrics collection | Use pull scraping                            |

## Key pitfall: stale series

The Pushgateway never automatically discards pushed series. If an instance is renamed or removed, its metrics remain until manually deleted via the API. This is fundamentally different from pull scraping where departed targets disappear automatically.

## Alternatives

- **PushProx**: reverse-proxy enabling Prometheus to scrape through firewall/NAT
- **Node Exporter textfile collector**: for machine-scoped batch job results
- **Move Prometheus behind the barrier**: preferred solution for firewall scenarios

## Related

- [Prometheus Pushing Source](../sources/prometheus-pushing.md)
- [Prometheus Instrumentation](prometheus-instrumentation.md)
- [Prometheus](../entities/prometheus.md)
