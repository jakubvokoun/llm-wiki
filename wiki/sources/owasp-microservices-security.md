---
title: "OWASP Microservices Security Cheat Sheet"
tags: [owasp, microservices, api, security, authorization, mtls]
sources: [owasp-microservices-security.md]
updated: 2026-04-15
---

# OWASP Microservices Security Cheat Sheet

Architecture patterns for authentication and authorization in microservices-based systems. Based on NIST SP 800-204 terminology.

## Key Takeaways

Microservice security requires rethinking auth: authentication and authorization must be addressed both at the edge (API gateway) and within the service mesh. A purely edge-level approach violates defense in depth and becomes unmanageable at scale.

## Authorization Architecture

### NIST Components

- **PAP**: Policy Administration Point — UI for rules management
- **PDP**: Policy Decision Point — evaluates policy
- **PEP**: Policy Enforcement Point — enforces decisions
- **PIP**: Policy Information Point — provides attributes to PDP

### Three Patterns

| Pattern                    | Where PDP lives            | Latency | Resilience         | Recommended?         |
| -------------------------- | -------------------------- | ------- | ------------------ | -------------------- |
| Decentralized              | In service code            | Low     | High               | No (hardcoded rules) |
| Centralized single PDP     | Remote service             | High    | Low (single point) | No                   |
| Centralized + embedded PDP | Library/sidecar in service | Low     | High (in-memory)   | **Yes**              |

**Recommended**: Centralized + embedded PDP (Netflix "Passport" pattern). Policy distributed to embedded PDPs; decisions made locally; policy kept up-to-date via async pull.

### Implementation Recommendations

1. Externalize authorization from code using policy language (not hardcoded)
2. Dedicate a platform security team to own the authorization solution
3. Use widely-adopted solutions (custom requires per-language SDKs)
4. Defense in depth: gateway (coarse) + service library (fine-grained) + business code (specific rules)
5. Formal procedures for policy development, approval, and rollout

## Identity Propagation

Internal services need external entity context for fine-grained auth. Don't reuse external access tokens internally (leakage risk).

**Recommended**: Signed internal identity structure ("Passport"):

- Edge auth service signs structure (HMAC or asymmetric)
- Contains user ID, roles/groups/permissions
- Passed downstream; never exposed externally
- External-token-agnostic (supports JWT, cookies, OAuth2 equally)
- Netflix example: EAS → signed "Passport" → internal services

**Not recommended**: Passing external access tokens directly to internal services.

## Service-to-Service Authentication

| Method      | How                                    | Trade-offs                                                                                                                      |
| ----------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| mTLS        | Each service has key pair; PKI-managed | Strong identity + encryption; complex cert lifecycle                                                                            |
| Token-based | Service gets signed token from STS     | Flexible; online validation detects revocations (high latency); offline uses public key (low latency, can't detect revocations) |

## Logging Architecture

```
Microservice → local log file → logging agent (co-located) → message broker (Kafka/NATS) → central logging
```

Key principles:

- Write to local file (not directly to network) — resilience against logging service failure
- Logging agent separate from service (decoupled, co-located for low latency)
- Message broker for async delivery — prevents DoS on logging service
- mTLS between agent and broker
- Filter/sanitize PII before shipping
- Correlation IDs per call chain
- Structured format (JSON/CSV) + context data (hostname, container name)

## Related Pages

- [concepts/microservices-security](../concepts/microservices-security.md)
- [concepts/service-mesh](../concepts/service-mesh.md)
- [concepts/zero-trust](../concepts/zero-trust.md)
- [concepts/secrets-management](../concepts/secrets-management.md)
