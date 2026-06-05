---
title: "FIRST PSIRT Services Framework v1.1"
tags: [psirt, first, vulnerability-handling, incident-response, framework, sdl]
sources: [first-psirt-services-framework.md]
updated: 2026-06-05
---

# FIRST PSIRT Services Framework v1.1

The canonical reference framework from [FIRST](../entities/first.md) defining the services a **[Product Security Incident Response Team](../concepts/psirt.md)** (PSIRT) may provide. A companion to the CSIRT Services Framework, it gives new and maturing teams a service catalogue to build from — not a mandated structure.

## What a PSIRT is

An entity focused on the **identification, assessment, and disposition of risks from security vulnerabilities** in the products an organization produces or sells. A properly deployed PSIRT is **not** a standalone group — it is integrated into the **Secure Development Lifecycle (SDL)**, adding value from requirements/design through the maintenance phase (where most product vulns surface as quality escapes).

## Three operating models

- **Distributed** — small core PSIRT + a matrix of product-team security engineers. Scales across large/diverse portfolios; challenge: fixers don't report to PSIRT.
- **Centralized** — larger dedicated PSIRT staff under a product-security executive. Concentrates expertise; doesn't scale as well as the portfolio grows.
- **Hybrid** — mixes both based on corporate size, portfolio diversity, and development strategy.

PSIRT autonomy matters: it should report to an executive who confirms its authority so it can take an independent position. **Influencers** (legislation, regulation, standards — e.g. the [CRA](../concepts/cyber-resilience-act.md)) often drive PSIRT formation more than named stakeholders.

## Framework structure

Hierarchy of **Service Areas → Services → Functions → Sub-functions**. The six service areas:

1. **Stakeholder Ecosystem Management** — internal stakeholders, finder/researcher community engagement, downstream consumers, metrics.
2. **Vulnerability Discovery** — intake and handling of reports; monitoring vulnerability-intelligence sources.
3. **Vulnerability Triage and Analysis** — qualification, reproduction (with SLAs), storage.
4. **Remediation** — fix development and coordinated release; release metrics.
5. **Vulnerability Disclosure** — advisory production, disclosure, internal-stakeholder comms, metrics.
6. **Training and Education** — training the PSIRT, dev and validation teams, and continuing education for executive/legal/compliance/marketing/PR/sales/support.

## Related

- [PSIRT](../concepts/psirt.md) (concept)
- [FIRST](../entities/first.md)
- [Vulnerability Handling](../concepts/vulnerability-handling.md)
- [GCVE Practical Guide](gcve-vulnerability-handling-disclosure.md) · [Intel PSIRT Process](intel-psirt-vulnerability-handling.md)
