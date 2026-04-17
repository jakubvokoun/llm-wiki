---
title: "Trust Boundaries"
tags: [security, architecture, trust, zero-trust, cloud]
sources: [owasp-secure-cloud-architecture.md]
updated: 2026-04-15
---

# Trust Boundaries

Trust boundaries are connection points between system components where a trust decision must be made — specifically, points where components with potentially different trust levels interact.

## Examples

- API gateway ↔ backend service
- Application ↔ end user
- Service ↔ third-party vendor API
- Microservice A ↔ microservice B
- Code function ↔ external data source

## Trust Configuration Models

### 1. No Trust (Zero Trust–aligned)

Every component verifies every other component, regardless of network location. No implicit trust from being "inside" the network.

- **Use for**: Financial systems, military, critical infrastructure, highly sensitive data
- **Trade-offs**: High assurance; slow, complex, expensive

### 2. Risk-based Trust (Most Common)

Trust low-risk, stable component relationships; verify high-risk or external-facing interactions.

- **Use for**: Most enterprise applications
- **Trade-offs**: Balances security overhead with operational efficiency; known residual risk

### 3. Full Trust

No verification between components.

- **Use for**: Only lowest-risk internal tooling with no sensitive data
- **Trade-offs**: Efficient but insecure; never trust user input regardless

## Trust Boundary vs. Zero Trust

The cloud architecture trust boundary model is related to but distinct from the formal Zero Trust Architecture framework (see [zero-trust](zero-trust.md)). Zero Trust is a broader security model where trust is never assumed based on network position alone. Trust boundary analysis is the architectural design activity that identifies _where_ trust decisions must be made.

## Microservices Context

In microservices, trust boundaries exist between every service pair. Key decisions:

- Use mTLS for service-to-service auth (cryptographic identity)
- Sign internal identity propagation structures (e.g., "Passport" pattern)
- Never pass raw external tokens to internal services

See [microservices-security](microservices-security.md).

## Sources

- [OWASP Secure Cloud Architecture Cheat Sheet](../sources/owasp-secure-cloud-architecture.md)
