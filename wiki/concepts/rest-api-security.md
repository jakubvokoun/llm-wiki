---
title: "REST API Security"
tags: [rest, api, security, jwt, cors, testing]
sources: [owasp-rest-security.md, owasp-rest-assessment.md]
updated: 2026-04-16
---

# REST API Security

Security design, implementation, and testing of RESTful APIs.

## Design Principles

### Statelessness

REST APIs are stateless — state refers to resource state, not session state. Stateful APIs (passing session state from client to backend) are an anti-pattern prone to replay and impersonation attacks.

### Transport

- HTTPS only — no HTTP endpoints.
- Consider mutual TLS (mTLS) for highly privileged services.

### Access Control

- Each API endpoint enforces access control independently (minimizes latency, reduces coupling).
- Centralize authentication in an Identity Provider (IdP).
- Access control decisions made locally by each endpoint.

## Authentication

### JWT (JSON Web Tokens)

**Must-do:**

- Never accept `{"alg":"none"}` — reject unsecured JWTs.
- Verify JWT integrity based on server-side config, NOT the `alg` header field (**algorithm confusion attack**).
- Prefer signatures over MACs (MAC key is shared among all validators, any can forge).

**Claims to verify:** `iss` (issuer), `aud` (audience), `exp` (expiration), `nbf` (not before).

**JWT revocation:** maintain a denylist for explicit session termination before expiry.

### API Keys

- Require for all requests to protected endpoints.
- Return `429 Too Many Requests` for rate limit violations.
- Do not rely exclusively on API keys for sensitive resources.
- Do not put API keys in URLs (captured in web server logs).

## Input Validation

- Validate type, length, range, and format of all parameters.
- Use strong types (numbers, booleans, dates) for implicit validation.
- Set request size limit → return `413 Request Entity Too Large`.
- Log input validation failures.
- XML requests: use XXE-hardened parser.

## Content Type Validation

- Reject requests with wrong/missing `Content-Type`: `406 Unacceptable` or `415 Unsupported Media Type`.
- Never copy `Accept` header directly to response `Content-Type`.
- Explicitly define accepted and returned content types.

## HTTP Method Restriction

- Allowlist permitted HTTP methods; return `405 Method Not Allowed` for others.
- Verify caller is authorized for the specific method on the specific resource.

## Out-of-Order Workflow Prevention

REST workflows (create → validate → approve → confirm) are vulnerable to step-skipping attacks.

**Defense:**

- Server-side state validation at every endpoint.
- Model workflows with explicit state machines.
- Bind tokens to specific workflow stages.
- Never trust frontend to enforce sequencing.

**Testing:** attempt to invoke later-stage endpoints without completing earlier ones; verify tokens are not reusable across stages.

## Security Headers

For APIs consumed by browsers:

| Header                      | Value                    | Purpose                                 |
| --------------------------- | ------------------------ | --------------------------------------- |
| `Cache-Control`             | `no-store`               | Prevents caching of sensitive responses |
| `Content-Security-Policy`   | `frame-ancestors 'none'` | Clickjacking prevention                 |
| `Strict-Transport-Security` | (configured)             | Forces HTTPS                            |
| `X-Content-Type-Options`    | `nosniff`                | MIME sniffing prevention                |
| `X-Frame-Options`           | `DENY`                   | Legacy clickjacking (backwards compat)  |

Note: most headers have no effect on non-browser clients (mobile apps, server-to-server, CLI tools).

## CORS

- Disable CORS if cross-domain calls are not needed.
- Be specific about allowed origins.

## Management Endpoints

- Keep off the public internet.
- If internet-facing: MFA required; separate port/host/NIC/subnet.
- Restrict with firewall rules or ACLs.

## Error Handling

- Generic error messages only — no stack traces, internal hints, or technology information.

## Audit Logging

- Log before and after security-relevant events.
- Log JWT/token validation errors to detect attacks.
- Sanitize log data to prevent log injection.

## Semantic HTTP Status Codes

| Code | Meaning                               |
| ---- | ------------------------------------- |
| 401  | Not authenticated                     |
| 403  | Authenticated but not authorized      |
| 405  | Wrong HTTP method                     |
| 413  | Request too large                     |
| 415  | Unsupported Content-Type              |
| 429  | Rate limited                          |
| 500  | Server error (never reveal internals) |

## Security Testing (Pentesting REST APIs)

### Challenge

REST APIs have a hidden attack surface:

- No standard documentation (unlike SOAP/WSDL).
- Parameters embedded in URLs, headers, JSON/XML bodies.
- Client-side code dynamically constructs calls.

### Discovery

1. Look for WADL/WSDL 2.0, developer guides, or config files.
2. Use a proxy (ZAP) to collect full requests including headers and bodies.

### Parameter Identification

- **Header parameters**: abnormal HTTP headers.
- **URL-embedded parameters**: repeating patterns (dates, IDs) across URLs.
- **Extensionless URL segments**: may be parameters if tech normally uses extensions.
- **High-variability segments**: same URL pattern with hundreds of different values.

**Verification**: set suspected parameter to invalid value → `404` = path element; application error = parameter.

### Fuzzing Strategy

- Analyze collected values to find valid/invalid boundaries.
- Target marginal invalid values (e.g., `0` for positive integer, `null`, negative numbers).
- Test sequences beyond the current user's allocated range (IDOR risk).
- Always emulate the custom auth mechanism.

## Related Pages

- [Authentication](authentication.md)
- [Authorization](authorization.md)
- [IDOR](idor.md)
- [Input Validation](input-validation.md)
- [HTTP Security Headers](http-security-headers.md)
- [Zero Trust Architecture](zero-trust.md)
- [OWASP REST Security Cheat Sheet](../sources/owasp-rest-security.md)
- [OWASP REST Assessment Cheat Sheet](../sources/owasp-rest-assessment.md)
