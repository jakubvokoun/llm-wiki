---
title: "OWASP Zero Trust Architecture Cheat Sheet"
tags:
  [owasp, zero-trust, ztna, identity, mfa, micro-segmentation, policy-as-code]
sources: [owasp-zero-trust.md]
updated: 2026-04-16
---

# OWASP Zero Trust Architecture Cheat Sheet

Source: `raw/owasp-zero-trust.md`

## Summary

Practical implementation guide for Zero Trust Architecture (ZTA) based on NIST SP 800-207 and CISA ZT Maturity Model v2.0. Covers all seven NIST principles, the Policy Engine/Administrator/Enforcement Point model, phased implementation (3–5 years), legacy system strategies, compliance mapping, and the Policy-as-Code + Continuous Verification + Telemetry loop.

## Seven NIST Principles (SP 800-207)

1. All data sources and computing services are resources
2. All communication secured regardless of network location (TLS 1.3+)
3. Access granted per-session — no permanent access
4. Access determined by dynamic policy (identity + device + behavior + location + time)
5. Monitor and measure security posture of all assets continuously
6. All authentication/authorization is dynamic and strictly enforced in real-time
7. Collect telemetry to improve security posture

## Architecture Components

| Component                    | Role                                                            |
| ---------------------------- | --------------------------------------------------------------- |
| **Policy Engine**            | Decides allow/deny based on identity, device health, risk score |
| **Policy Administrator**     | Translates decision into enforcement commands                   |
| **Policy Enforcement Point** | Firewalls, proxies, API gateways — blocks/allows traffic        |

## MFA Requirements

- **Phishing-resistant (preferred):** FIDO2 hardware keys, WebAuthn/Passkeys, smart cards/PIV
- **Acceptable:** TOTP mobile apps, backup codes
- **Avoid:** SMS MFA (SIM-swap / phishing vulnerable)
- OMB M-22-09 mandates phishing-resistant MFA for U.S. federal agencies

## Implementation Phases

| Phase | Timeline     | Focus                                                                    |
| ----- | ------------ | ------------------------------------------------------------------------ |
| 1     | Months 1–6   | Asset inventory, MFA everywhere, replace VPN→ZTNA, PAM for admin         |
| 2     | Months 6–18  | Micro-segmentation, continuous device health, WAF + identity-aware proxy |
| 3     | Months 18–36 | Behavioral analytics, automated response, policy tuning                  |
| 4     | Ongoing      | Threat intel updates, post-quantum prep, metrics                         |

## Policy-as-Code + Continuous Verification + Telemetry

**Policy-as-Code tools:** OPA/Gatekeeper, Kyverno, Cilium, AWS SCP, Azure Policy

**Continuous verification:** SPIFFE/SPIRE workload identity, image signing (cosign/sigstore), SAST gates, RBAC drift detection at CI/CD admission

**Telemetry signals:** identity correlation, east-west network anomalies, syscall anomalies (Falco/Tetragon), deployment manifest drift, vulnerability reachability

The three components form a feedback loop: policies inform verification → telemetry triggers policy updates → policies re-enforce.

## Legacy System Strategies

| Problem                   | Solution                                                      |
| ------------------------- | ------------------------------------------------------------- |
| No MFA support            | Security proxy in front (handles modern auth, passes through) |
| Flat network requirements | Network isolation zone + monitor all traffic to zone          |
| Old auth protocol         | Protocol translation gateway (SAML/OAuth → Kerberos/basic)    |
| Poor logging              | Network-based detection for traffic pattern monitoring        |

## Compliance Mapping

| Standard    | ZTA Controls                                             |
| ----------- | -------------------------------------------------------- |
| SOC 2       | Access controls, continuous monitoring, audit logging    |
| PCI DSS     | Network segmentation, encrypted comms, access monitoring |
| HIPAA       | Granular access, data encryption, audit trails           |
| GDPR        | Data access logging, breach detection                    |
| OMB M-22-09 | Phishing-resistant MFA, device certs, encrypted DNS      |

## Common Mistakes

- Treating it as a network-only problem (it's identity-based)
- Not monitoring enough (SIEM + analytics required)
- UX friction driving workarounds (use risk-based step-up, not constant friction)
- Ignoring legacy systems (often contain most sensitive data)
- No executive sponsorship (multi-year, multi-team effort)
- Rushing (most orgs take 3–5 years)

## Related Concepts

- [Zero Trust Architecture](../concepts/zero-trust.md)
- [Multi-Factor Authentication](../concepts/mfa.md)
- [Micro-segmentation / Network Policy](../concepts/network-policy.md)
- [Service Mesh](../concepts/service-mesh.md)
- [RBAC](../concepts/rbac.md)
- [Security Logging](../concepts/security-logging.md)
