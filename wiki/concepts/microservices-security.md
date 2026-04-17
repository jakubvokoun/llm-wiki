---
title: "Microservices Security"
tags: [microservices, security, authorization, identity, mtls, logging]
sources: [owasp-microservices-security.md]
updated: 2026-04-15
---

# Microservices Security

Security architecture patterns for microservices-based systems, covering authorization, identity propagation, and service-to-service authentication.

## Core Challenge

Microservices decompose a monolith into many independently deployable services. Each service must:

- Authenticate callers (who is this?)
- Authorize requests (are they allowed?)
- Propagate caller identity to downstream services

These problems are more complex than in monoliths because there's no single process boundary.

## Authorization Architecture

### NIST Component Model

- **PAP**: Policy Administration Point — rule management UI
- **PDP**: Policy Decision Point — evaluates policy
- **PEP**: Policy Enforcement Point — enforces decisions
- **PIP**: Policy Information Point — provides attributes

### Recommended Pattern: Centralized + Embedded PDP

Policy defined centrally (PAP → policy repository). Distributed asynchronously to embedded PDPs (library/sidecar per service). Decisions made locally = low latency + resilience.

Contrast with alternatives:

- Decentralized (hardcoded in service code) — unscalable, hard to update
- Single remote PDP — latency + single point of failure

Defense in depth: gateway (coarse) + service library (fine) + business code (specific).

## Identity Propagation

**Problem**: Internal services need to know the external user's identity for authorization. External tokens (JWT, OAuth2) must not be passed directly to internal services (leakage risk).

**Solution**: Edge authentication service issues a signed internal identity structure ("Passport"):

- Signed with HMAC or asymmetric key
- Contains: user ID, roles/groups, permissions
- Passed downstream as HTTP header
- Never exposed to external clients
- External-token-agnostic — works with any external auth mechanism

## Service-to-Service Authentication

**mTLS**: Each service has a certificate. Provides cryptographic identity + encryption. Complex cert lifecycle (provisioning, rotation, revocation). Recommended for sensitive services.

**Token-based**: Service obtains token from security token service (STS) and attaches to requests.

- Online validation: detect revoked tokens; high latency → for critical ops
- Offline validation: use public key locally; low latency; can't detect revocations → for non-critical ops

## Distributed Logging

Architecture: service → local file → co-located agent → message broker → central logging

Key requirements:

- Co-located agent (not direct network call) — protects against central logging failures
- Async message broker — prevents DoS propagation
- mTLS between agent and broker
- Sanitize PII before shipping
- Correlation IDs per call chain

## Related Concepts

- [service-mesh](service-mesh.md)
- [zero-trust](zero-trust.md)
- [rbac](rbac.md)
- [secrets-management](secrets-management.md)
- [kubernetes-security](kubernetes-security.md)

## Sources

- [OWASP Microservices Security Cheat Sheet](../sources/owasp-microservices-security.md)
