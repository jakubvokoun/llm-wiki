---
title: "Prometheus Remote Write"
tags:
  [
    prometheus,
    remote-write,
    WAL,
    performance,
    thanos,
    victoria-metrics,
    grafana-mimir,
  ]
sources: [prometheus-remote-write.md]
updated: 2026-04-24
---

# Prometheus Remote Write

Prometheus can forward scraped metrics to remote storage backends (Thanos, VictoriaMetrics, Grafana Mimir, Cortex, etc.) via the remote write protocol.

## How it works

1. Metrics written to local **WAL** (write-ahead log) first
2. Remote write queue(s) read from the WAL and send batches to the endpoint
3. Prometheus dynamically adjusts the number of **shards** (parallel senders)
4. Failed sends retried for up to **2 hours**; after that data is lost on WAL compaction

```
WAL → shard queues → remote endpoint
```

## Failure behavior

- If a shard queue fills, WAL reads block for all shards → throughput stops
- Data loss only if remote endpoint is unreachable for >2 hours

## Memory model

- ~25% memory baseline increase
- Series ID→labels cache: high cardinality churn significantly increases memory
- Shard memory: `num_shards × (capacity + max_samples_per_send)` — defaults <2 MB/shard
- When increasing `capacity` or `max_samples_per_send`, reduce `max_shards` to compensate

## Tuning summary

| Goal                       | Parameter to adjust                                |
| -------------------------- | -------------------------------------------------- |
| Prevent WAL blocking       | Increase `capacity` (3–10× `max_samples_per_send`) |
| Protect slow endpoint      | Reduce `max_shards`                                |
| Faster startup throughput  | Increase `min_shards`                              |
| Larger per-request batches | Increase `max_samples_per_send`                    |
| Reduce memory              | Reduce `max_shards` + `capacity` together          |
| Reduce noisy retries       | Increase `min_backoff` / `max_backoff`             |

## Related

- [Prometheus Remote Write Source](../sources/prometheus-remote-write.md)
- [Prometheus](../entities/prometheus.md)
- [Prometheus Instrumentation](prometheus-instrumentation.md)
