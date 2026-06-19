---
title: "CVSS v4.0 User Guide"
tags: [cvss, severity, first, vulnerability, scoring]
sources: [cvss-v4-user-guide.md]
updated: 2026-06-19
---

# CVSS v4.0 User Guide

[FIRST](../entities/first.md)'s companion to the [specification](cvss-v4-specification-document.md): explains _how to score_, what changed from v3.1, and supplies assessment rubrics.

## Changes in v4.0

- **Nomenclature** (CVSS-B / -BT / -BE / -BTE) makes explicit which metric groups produced a score.
- **Base Score measures severity, not risk** — reinforced throughout (see [CVSS](../concepts/cvss.md#severity-≠-risk)).
- **Scope removed**, replaced by Vulnerable vs Subsequent System impacts.
- New/revised Base metrics: **Attack Requirements (AT)** and three-level **User Interaction**.
- **Temporal → Threat**; Remediation Level and Report Confidence dropped, emphasis on real-world Exploit Maturity.
- Updated vector version identifier (`CVSS:4.0/…`).

## Assessment guidance

- Use the **reasonable worst-case** scenario, especially for **library/component** vulnerabilities — assume maximum exposure and privilege unless implementation details say otherwise.
- Multiple CVSS-B scores are acceptable for a vuln affecting different platforms/versions, each with context about where it applies.
- Detailed scoring rubrics for the Base metrics, plus 13 scenario subsections in the Assessment Guide.

## Supplemental metrics (context only)

Safety, Automatable, Provider Urgency, Recovery, Value Density, Vulnerability Response Effort — the consumer decides how (or whether) to weight each; none changes the numeric score.

## See also

- [CVSS](../concepts/cvss.md) · [Specification](cvss-v4-specification-document.md) · [Implementation Guide](cvss-v4-implementation-guide.md) · [Examples](cvss-v4-examples.md) · [FAQ](cvss-v4-faq.md)
- [FIRST](../entities/first.md)
