---
title: "OWASP Secure Cloud Architecture Cheat Sheet"
tags: [owasp, cloud, architecture, security, vpc, iam]
sources: [owasp-secure-cloud-architecture.md]
updated: 2026-04-15
---

# OWASP Secure Cloud Architecture Cheat Sheet

Security patterns for creating and reviewing cloud architectures, targeting medium-to-large enterprise systems.

## Key Takeaways

Start with risk analysis and threat modeling before designing architecture. Understand what threats exist, their likelihood, attack surface, and business impact.

## Object Storage Access Patterns

| Method         | Best For                                | Key Risk                                      |
| -------------- | --------------------------------------- | --------------------------------------------- |
| IAM Access     | Sensitive data; indirect access via app | Broad IAM policy; hardcoded credentials       |
| Signed URLs    | Non-sensitive direct file downloads     | Anonymous access; injection in custom URL gen |
| Public Storage | Non-sensitive public assets only        | Treats all stored data as publicly leaked     |

## Network Architecture

**VPC + Subnet structure:**

- VPCs create network boundaries (like physical data center networks)
- **Public subnets**: Load balancers, API gateways, bastion hosts — internet-facing
- **Private subnets**: Databases, backend services — no direct internet access
- Traffic flows: Internet → Gateway → Public subnet (LB/Web) → Private subnet (DB/API)

## Trust Boundaries

Three levels of trust configuration:

| Model                | Use Case                          | Trade-off                                |
| -------------------- | --------------------------------- | ---------------------------------------- |
| No Trust             | Finance, military, critical infra | High assurance; slow, expensive, complex |
| Some Trust (typical) | Most apps — risk-based approach   | Balances overhead with security gaps     |
| Full Trust           | Lowest risk only                  | Efficient but insecure — avoid           |

"No Trust" ≠ Zero Trust (see CISA Zero Trust Maturity Model for the formal framework).

## Security Tooling

**WAF**: Attach to entry points; use provider rulesets + custom rules for rate limiting, route filtering, tech-specific protections.

**Logging**: L7 HTTP calls with headers; internal actions with actor info; trace IDs across lifecycle; mask PII. Legal/compliance dictates retention.

**Monitoring**: Alert on 4xx/5xx rate spikes, resource anomalies, DB read/write rate changes, serverless invocation spikes, cost limits.

**DDoS**: WAF-based rate limiting for basic protection; cloud-provider managed services (AWS Shield, GCP Cloud Armor, Azure DDoS Protection) for advanced.

## Shared Responsibility Model

| Layer           | IaaS     | PaaS     | SaaS                |
| --------------- | -------- | -------- | ------------------- |
| App code        | Dev      | Dev      | Provider            |
| Auth/authz      | Dev      | Dev      | Provider+Dev config |
| OS / containers | Dev      | Provider | Provider            |
| Hardware        | Provider | Provider | Provider            |

Regardless of layer, developers remain responsible for: auth/authz, logging/monitoring, code security (OWASP Top 10), third-party library patching.

For SaaS vendors: ask for ISO 27001 attestation records.

## Related Pages

- [concepts/cloud-architecture-security](../concepts/cloud-architecture-security.md)
- [concepts/shared-responsibility-model](../concepts/shared-responsibility-model.md)
- [concepts/trust-boundaries](../concepts/trust-boundaries.md)
- [concepts/web-application-firewall](../concepts/web-application-firewall.md)
- [concepts/secrets-management](../concepts/secrets-management.md)
