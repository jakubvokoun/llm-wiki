# Microservices Security Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Microservices_Security_Cheat_Sheet.html

## Introduction

Microservice architecture is increasingly used in cloud and on-premise systems. Core security requirements: authentication and authorization. This sheet covers patterns for security architects.

## Edge-level Authorization

Authorization at the API gateway (edge) level only. NIST recommends mTLS to prevent gateway bypass. Limitations:
- Hard to manage with many roles/rules in complex ecosystems
- Single point of decision violates defense in depth
- Operation teams own gateway; dev teams can't directly change auth rules

In practice, authorization is implemented at both edge (coarse) and service level (fine-grained).

## Service-level Authorization

Uses NIST SP 800-162 terminology:
- **PAP** (Policy Administration Point): UI for creating/managing access control rules
- **PDP** (Policy Decision Point): Evaluates access control policy
- **PEP** (Policy Enforcement Point): Enforces PDP decisions
- **PIP** (Policy Information Point): Provides attributes for PDP decisions

### Patterns

#### Decentralized Pattern
PDP and PEP implemented directly in microservice code. Access control rules stored per service. Simple but requires code updates for every authorization change.

#### Centralized Pattern with Single PDP
Rules defined, stored, and evaluated centrally. Microservice calls PDP via network for each decision. Can cause latency — mitigate with caching. PDP must be HA. Combine with gateway-level auth for defense in depth.

#### Centralized Pattern with Embedded PDP (Recommended)
Rules defined centrally but stored/evaluated at microservice level. PDP delivered as library or sidecar. Low latency (in-memory policy). Policy is current, but decisions not cached (avoids stale access rules).

Netflix example: Policy portal → Aggregator → Distributor → embedded PDP libraries per service.

### Recommendations
1. Externalize/decouple authorization from code using policy language (not hardcoded)
2. Platform-level solution owned by a dedicated security team
3. Use widely-adopted solutions (custom solutions require SDKs per language, community support)
4. Defense in depth: gateway (coarse) + service library (fine) + business code (specific rules)
5. Formal procedures for policy development, approval, and rollout

## External Entity Identity Propagation

Microservices need external entity identity for fine-grained authorization. Don't reuse external access tokens for internal propagation (leakage risk, increases attack surface).

### Patterns

#### Clear / Self-signed Data Structures
Service extracts identity and passes as JSON/self-signed JWT. Requires trusting calling services. Only suitable for highly trusted environments.

#### Signed by Trusted Issuer (Recommended)
Edge auth service signs an internal identity structure ("Passport" pattern from Netflix) with HMAC. Structure contains user ID, roles, permissions. Passed to internal services, never exposed externally. External-token-agnostic and allows decoupling.

### Recommendations
1. Decouple external access tokens from internal identity representation
2. Use signed (symmetric or asymmetric) internal identity structures
3. Make the structure extensible for future claims
4. Never expose the internal identity structure externally

## Service-to-Service Authentication

### mTLS
Each service carries public/private key pair and authenticates via mTLS. Self-hosted PKI. Challenges: key provisioning, certificate revocation, key rotation.

### Token-based
Service obtains signed token from security token service using its service ID/password. Attaches to outgoing requests via HTTP headers. Token validated by recipient:
- **Online validation**: Network call to token service. Can detect revoked tokens. High latency. For critical requests.
- **Offline validation**: Uses downloaded public key. Cannot detect revoked tokens. Low latency. For non-critical requests.

## Logging

Architecture: each microservice writes to local log file → logging agent reads and publishes to message broker (Kafka/NATS) → central logging service subscribes.

Key recommendations:
1. Microservices write to local files, not directly to central logging (resilience)
2. Dedicated logging agent decoupled from microservice, deployed co-located
3. Message broker for async log shipping (prevents DoS on central logging)
4. mTLS between logging agent and broker (prevent spoofing, sniffing)
5. Message broker enforces access control (least privilege)
6. Logging agent filters/sanitizes PII, passwords, API keys before shipping
7. Generate correlation IDs per call chain
8. Structured log format (JSON, CSV)
9. Append context data (hostname, container name, class name)

## References

- NIST SP 800-204: Security Strategies for Microservices-based Application Systems
- NIST SP 800-204A: Building Secure Microservices-based Applications Using Service-Mesh Architecture
- Microservices Security in Action, Prabath Siriwardena and Nuwan Dias, Manning 2020
