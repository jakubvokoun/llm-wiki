---
title: "Shared Responsibility Model"
tags: [cloud, security, iaas, paas, saas, responsibility]
sources: [owasp-secure-cloud-architecture.md]
updated: 2026-04-15
---

# Shared Responsibility Model

Framework for dividing security responsibilities between cloud service providers (CSPs) and customers.

## The Three Layers

| Service Model | Customer Controls                       | CSP Controls                    | Trade-offs                                   |
| ------------- | --------------------------------------- | ------------------------------- | -------------------------------------------- |
| **IaaS**      | Auth/authz, data, networking, OS, app   | Hardware, data center           | Most control; highest cost + complexity      |
| **PaaS**      | App auth/authz, app code, external data | OS, containers, some networking | Balanced; good scalability                   |
| **SaaS**      | Configuration, admin, some integrations | Full stack                      | Lowest maintenance; least control/visibility |

## Self-Managed vs. Managed Services

Many cloud services exist on a spectrum. AWS illustrates this with EC2 (IaaS) → Lambda (managed execution) → DynamoDB (managed database).

### Self-managed responsibilities

- OS patching and minor version upgrades
- AMI/compute image refreshes
- Major version upgrades on a planned schedule
- Runtime vulnerability remediation

Best practice: automate minor updates; schedule dev cycle time for major upgrades.

## Universal Developer Responsibilities

Regardless of service model, customers are always responsible for:

- Authentication and authorization logic
- Logging and monitoring
- Application code security (OWASP Top 10)
- Third-party library patching within the application

## SaaS Vendor Evaluation

Ask SaaS vendors for:

- ISO 27001 attestation records
- SOC 2 Type II reports
- CSP compliance programs (AWS: aws.amazon.com/compliance, GCP: cloud.google.com/security/compliance, Azure: servicetrust.microsoft.com)

## Related Concepts

- [cloud-architecture-security](cloud-architecture-security.md)
- [iac-security](iac-security.md)

## Sources

- [OWASP Secure Cloud Architecture Cheat Sheet](../sources/owasp-secure-cloud-architecture.md)
