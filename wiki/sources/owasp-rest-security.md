---
title: "OWASP REST Security Cheat Sheet"
tags: [owasp, rest, api, security, jwt, cors]
sources: [owasp-rest-security.md]
updated: 2026-04-16
---

# OWASP REST Security Cheat Sheet

## Summary

Security controls for REST API implementations: HTTPS only, per-endpoint access control, JWT verification (algorithm confusion prevention, claim validation, denylist), API key practices, HTTP method allowlists, out-of-order workflow prevention, content type validation, management endpoint isolation, security headers for browser clients, CORS policy, sensitive data in URLs, and semantic HTTP status codes.

## Key Takeaways

### HTTPS

- All REST endpoints must be HTTPS-only.
- Consider mutual TLS (client certificates) for highly privileged services.

### Access Control

- Access control decision must be at each endpoint (not just gateway).
- Centralize user authentication in an Identity Provider (IdP) issuing access tokens.

### JWT Security

- Never accept `{"alg":"none"}` — reject unsecured JWTs.
- **Algorithm confusion attack**: the relying party must verify JWT integrity based on its own hard-coded/configured algorithm, NOT the `alg` header field.
- Prefer signatures over MACs (MAC key is shared — any service that validates can also forge).
- Always verify: `iss`, `aud`, `exp`, `nbf` claims.
- Maintain a JWT denylist for explicit session termination before expiry.

### API Keys

- Require for every request to protected endpoints.
- Return `429 Too Many Requests` for rate-limit violations.
- Don't rely exclusively on API keys for sensitive resources.

### HTTP Method Restriction

- Allowlist permitted HTTP methods; return `405 Method Not Allowed` for others.
- Verify caller is authorized for the specific method on the specific resource.

### Out-of-Order API Execution (Business Logic)

- REST workflows (create → validate → approve → confirm) must validate state transitions server-side.
- Attackers can skip to `confirm` without completing `pay`.
- Model with explicit state machines; bind tokens to workflow stages.
- Never trust frontend sequencing.

### Input Validation

- Validate length, range, format, and type.
- Request size limit → `413 Request Entity Too Large`.
- Log input validation failures.
- XML inputs: use a parser hardened against XXE.

### Content Type Validation

- Reject requests with wrong/missing Content-Type: `406` or `415`.
- Never copy `Accept` header directly to response `Content-Type`.
- Explicitly define and restrict content types accepted and returned.

### Management Endpoints

- Keep off the public internet.
- If internet-accessible: require MFA; use different port/host/NIC/subnet.

### Error Handling

- Generic error messages only — no stack traces, internal hints.

### Security Headers for Browser-Consumed APIs

Key headers:

- `Cache-Control: no-store` — no sensitive data caching.
- `Content-Security-Policy: frame-ancestors 'none'` — clickjacking prevention.
- `Strict-Transport-Security` — HTTPS enforcement.
- `X-Content-Type-Options: nosniff` — MIME sniffing prevention.
- `X-Frame-Options: DENY` — legacy clickjacking (backwards compat).

Note: most headers only affect browser clients. Non-browser APIs (mobile, server-to-server, CLI) are unaffected.

### CORS

- Disable CORS headers if cross-domain calls are not expected.
- Be as specific as possible about allowed origins.

### Sensitive Data in URLs

- Never put API keys, passwords, or tokens in URLs (logged by web servers).
- Sensitive data in `POST`/`PUT`: use request body or headers.
- Sensitive data in `GET`: use HTTP headers.

### HTTP Status Codes

Key security-relevant codes: `401` (not authenticated), `403` (not authorized), `405` (wrong method), `413` (too large), `415` (wrong content type), `429` (rate limited), `500` (never reveal internals).

## Related Pages

- [REST API Security](../concepts/rest-api-security.md)
- [Authentication](../concepts/authentication.md)
- [Authorization](../concepts/authorization.md)
- [HTTP Security Headers](../concepts/http-security-headers.md)
- [Input Validation](../concepts/input-validation.md)
- [OWASP REST Assessment Cheat Sheet](owasp-rest-assessment.md)
- [OWASP](../entities/owasp.md)
