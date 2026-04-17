# REST Security Cheat Sheet

## Introduction

REST (Representational State Transfer) is an architectural style for developing distributed hypermedia applications. REST APIs are stateless — state refers to the state of the resource, not the state of a session.

## HTTPS

Secure REST services must only provide HTTPS endpoints. This protects authentication credentials in transit (passwords, API keys, JWTs) and allows clients to authenticate the service.

Consider mutually authenticated client-side certificates for highly privileged web services.

## Access Control

Non-public REST services must perform access control at each API endpoint.

- Access control decisions should be taken locally by REST endpoints (minimize latency, reduce coupling).
- User authentication should be centralized in an Identity Provider (IdP) that issues access tokens.

## JWT

JSON Web Tokens (JWT) are converging as the standard format for security tokens.

- Ensure JWTs are integrity protected by either a signature or a MAC. Do not allow unsecured JWTs (`{"alg":"none"}`).
- Signatures are preferred over MACs for integrity protection (MACs allow any validating service to also create new JWTs with the same key).
- A relying party must verify JWT integrity based on its own configuration, NOT based on the JWT header's algorithm field (algorithm confusion attack vector).

Standard claims to verify:
- `iss` (issuer) — is this a trusted issuer?
- `aud` (audience) — is the relying party in the target audience?
- `exp` (expiration time) — is the current time before the end of the validity period?
- `nbf` (not before time) — is the current time after the start of the validity period?

When an explicit session termination event occurs, submit a digest of associated JWTs to a denylist to invalidate the JWT before expiration.

## API Keys

API keys can reduce the impact of DoS attacks and prevent resource abuse.

- Require API keys for every request to the protected endpoint.
- Return `429 Too Many Requests` if requests are coming in too quickly.
- Revoke the API key if the client violates the usage agreement.
- Do not rely exclusively on API keys to protect sensitive, critical or high-value resources.

## Restrict HTTP methods

- Apply an allowlist of permitted HTTP Methods (e.g., `GET`, `POST`, `PUT`).
- Reject all requests not matching the allowlist with `405 Method Not Allowed`.
- Ensure the caller is authorized to use the incoming HTTP method on the resource, collection, action, and record.

## Preventing Out-of-Order API Execution

Modern REST APIs often implement business workflows through a sequence of endpoints (create → validate → approve → finalize). If the backend does not validate workflow state transitions, attackers may invoke endpoints out of sequence.

### Problem

Out-of-order API execution occurs when an attacker:
- Skips required workflow steps by directly calling later-stage endpoints.
- Replays or reuses tokens across workflow boundaries.
- Exploits assumptions that the frontend enforces correct sequencing.

### Prevention

- Enforce workflow state validation on the server side for every request.
- Model workflows explicitly using finite states or state machines.
- Bind tokens or identifiers to specific workflow stages.
- Avoid relying on frontend logic to enforce sequencing.
- Reject invalid or out-of-order transitions with clear error responses.

### Testing Checklist

- Can endpoints be invoked out of sequence?
- Does each endpoint validate the current workflow state?
- Are tokens reusable across workflow steps?
- Are invalid state transitions consistently rejected?

## Input Validation

- Do not trust input parameters/objects.
- Validate input: length / range / format and type.
- Use strong types (numbers, booleans, dates, fixed data ranges) for implicit input validation.
- Constrain string inputs with regexps.
- Define an appropriate request size limit and reject requests exceeding the limit with HTTP `413 Request Entity Too Large`.
- Log input validation failures.
- Use a secure parser for incoming messages; if using XML, use a parser not vulnerable to XXE.

## Validate Content Types

A REST request or response body should match the intended content type in the header.

### Validate request content types

- Reject requests with unexpected or missing content type headers with `406 Unacceptable` or `415 Unsupported Media Type`.
- For XML, ensure appropriate XML parser hardening (XXE prevention).
- Explicitly define content types to avoid accidentally exposing unintended types.

### Send safe response content types

- Do NOT simply copy the `Accept` header to the `Content-type` header of the response.
- Reject the request (with `406 Not Acceptable`) if the `Accept` header does not contain one of the allowable types.
- Ensure sending intended content type headers in your response matching your body content.

## Management Endpoints

- Avoid exposing management endpoints via Internet.
- If management endpoints must be accessible via Internet, require strong authentication (e.g., MFA).
- Expose management endpoints via different HTTP ports or hosts on a restricted subnet.
- Restrict access by firewall rules or access control lists.

## Error Handling

- Respond with generic error messages — avoid revealing details of the failure unnecessarily.
- Do not pass technical details (call stacks, internal hints) to the client.

## Audit Logs

- Write audit logs before and after security related events.
- Consider logging token validation errors to detect attacks.
- Sanitize log data beforehand to avoid log injection attacks.

## Security Headers

Headers for all API responses that may be consumed by browser clients:

| Header | Rationale |
|--------|-----------|
| `Cache-Control: no-store` | Prevents sensitive information from being cached |
| `Content-Security-Policy: frame-ancestors 'none'` | Prevents clickjacking via drag-and-drop attacks |
| `Content-Type` | Prevents MIME sniffing attacks |
| `Strict-Transport-Security` | Forces HTTPS, protects against spoofed certificates |
| `X-Content-Type-Options: nosniff` | Prevents MIME sniffing |
| `X-Frame-Options: DENY` | Legacy clickjacking prevention (for older browsers) |

Note: Most security headers only affect browser clients. If the API is consumed only by non-browser clients (mobile apps, server-to-server, CLI), many headers have no effect.

## CORS

- Disable CORS headers if cross-domain calls are not supported/expected.
- Be as specific as possible when setting allowed origins.

## Sensitive Information in HTTP Requests

- In `POST`/`PUT` requests: transfer sensitive data in the request body or request headers.
- In `GET` requests: transfer sensitive data in an HTTP Header.
- Never put API keys, passwords, or tokens in the URL (captured in web server logs).

## HTTP Return Codes

Key security-related status codes:

| Code | Meaning |
|------|---------|
| 400 | Bad Request — malformed request |
| 401 | Unauthorized — wrong or no authentication |
| 403 | Forbidden — authenticated but not authorized |
| 405 | Method Not Allowed — unexpected HTTP method |
| 406 | Unacceptable — unsupported Accept content type |
| 413 | Payload Too Large — request size limit exceeded |
| 415 | Unsupported Media Type — unsupported Content-Type |
| 429 | Too Many Requests — rate limiting / DoS protection |
| 500 | Internal Server Error — never reveal internal details |
