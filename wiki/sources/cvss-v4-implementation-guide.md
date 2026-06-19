---
title: "CVSS v4.0 Consumer Implementation Guide"
tags: [cvss, severity, first, vulnerability, maturity, prioritization]
sources: [cvss-v4-implementation-guide.md]
updated: 2026-06-19
---

# CVSS v4.0 Consumer Implementation Guide

A [FIRST](../entities/first.md) guide aimed at **consumers** (not vendors): how to move beyond the published worst-case Base score by applying Threat and Environmental metrics in your own context.

## Key takeaway

The Base score ([CVSS-B](../concepts/cvss.md#nomenclature-label-which-groups-you-used)) is a _starting point_, deliberately worst-case. Real prioritization comes from **enriching** the vector with Threat (exploit maturity) and Environmental (modified base metrics + CIA security requirements) data specific to your deployment.

## Vector enrichment

- **Threat:** populate Exploit Maturity from threat intel — applying it only ever **lowers** the score.
- **Environmental — modified exploitability:** MAV, MAC, MAT, MPR, MUI; **modified impact:** MVC, MVI, MVA; plus **Security Requirements** (CR/IR/AR) reflecting asset criticality. Asset-management systems can supply these systematically.
- Secure network architecture (segmentation, compensating controls) measurably reduces environmental scores — Appendix B works through sample network configurations and their score impact.

## CVSS Maturity Model

A model for _how mature an organization's CVSS practice is_, by how much enrichment data it generates and how automatically:

| Level   | Practice                                               |
| ------- | ------------------------------------------------------ |
| **0**   | Base only (CVSS-B)                                     |
| **1**   | + Threat or limited Environmental                      |
| **2**   | + systematic Environmental                             |
| **3**   | Full Base + Threat + Environmental, automated at scale |
| **"+"** | Maturity-Plus overlay                                  |

Principles weigh **automatability at scale**, **difficulty/cost of obtaining data**, and **level of effort to generate data**.

## See also

- [CVSS](../concepts/cvss.md) · [Specification](cvss-v4-specification-document.md) · [User Guide](cvss-v4-user-guide.md) · [Examples](cvss-v4-examples.md) · [FAQ](cvss-v4-faq.md)
- [Vulnerability Handling](../concepts/vulnerability-handling.md) · [EPSS](../concepts/epss.md) · [SSVC](../concepts/ssvc.md)
