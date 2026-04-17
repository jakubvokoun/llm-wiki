---
title: "Cloud Architecture Security"
tags: [cloud, architecture, security, vpc, iam, waf]
sources: [owasp-secure-cloud-architecture.md]
updated: 2026-04-15
---

# Cloud Architecture Security

Security patterns and principles for designing secure cloud architectures.

## Foundation: Risk Analysis First

Before designing architecture, perform:

- Threat modeling (identify threats and likelihood)
- Attack surface assessment
- Business impact analysis

Resources: OWASP Threat Modeling Cheat Sheet, CISA Cyber Risk Assessment.

## Network Architecture

### VPC + Subnet Pattern

- **VPCs**: Network boundaries analogous to physical data center networks
- **Public subnets**: Internet-facing components — load balancers, API gateways, bastions
- **Private subnets**: Sensitive resources — databases, backend services, secret stores

Standard flow: `Internet → Gateway → Public LB → Private App/DB`

### Object Storage Access

| Method       | Use When                         | Risk                              |
| ------------ | -------------------------------- | --------------------------------- |
| IAM-mediated | Sensitive data                   | Broad IAM policy; hardcoded creds |
| Signed URLs  | Non-sensitive direct downloads   | Anonymous access                  |
| Public       | Non-sensitive public assets only | Everything is effectively public  |

## Trust Boundaries

Every inter-component connection requires a trust decision. Three models:

| Model                 | Description                            | Use For                           |
| --------------------- | -------------------------------------- | --------------------------------- |
| No Trust (Zero Trust) | Every component verifies every other   | Critical infra, financial systems |
| Risk-based (typical)  | Trust low-risk flows; verify high-risk | Most enterprise apps              |
| Full Trust            | No verification                        | Avoid — insecure                  |

Note: The "No Trust" model diverges from but is related to [zero-trust](zero-trust.md) architecture.

## Security Tooling

### WAF

- First line of defense at entry points (load balancers, API gateways)
- Provider rulesets (AWS Managed Rules, GCP WAF, Azure CRS) + custom rules
- Custom rules: route filtering, rate limiting, tech-specific protections

### Monitoring Anomaly Thresholds

- HTTP 4xx/5xx rate spikes
- CPU/memory/storage outliers
- Database read/write rate anomalies
- Serverless invocation spikes
- Cost limit alerts

### DDoS

- Basic: WAF rate limits
- Advanced: AWS Shield, GCP Cloud Armor, Azure DDoS Protection

## Shared Responsibility

See [shared-responsibility-model](shared-responsibility-model.md) for full breakdown.

Even with fully managed services, developers remain responsible for:

- Authentication and authorization
- Logging and monitoring
- Application code security (OWASP Top 10)
- Third-party library patching

## Sources

- [OWASP Secure Cloud Architecture Cheat Sheet](../sources/owasp-secure-cloud-architecture.md)
