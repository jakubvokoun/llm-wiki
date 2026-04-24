---
title: "Prometheus Histograms and Summaries"
tags: [prometheus, monitoring, histograms, summaries, metrics]
sources: [prometheus-histograms.md]
updated: 2026-04-24
---

# Prometheus Histograms and Summaries

Official Prometheus guidance on choosing between histograms and summaries for distribution tracking (latency, request size, etc.).

## Core Recommendation

> "If you can, use native histograms and prefer them over both classic histograms and summaries."

## Two Approaches

|                            | Summary                         | Histogram                     |
| -------------------------- | ------------------------------- | ----------------------------- |
| Quantile calculation       | Pre-computed in client          | Calculated in PromQL          |
| Cross-instance aggregation | **Not possible**                | Supported                     |
| Bucket configuration       | None needed                     | Must pre-configure boundaries |
| Flexibility                | Low (locked at instrumentation) | High (ad-hoc in PromQL)       |

Summaries: accurate quantiles, but computed over a fixed time window. Cannot aggregate `quantile` across multiple instances — "aggregating the precomputed quantiles from a summary rarely makes sense."

## Histogram Variants

| Type                                               | Buckets                      | Storage                         | Notes                       |
| -------------------------------------------------- | ---------------------------- | ------------------------------- | --------------------------- |
| **Native histogram**                               | Dynamic exponential          | Composite samples               | Best choice                 |
| **Classic histogram**                              | Fixed, pre-configured        | Separate time series per bucket | Legacy                      |
| **NHCB** (Native Histogram with Custom Boundaries) | Ingested as native on server | Efficient                       | Migration path from classic |

Native histograms provide:

- Better quantile accuracy (especially when values drift from anticipated ranges)
- Significantly better storage efficiency vs classic
- Ad-hoc percentile/time window selection via PromQL

## Migration Path

Classic histogram → NHCB → Native histogram. NHCB allows server-side ingestion of classic histograms as native, providing storage benefits while maintaining query compatibility.

## Related Pages

- [Prometheus](../entities/prometheus.md)
- [Prometheus Instrumentation](../concepts/prometheus-instrumentation.md)
- [Prometheus Metric Naming](../sources/prometheus-naming.md)
