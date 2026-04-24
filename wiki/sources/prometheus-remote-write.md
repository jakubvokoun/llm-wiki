---
title: "Prometheus Remote Write Tuning"
tags: [prometheus, remote-write, WAL, performance, monitoring, thanos]
sources: [prometheus-remote-write.md]
updated: 2026-04-24
---

# Prometheus Remote Write Tuning

## Architecture

```
      |-->  queue (shard_1)   --> remote endpoint
WAL --|-->  queue (shard_...) --> remote endpoint
      |-->  queue (shard_n)   --> remote endpoint
```

- Each remote write destination gets its own queue backed by the local WAL
- If any shard's queue fills, WAL reads block for **all** shards → throughput halts
- Failed sends retried for up to **2 hours**; after that WAL compacts and undelivered data is **lost**
- Prometheus auto-scales shard count based on sample rate, pending samples, and send latency

## Resource impact

- **Memory**: ~25% increase typical; series ID→label cache amplifies churn
- **Shard memory**: `num_shards × (capacity + max_samples_per_send)` — defaults keep this <2 MB/shard
- **CPU + network**: monitor `prometheus_remote_storage_samples_pending` for saturation

## Key `queue_config` parameters

| Parameter              | Description                                | Guidance                                    |
| ---------------------- | ------------------------------------------ | ------------------------------------------- |
| `capacity`             | Samples queued per shard before WAL blocks | 3–10× `max_samples_per_send`                |
| `max_shards`           | Maximum parallel senders                   | Rarely increase; reduce to protect endpoint |
| `min_shards`           | Initial shard count                        | Increase if falling behind at startup       |
| `max_samples_per_send` | Batch size per request                     | Adjust to backend limits                    |
| `batch_send_deadline`  | Max wait before sending underfull batch    | Increase for low-volume systems             |
| `min_backoff`          | Initial retry wait (doubles per failure)   | Increase to spread load on recovery         |
| `max_backoff`          | Maximum retry wait                         | Cap on exponential backoff                  |

## See also

- [Prometheus Remote Write Concept](../concepts/prometheus-remote-write.md)
- [Prometheus](../entities/prometheus.md)
