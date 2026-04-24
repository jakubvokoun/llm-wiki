---
title: "SRE Book — Part III: Practices (Overview)"
tags: [sre, practices, reliability, hierarchy, google]
sources: [sre-book-part-iii-practices.md]
updated: 2026-04-24
---

# SRE Book — Part III: Practices (Overview)

Overview chapter introducing the Practices section of the SRE book. Introduces the **Service Reliability Hierarchy** — a Maslow's-analogy framework for understanding service health.

## The Service Reliability Hierarchy

From most basic to most advanced:

| Level                 | Description                                                                        |
| --------------------- | ---------------------------------------------------------------------------------- |
| **Monitoring**        | Without it, you're flying blind; bottom layer of production needs                  |
| **Incident Response** | On-call support; effective troubleshooting; emergency response; managing incidents |
| **Postmortem / RCA**  | Blameless postmortems; outage tracking; learning from failure                      |
| **Testing**           | Test suites to prevent known error classes before production                       |
| **Capacity Planning** | Demand forecasting; load balancing; overload handling; cascading failures          |
| **Development**       | Distributed consensus; cron; data pipelines; data integrity                        |
| **Product**           | Reliable product launches at scale; Day Zero user experience                       |

Each layer depends on the layers below it being solid.

## Key Insight

This hierarchy was developed when Google SREs (including Mikey Dickerson) joined the US government to help with the healthcare.gov launch in 2013–2014. They needed a way to explain how to systematically increase systems' reliability — and found that teams were trying to skip levels.

Mikey Dickerson later became the first administrator of the US Digital Service, bringing SRE principles to US government IT systems.

## Chapter Map (Part III)

| Chapter   | Topic                                    |
| --------- | ---------------------------------------- |
| Ch. 10    | Practical Alerting from Time-Series Data |
| Ch. 11    | Being On-Call                            |
| Ch. 12    | Effective Troubleshooting                |
| Ch. 13    | Emergency Response                       |
| Ch. 14    | Managing Incidents                       |
| Ch. 15    | Postmortem Culture                       |
| Ch. 16    | Tracking Outages                         |
| Ch. 17    | Testing for Reliability                  |
| Ch. 18    | Software Engineering in SRE              |
| Ch. 19–21 | Load Balancing and Overload              |
| Ch. 22    | Cascading Failures                       |
| Ch. 23–24 | Managing Critical State / Cron           |
| Ch. 25–26 | Data Pipelines / Data Integrity          |
| Ch. 27    | Reliable Product Launches                |

## Related Pages

- [Service Reliability Hierarchy](../concepts/service-reliability-hierarchy.md)
- [Site Reliability Engineering](../concepts/site-reliability-engineering.md)
- [Observability](../concepts/observability.md)
- [Incident Response](../concepts/incident-response.md)
