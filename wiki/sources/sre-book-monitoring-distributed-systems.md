---
title: "SRE Book — Chapter 6: Monitoring Distributed Systems"
tags: [sre, monitoring, alerting, observability, four-golden-signals]
sources: [sre-book-monitoring-distributed-systems.md]
updated: 2026-04-24
---

# SRE Book — Chapter 6: Monitoring Distributed Systems

Author: Rob Ewaschuk

## Key Takeaways

**Why monitor:** Long-term trend analysis, A/B comparisons, alerting, dashboards, ad-hoc debugging, capacity planning, security analysis.

**Paging is expensive:** Interrupts workflow at work; interrupts personal time and sleep at home. Alert fatigue → second-guessing, skimming, ignoring real pages. Effective alerting = high signal, very low noise.

**White-box vs black-box monitoring:**

| Type      | What it sees          | Best for                                      |
| --------- | --------------------- | --------------------------------------------- |
| White-box | Internal metrics/logs | Imminent problems, failures masked by retries |
| Black-box | External behavior     | Real, active problems (symptom-oriented)      |

Black-box forces discipline: only page when a problem is real and ongoing. White-box enables early warning.

**Symptoms vs Causes:** Page on symptoms (users affected), not causes (root mechanism). Cause-oriented alerts belong in dashboards, not pagers. "What's broken" vs "why."

**Four Golden Signals:**

| Signal     | Description                                                                                 |
| ---------- | ------------------------------------------------------------------------------------------- |
| Latency    | Time to service a request; track error latency separately — slow errors are worse than fast |
| Traffic    | Demand on the system (requests/s, concurrent sessions, transactions/s)                      |
| Errors     | Rate of failed requests (explicit 500s, implicit wrong content, policy violations)          |
| Saturation | How "full" the service is; leading indicator: p99 latency; predict disk/resource exhaustion |

Measure all four + page on any one being problematic → decent basic coverage.

**Percentiles, not means:** Average latency masks tail behavior. Use histograms with exponentially spaced buckets. p99 of one backend can become p50 of a frontend.

**Resolution:** Match measurement frequency to SLO; probing faster than once/minute is often wasteful for 99.9% SLO services. Use server-side sampling + aggregate externally for high-resolution cheap metrics.

**Monitoring system design — keep it simple:**

- Catch-all rules must be simple, predictable, reliable
- Rarely-triggered rules (< once/quarter) → candidates for removal
- Collected-but-unused signals → candidates for removal
- Avoid magic/ML threshold detection

**Alerting checklist (4 questions):**

1. Does this alert detect an otherwise undetected condition that is urgent, actionable, user-visible?
2. Can this alert ever be safely ignored? If yes, fix that first.
3. Does this alert definitely indicate user impact? Filter out test deployments, drained traffic.
4. Is action required? Is it urgent or can it wait? Could it be automated?

**Paging philosophy:**

- Every page → react with urgency (sustainable only a few times/day)
- Every page → actionable
- Every page → requires intelligence (not robotic response)
- Every page → novel problem or unseen event

**Long-term view:** Rote/algorithmic page responses are a red flag — automate or fix root cause. Controlled short-term availability decrease can buy time for real fixes (Bigtable SLO dial-back example).

## Notable Case Studies

- **Bigtable:** SLO based on mean latency masked a bad tail; voluminous email + page alerts → alert fatigue. Fix: dialed back SLO to p75 temporarily, disabled emails, focused on real fixes.
- **Gmail + Workqueue:** Scheduler bugs generated thousands of individual-task alerts. Automated the "poke" workaround, but tracked tension between hack-vs-fix. Rote responses signal tech debt that must be escalated.

## Related Pages

- [Four Golden Signals](../concepts/four-golden-signals.md)
- [Observability](../concepts/observability.md)
- [Alert Severity Levels](../concepts/alert-severity.md)
- [Prometheus Alerting](../concepts/prometheus-alerting.md)
- [Runbooks](../concepts/runbooks.md)
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
