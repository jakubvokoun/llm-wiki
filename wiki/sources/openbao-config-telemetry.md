---
title: "OpenBao — Telemetry Config"
tags: [openbao, configuration, telemetry, metrics, prometheus, monitoring]
sources: [openbao-config-telemetry.md]
updated: 2026-07-03
---

# OpenBao — Telemetry Config

The `telemetry` stanza — publishing [OpenBao](../entities/openbao.md) metrics to upstream monitoring systems.

## Key Takeaways

- Grouped by provider: **statsite**, **statsd**, **Circonus**, **DogStatsD**, **[Prometheus](../entities/prometheus.md)**, and **Stackdriver** (GCP).
- **Common params:** `usage_gauge_period` (`10m`; `none` disables high-cardinality gauges), `maximum_gauge_cardinality`, `disable_hostname`, `enable_hostname_label`, `metrics_prefix` (defaults to `vault`), lease-expiry histogram controls (`lease_metrics_epsilon`, `num_lease_metrics_buckets`), and `prefix_filter` allow/block rules (`+`/`-`).
- **Prometheus:** set `prometheus_retention_time` (`24h`; `0` disables) + `disable_hostname = true`. The `/v1/sys/metrics` endpoint is **active-node only** (enable on standbys via the listener's `unauthenticated_metrics_access`). Scrape with `metrics_path: /v1/sys/metrics`, `params: format: [prometheus]`, and a `bearer_token` (needs `read`,`list` on the path).
- A dedicated hardened metrics [listener](openbao-config-listener-tcp.md) (`metrics_only = true`) is the recommended way to expose metrics separately from API traffic.

## Related

- [Prometheus](../entities/prometheus.md)
- [listener/tcp](openbao-config-listener-tcp.md)
- [Telemetry internals](https://openbao.org/docs/internals/telemetry/)
- [OpenBao](../entities/openbao.md)
