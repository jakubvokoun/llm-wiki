---
title: "Zero Trust Architecture"
tags:
  [zero-trust, security, architecture, network, identity, ztna, policy-as-code]
sources:
  [
    owasp-secure-cloud-architecture.md,
    owasp-microservices-security.md,
    owasp-secure-product-design.md,
    owasp-zero-trust.md,
  ]
updated: 2026-04-16
---

# Zero Trust Architecture

Zero Trust is a security model based on the principle "never trust, always verify" — no implicit trust is granted based on network location (inside vs. outside the perimeter).

## Core Principles

1. **Verify explicitly**: Always authenticate and authorize based on all available data points (identity, location, device health, service/workload, data classification, anomalies)
2. **Use least privilege**: Limit user/service access with just-in-time and just-enough-access (JIT/JEA), risk-based adaptive policies, and data protection
3. **Assume breach**: Minimize blast radius, segment access, encrypt end-to-end, use analytics to get visibility and drive threat detection

## Zero Trust vs. Perimeter Security

Traditional model: trusted internal network + untrusted external. Once inside the perimeter, lateral movement is easy.

Zero Trust: no implicit trust based on network location. Every request authenticated and authorized regardless of origin.

## Implementation in Microservices

Service meshes (Istio, Linkerd) enable practical Zero Trust at scale:

- Automatic mTLS between all services
- Cryptographic identity per service (SPIFFE/SPIRE)
- Policy enforcement at every service boundary

Identity propagation patterns (signed "Passport") also support Zero Trust — each service verifies the caller's identity rather than trusting network position.

## CISA Zero Trust Maturity Model

Five pillars:

1. Identity
2. Devices
3. Networks
4. Applications & Workloads
5. Data

Four stages: Traditional → Initial → Advanced → Optimal

See: CISA Zero Trust Maturity Model v2 (2023)

## Relationship to Trust Boundaries

Trust boundary analysis identifies _where_ trust decisions must be made. Zero Trust architecture is the _policy_ applied at those boundaries: verify always, trust nothing implicitly.

## NIST SP 800-207 Seven Principles (expanded)

1. All resources need protection (no safe internal assets)
2. All communication secured regardless of location (TLS 1.3+)
3. Access per-session, never permanent
4. Dynamic policy: identity + device health + behavior + location + time
5. Continuous asset health monitoring (devices lose access if out of compliance)
6. Real-time dynamic authentication and authorization
7. Telemetry collection drives policy improvement

## Architecture Components

- **Policy Engine**: allow/deny decision based on risk signals
- **Policy Administrator**: translates decision into enforcement commands
- **Policy Enforcement Point**: firewalls, proxies, API gateways — where blocking happens

## Policy-as-Code + Continuous Verification Loop

Tools: OPA/Gatekeeper, Kyverno, Cilium, cloud provider policy engines.
Signals: identity telemetry, east-west traffic anomalies, syscall anomalies (Falco/Tetragon), image signature mismatches.
Loop: code → verify at admission → telemetry → refine policies.

## MFA Hierarchy

Phishing-resistant: FIDO2 keys, WebAuthn/Passkeys, smart cards.
Avoid: SMS MFA.

## Legacy System Strategies

- Security proxy fronting systems without MFA support
- Network isolation zones for systems with flat-network requirements
- Protocol translation gateways (SAML/OAuth → Kerberos)

## Related Concepts

- [Trust Boundaries](trust-boundaries.md)
- [Service Mesh](service-mesh.md)
- [Microservices Security](microservices-security.md)
- [Cloud Architecture Security](cloud-architecture-security.md)
- [Multi-Factor Authentication](mfa.md)
- [Network Policy](network-policy.md)
- [RBAC](rbac.md)

## Sources

- [OWASP Zero Trust Architecture Cheat Sheet](../sources/owasp-zero-trust.md)
- [OWASP Secure Cloud Architecture Cheat Sheet](../sources/owasp-secure-cloud-architecture.md)
- [OWASP Microservices Security Cheat Sheet](../sources/owasp-microservices-security.md)
- [OWASP Secure Product Design Cheat Sheet](../sources/owasp-secure-product-design.md)
