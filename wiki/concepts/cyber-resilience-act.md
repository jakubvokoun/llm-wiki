---
title: "Cyber Resilience Act (CRA)"
tags:
  [
    cra,
    eu,
    regulation,
    product-security,
    vulnerability-management,
    sbom,
    ce-marking,
  ]
sources:
  [
    eu-cra-overview.md,
    eu-cra-reporting.md,
    orcwg-cra.md,
    cra-vulnerability-management.md,
  ]
updated: 2026-06-05
---

# Cyber Resilience Act (CRA)

**Regulation (EU) 2024/2847** — the EU's horizontal cybersecurity law for **products with digital elements** (PDEs: hardware + software placed on the EU market, regardless of where made). Sets mandatory security requirements across the product lifecycle, enforced via **CE marking** and national market-surveillance authorities. Expected to have a **GDPR-like global ripple effect**.

## Timeline

| Date | Milestone |
| --- | --- |
| 10 Dec 2024 | In force |
| 11 Sep 2026 | **Reporting obligations** apply; Single Reporting Platform live |
| 11 Dec 2027 | All main obligations apply |

## Core obligations

- **Secure by design** — PDEs shipped **free of known exploitable vulnerabilities**; vulns remediated "without delay" and disclosed once fixed; security updates available **≥10 years** (or support period; min support 5 years).
- **[Vulnerability handling](vulnerability-handling.md)** — documented process, **SBOM** of at least primary components (regulator-requestable, not necessarily public), single point of contact, and upstream reporting when third-party/OSS components are affected.
- **[Coordinated disclosure](vulnerability-disclosure.md)** — a CVD policy built on ISO/IEC 29147 & 30111; researcher protection and (encouraged) bug bounties.
- **[Reporting](../sources/eu-cra-reporting.md)** — actively exploited vulnerabilities and severe incidents: **24h** early warning → **72h** notification → **14-day** final report, once via the **Single Reporting Platform** to the national [CSIRT](../entities/enisa.md)/[ENISA](../entities/enisa.md).

## Who is affected

**Manufacturers** (anyone placing a product on the EU market); **Open Source Stewards** (lighter, dedicated category); individual **maintainers** only if they **monetize** the project. Reaches the full supply chain — including the ~76% of typical applications that is open source. [Fines are severe](https://eur-lex.europa.eu/eli/reg/2024/2847/oj#art_64).

## Related

- [Vulnerability Handling](vulnerability-handling.md) · [Vulnerability Disclosure](vulnerability-disclosure.md)
- [ENISA](../entities/enisa.md) · [ORCWG](../entities/orcwg.md)
- Sources: [CRA Overview](../sources/eu-cra-overview.md) · [CRA Reporting](../sources/eu-cra-reporting.md) · [ORCWG CRA](../sources/orcwg-cra.md) · [Vulnerability Management Under the CRA](../sources/cra-vulnerability-management.md)
