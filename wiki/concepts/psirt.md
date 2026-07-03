---
title: "PSIRT (Product Security Incident Response Team)"
tags: [psirt, incident-response, vulnerability-handling, sdl, first, cvd]
sources:
  [
    first-psirt-services-framework.md,
    intel-psirt-vulnerability-handling.md,
    gcve-vulnerability-handling-disclosure.md,
  ]
updated: 2026-06-05
---

# PSIRT (Product Security Incident Response Team)

The team that handles security vulnerabilities **in the products an organization makes or sells** — identifying, assessing, and dispositioning the risk. Distinct from an enterprise **CSIRT**, which defends the organization's own IT/networks. Defined canonically by the [FIRST PSIRT Services Framework](../sources/first-psirt-services-framework.md).

## Where it sits

Integrated into the **Secure Development Lifecycle (SDL)** — not a standalone group. Most product vulns surface in the maintenance phase as quality escapes, but PSIRTs add value earlier (design, threat modeling). A PSIRT needs **autonomy** and should report to an executive who confirms its authority.

## Operating models

- **Distributed** — small core + product-team security engineers (scales for large portfolios).
- **Centralized** — dedicated team (concentrates expertise; scales less well).
- **Hybrid** — mix, chosen by size/portfolio/strategy.

## What it does (FIRST six service areas)

1. Stakeholder ecosystem management (incl. researcher/finder community)
2. Vulnerability discovery (intake, intel monitoring)
3. Triage and analysis (qualification, reproduction)
4. Remediation (fix + coordinated release)
5. [Disclosure](vulnerability-disclosure.md) (advisories, comms)
6. Training and education

In small/open-source projects the "PSIRT" may just be the core maintainers. [Intel](../sources/intel-psirt-vulnerability-handling.md) is a worked example (Identify → Mitigate → Disclose). **Regulation** (e.g. the [CRA](cyber-resilience-act.md)) is an increasingly dominant influencer on PSIRT formation.

## Related

- [Vulnerability Handling](vulnerability-handling.md)
- [Vulnerability Disclosure](vulnerability-disclosure.md)
- [FIRST](../entities/first.md)
- [CVSS](cvss.md)
- Sources: [FIRST PSIRT Framework](../sources/first-psirt-services-framework.md)
- [Intel PSIRT](../sources/intel-psirt-vulnerability-handling.md)
- [GCVE Guide](../sources/gcve-vulnerability-handling-disclosure.md)
