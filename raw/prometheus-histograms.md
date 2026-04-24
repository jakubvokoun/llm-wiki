# Histograms and Summaries in Prometheus

## Core Recommendation

The document establishes a clear priority: "If you can, use native histograms and prefer them over both classic histograms and summaries."

## Two Fundamental Approaches to Distribution Representation

Prometheus supports two different methodologies for tracking distributions of observed values:

1. **Summaries**: The instrumented program pre-calculates quantiles over fixed time windows and exposes them as additional metrics. This approach offers accuracy but prevents later recalculation with different parameters or across aggregated instances.

2. **Histograms**: The program represents distributions through bucketed counts, enabling arbitrary quantile calculations later and allowing aggregation across sources.

## Histogram Variants

Three histogram types exist:

- **Native Histograms**: Use composite samples with dynamic exponential buckets, offering the most flexibility and efficiency
- **Classic Histograms**: Employ fixed, pre-configured bucket boundaries, creating separate time series per bucket
- **Native Histograms with Custom Bucket boundaries (NHCB)**: Allow ingesting classic histograms as native histograms on the server side

## Key Operational Differences

**Quantile Aggregation**: Summaries cannot be meaningfully aggregated across instances, while histograms support this through PromQL functions. The document emphasizes that "aggregating the precomputed quantiles from a summary rarely makes sense."

**Flexibility**: Native histograms enable ad-hoc specification of percentiles and time windows via PromQL, whereas summaries require these selections during instrumentation.

**Accuracy**: Native histograms with appropriate resolution provide superior quantile estimates compared to classic histograms with fixed buckets, particularly when actual values drift from anticipated ranges.

## Practical Guidance

For organizations unable to adopt native histograms immediately, ingesting classic histograms as NHCBs provides a transitional path that delivers significantly better storage efficiency than pure classic histogram approaches while maintaining query compatibility.
