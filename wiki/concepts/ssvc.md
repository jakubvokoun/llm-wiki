---
title: "SSVC (Stakeholder-Specific Vulnerability Categorization)"
tags: [ssvc, vulnerability, prioritization, risk, cisa]
sources: [cvss-v4-faq.md]
updated: 2026-06-19
---

# SSVC (Stakeholder-Specific Vulnerability Categorization)

A **decision-tree** methodology (developed at CMU SEI, promoted by [CISA](../entities/cisa.md)) for deciding _what to do_ about a vulnerability. Rather than producing a number, SSVC walks stakeholder-relevant factors — exploitation status, technical impact, automatability, mission/well-being impact — to an **action**: typically _Track / Track\* / Attend / Act_.

## SSVC vs CVSS

- **[CVSS](cvss.md)** — _how severe?_ (a severity number)
- **SSVC** — _what decision should I make?_ (an action, given my role)

Per the [CVSS v4.0 FAQ](../sources/cvss-v4-faq.md), SSVC is **not a replacement** for CVSS; CVSS severity (and [EPSS](epss.md) likelihood) can feed SSVC's decision points. SSVC's strength is making prioritization explicit and role-specific instead of collapsing everything into one score.

## Related

- [CVSS](cvss.md)
- [EPSS](epss.md)
- [Vulnerability Handling](vulnerability-handling.md)
- [Vulnerability Disclosure](vulnerability-disclosure.md)
- [CISA](../entities/cisa.md)
