---
title: "Defense-in-Depth"
tags: [defense-in-depth, security-architecture, layered-security]
sources: [owasp-secure-product-design.md]
updated: 2026-04-16
---

# Defense-in-Depth

A security strategy using multiple independent layers of controls so that if one layer fails, others still protect the asset.

## Core Idea

No single control is perfect. Layer controls at every level so an attacker must defeat multiple independent mechanisms to succeed. Each layer slows, detects, or stops an attack.

## Typical Layers

| Layer       | Examples                                                   |
| ----------- | ---------------------------------------------------------- |
| Physical    | Locked facilities, hardware security modules               |
| Network     | Firewalls, network segmentation, VPCs, NACLs               |
| Host/OS     | Hardened OS config, patch management, EDR                  |
| Application | Input validation, authentication, authorization, SAST/DAST |
| Data        | Encryption at rest and in transit, DLP, access controls    |
| Identity    | MFA, least privilege, PAM                                  |
| Monitoring  | SIEM, IDS/IPS, anomaly detection, logging                  |

## Why It Matters

- Prevents a single misconfiguration or vulnerability from being catastrophic
- Attackers must chain multiple failures — increasing cost and detection probability
- Supports fail-safe defaults: if outer layers are bypassed, inner layers still protect

## Applied in Practice

In cloud architectures: VPC + security groups + WAF + application-level auth + encryption = layered defense.

In Kubernetes: network policies + pod security standards + RBAC + admission controllers + runtime detection.

In CI/CD: SCM hardening + branch protection + secrets scanning + artifact signing + deployment gates.

## Relationship to Other Principles

- **Least Privilege** removes permissions to shrink what's exploitable at each layer
- **Zero Trust** extends the model to identity/network: never rely on a single trust assertion
- **Secure by Default** ensures new layers start hardened, not open

## Sources

- [OWASP Secure Product Design Cheat Sheet](../sources/owasp-secure-product-design.md)
- [OWASP CI/CD Security Cheat Sheet](../sources/owasp-cicd-security.md)
- [OWASP Kubernetes Security Cheat Sheet](../sources/owasp-kubernetes-security.md)
- [OWASP Secure Cloud Architecture Cheat Sheet](../sources/owasp-secure-cloud-architecture.md)
