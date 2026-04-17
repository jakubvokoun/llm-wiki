---
title: "OWASP gRPC Security Cheat Sheet"
tags: [owasp, grpc, rpc, microservices, mtls, protobuf, rate-limiting]
sources: [owasp-grpc-security.md]
updated: 2026-04-16
---

# OWASP gRPC Security Cheat Sheet

Source: `raw/owasp-grpc-security.md`

## Summary

Security controls specific to gRPC (HTTP/2 + Protocol Buffers). Differs from REST: streaming enables unbounded message floods, Protobuf provides type safety but not business logic validation, reflection exposes full API surface in dev, and mTLS is the standard identity model for service-to-service. Covers transport, auth/authz, input validation, rate limiting, error handling, service discovery, and monitoring.

## Key Controls

### Transport Security

- TLS 1.2+ mandatory in production; TLS 1.3 preferred
- **mTLS for service-to-service:** both sides present certificates; short-lived certs (≤90 days) with automated rotation
- Service mesh (Istio/Linkerd) for automatic mTLS at scale

### Authentication

- JWT or API key validation via **interceptors** (not inside method handlers)
- Pass credentials in metadata headers, never in RPC method parameters
- Short-lived tokens: 15–60 minute expiration with refresh
- gRPC status codes: `UNAUTHENTICATED` for missing/invalid credentials

### Authorization

- Method-level RBAC via interceptors
- Log all authz failures; use `PERMISSION_DENIED` status code
- Least-privilege: method permissions map, deny by default

### Input Validation

- **Protobuf provides type safety, NOT business logic validation** — always validate server-side
- Use `protoc-gen-validate` for declarative field rules (email, min/max length, numeric ranges)
- Allowlist string inputs to block injection characters
- Parameterized queries for any database access

### Message Size Limits (DoS prevention)

```go
grpc.MaxRecvMsgSize(4 * 1024 * 1024)  // 4MB
grpc.MaxSendMsgSize(4 * 1024 * 1024)
```

Also limit: max messages per stream, max session duration.

### Rate Limiting

- Per-client IP via interceptors (token bucket: 10 req/sec, burst 20)
- Clean up old limiter state periodically to prevent memory leaks
- Production: external rate limiting (Redis, dedicated service)
- Return `RESOURCE_EXHAUSTED` status code on limit hit

### Timeouts

- Set server-side defensive timeouts even when client provides a deadline
- Prevents resource exhaustion from long-running streaming calls

### Error Handling

- Log detailed errors server-side; return **generic** messages to client
- Never leak stack traces, DB errors, or internal paths

### gRPC Reflection

- **Disable in production** — reflection exposes full method and message schema to any client
- Enable only in non-production environments

### Service Discovery

- Secure Consul/etcd with mTLS
- K8s: RBAC-restrict access to services/endpoints resources
- Prefer service mesh for automatic identity + discovery security

### Monitoring

Key signals:

- Auth failure rate per method
- Requests to non-existent methods (reconnaissance indicator)
- Resource exhaustion patterns
- Unusual per-client request rates

Distributed tracing: OpenTelemetry spans including `grpc.method` and `client.ip` attributes.

### Security Testing

```bash
# Check if reflection is exposed (should fail in prod)
grpcurl -plaintext localhost:50051 list

# Test auth requirement
grpcurl -plaintext -H "authorization: Bearer invalid" \
  localhost:50051 myservice.MyService/GetUser
```

Test categories: auth bypass, authz boundaries, input injection, rate limit enforcement, message size limits, TLS config.

## gRPC vs REST Security Differences

| Concern          | REST                     | gRPC                                |
| ---------------- | ------------------------ | ----------------------------------- |
| Message size DoS | HTTP body limits         | `MaxRecvMsgSize` option             |
| Input validation | JSON schema / middleware | `protoc-gen-validate` + server-side |
| API discovery    | OpenAPI (optional)       | Reflection (disable in prod!)       |
| Auth transport   | HTTP headers             | gRPC metadata                       |
| Service identity | mTLS optional            | mTLS standard                       |
| Error info       | HTTP status + body       | gRPC status codes                   |

## Related Concepts

- [TLS](../concepts/tls.md)
- [Microservices Security](../concepts/microservices-security.md)
- [Service Mesh](../concepts/service-mesh.md)
- [REST API Security](../concepts/rest-api-security.md)
- [Input Validation](../concepts/input-validation.md)
- [RBAC](../concepts/rbac.md)
- [Security Logging](../concepts/security-logging.md)
