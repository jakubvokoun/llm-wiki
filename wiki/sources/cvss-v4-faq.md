---
title: "CVSS v4.0 FAQ"
tags: [cvss, severity, first, vulnerability, faq, epss, ssvc]
sources: [cvss-v4-faq.md]
updated: 2026-06-19
---

# CVSS v4.0 FAQ

[FIRST](../entities/first.md)'s answers to recurring [CVSS](../concepts/cvss.md) v4.0 questions (~25 Q&As). Highlights:

## Metric clarifications

- **AC vs AT:** Attack Complexity = the attacker must actively _evade a security-enhancing measure_; Attack Requirements = prerequisite _deployment/execution conditions_ (race condition, on-path position) that aren't there to mitigate attacks. Compensating controls (WAF, CSP) belong in **Environmental** (modified metrics), not Base AC/AT.
- **Vulnerable vs Subsequent System** boundaries, including the tricky XSS and SQL-injection cases (which system is which, and Passive vs Active UI for reflected/stored XSS). CSRF is addressed for the UI metric.
- **Supplemental metrics:** how to consume them given they never change the score.

## Scoring behaviour

- v4.0 deliberately **de-clusters** scores away from High/Critical that plagued v3.1.
- **Threat data only reduces** the score; how to apply threat intel and environmental data into an assessment.
- Why v4.0 and v3.1 scores differ, and how to **derive a v3.1 vector from v4.0**.
- Why one vulnerability can legitimately carry **different scores** (different platforms, different consumers).

## Ecosystem

- **EPSS / SSVC are not replacements** for CVSS — they answer likelihood and decision questions respectively and consume CVSS as input. See [EPSS](../concepts/epss.md), [SSVC](../concepts/ssvc.md).
- Applying CVSS concepts to **AI/LLM** application issues, and how **AIVSS** relates to CVSS.
- CVSS does **not** require a CVE ID; building your own CVSS calculator.

## See also

- [CVSS](../concepts/cvss.md) · [Specification](cvss-v4-specification-document.md) · [User Guide](cvss-v4-user-guide.md) · [Implementation Guide](cvss-v4-implementation-guide.md) · [Examples](cvss-v4-examples.md)
- [EPSS](../concepts/epss.md) · [SSVC](../concepts/ssvc.md) · [CVE](../concepts/cve.md)
