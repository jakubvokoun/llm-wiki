---
title: "EPSS (Exploit Prediction Scoring System)"
tags: [epss, vulnerability, prioritization, first, risk]
sources: [cvss-v4-faq.md]
updated: 2026-06-19
---

# EPSS (Exploit Prediction Scoring System)

A [FIRST](../entities/first.md)-maintained, data-driven framework that estimates the **probability that a vulnerability will be exploited in the wild** (typically within the next 30 days), expressed as a 0–1 score.

## EPSS vs CVSS

Different questions, complementary answers:

- **[CVSS](cvss.md)** — _how severe?_ (intrinsic technical impact)
- **EPSS** — _how likely to be exploited?_ (empirical threat likelihood)

Per the [CVSS v4.0 FAQ](../sources/cvss-v4-faq.md), EPSS is **not a replacement** for CVSS. A mature prioritization process combines severity (CVSS), exploit likelihood (EPSS), and decision logic ([SSVC](ssvc.md)) rather than relying on any single number.

## Related

- [CVSS](cvss.md) · [SSVC](ssvc.md) · [Vulnerability Handling](vulnerability-handling.md)
- [FIRST](../entities/first.md)
