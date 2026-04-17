---
title: "WebSocket Security"
tags: [websocket, cswsh, real-time, authentication, input-validation, dos]
sources: [owasp-websocket-security.md]
updated: 2026-04-16
---

# WebSocket Security

WebSockets (RFC 6455) provide persistent bidirectional TCP connections upgraded from HTTP. Their security model differs fundamentally from standard HTTP: connections persist, browsers auto-send cookies on upgrade, and no built-in authentication exists.

## Key Threats

| Threat          | Description                                                                             |
| --------------- | --------------------------------------------------------------------------------------- |
| CSWSH           | Cross-Site WebSocket Hijacking — malicious site opens WS, browser sends session cookies |
| Injection       | WS messages carry XSS, SQLi, command injection payloads                                 |
| Session drift   | WS connections outlive HTTP sessions; stale auth persists                               |
| DoS             | Persistent connections = connection exhaustion and message flooding vectors             |
| Monitoring gaps | HTTP logs only capture the upgrade request, miss all message traffic                    |

## Cross-Site WebSocket Hijacking (CSWSH)

The WebSocket equivalent of CSRF. Browser sends cookies in the upgrade request → authenticated connection to attacker-controlled code.

**Mitigations:**

- **Origin header allowlist** — validate `Origin` header on every handshake (browser sets this; JS cannot override)
- **SameSite=Lax/Strict** cookies
- **CSRF tokens** in handshake (if app already uses CSRF tokens)

```js
const wss = new WebSocket.Server({
  verifyClient: (info) => {
    const allowed = ["https://app.example.com"];
    return allowed.includes(info.origin);
  },
});
```

## Transport

- Always `wss://` (TLS); never `ws://` in production
- Only RFC 6455; disable Hixie-76 and hybi-00 (legacy vulnerabilities)
- Disable `permessage-deflate` unless required (CRIME/BREACH-class info leakage)

## Authentication Pattern

1. Upgrade with session cookie → validate Origin + session at handshake
2. Alternatively: accept anonymous WS connection, then require token as first message
3. Re-validate session periodically for long-lived connections (30-min intervals common)
4. Maintain session→connections map; close WS on logout/expiry

## Input Validation

WebSocket messages are untrusted input — same rules as HTTP:

- JSON schema validation + allowlists on every message
- Size limits (`maxPayload ≤ 64KB`)
- Rate limiting (100 msg/min starting point)
- `JSON.parse()` not `eval()`
- Nonces/timestamps to prevent replay attacks

## DoS Considerations

- Per-user connection limits (prefer over per-IP for authenticated apps)
- Message size limits + rate limiting
- Heartbeat ping/pong to detect and clean dead connections
- Idle timeouts
- Backpressure to prevent memory exhaustion

## Monitoring

Log at WS layer: connection events (user, IP, origin), per-message auth decisions, violations, abnormal disconnections. Never log message contents or tokens.

## Related Concepts

- [TLS](tls.md) — transport for `wss://`
- [Session Management](session-management.md) — session lifetime and WS interaction
- [Authentication](authentication.md) — token/cookie patterns
- [Input Validation](input-validation.md) — message validation
- [Security Logging](security-logging.md) — WS logging gaps
