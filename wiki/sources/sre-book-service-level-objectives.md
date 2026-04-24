---
title: "SRE Book — Chapter 4: Service Level Objectives"
tags: [sre, slo, sli, sla, reliability, monitoring]
sources: [sre-book-service-level-objectives.md]
updated: 2026-04-24
---

# SRE Book — Chapter 4: Service Level Objectives

Authors: Chris Jones, John Wilkes, Niall Murphy, Cody Smith

## Key Takeaways

**SLI/SLO/SLA are distinct concepts:**

- **SLI** (indicator) — quantitative measure of service behavior (latency, error rate, availability, throughput)
- **SLO** (objective) — target value/range for an SLI; sets expectations for users
- **SLA** (agreement) — contract with explicit consequences (financial or otherwise) if SLOs are missed

**SLI selection by service type:**

| Service type      | Key SLIs                                  |
| ----------------- | ----------------------------------------- |
| User-facing       | availability, latency, throughput         |
| Storage           | latency, availability, durability         |
| Big data/pipeline | throughput, end-to-end latency            |
| All systems       | correctness (was the right answer given?) |

**Prefer percentiles over averages:** Averages mask tail latency. Use 50th percentile for typical case, 99th/99.9th for worst-case. Users prefer slightly slower systems to high-variance ones.

**SLO target-setting rules:**

- Don't lock into current performance — that may require heroic efforts to maintain
- Keep it simple — complex aggregations obscure problems
- Avoid absolutes ("always available", "infinite scale")
- Have as few SLOs as possible — only ones that can win prioritization conversations
- Start loose, tighten over time

**Safety margin and non-overachievement:**

- Maintain a tighter _internal_ SLO than the advertised one (buffer for chronic problems)
- Deliberately don't overachieve: if actual performance exceeds SLO, users depend on the higher bar (Chubby planned outages example)

**Error budgets:** 100% reliability is the wrong target. Missing SLOs at a defined rate (error budget) is acceptable; the gap against budget informs release cadence. An error budget is an SLO for meeting other SLOs.

**Control loop:** monitor SLIs → compare to SLOs → decide on action → act.

## Notable Example

Google's **Chubby** lock service was so reliable that services took hard dependencies on it despite no formal guarantee. SRE response: synthesize controlled outages so the actual SLO is met but not significantly exceeded — flushing out unreasonable dependencies.

## Related Pages

- [Service Level Objectives](../concepts/service-level-objectives.md)
- [Error Budgets](../concepts/error-budgets.md)
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
- [Prometheus Alerting](../concepts/prometheus-alerting.md)
