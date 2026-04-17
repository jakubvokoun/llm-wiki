---
title: "OWASP WebSocket Security Cheat Sheet"
tags: [owasp, websocket, cswsh, authentication, input-validation, dos]
sources: [owasp-websocket-security.md]
updated: 2026-04-16
---

# OWASP WebSocket Security Cheat Sheet

Source: `raw/owasp-websocket-security.md`

## Overview

WebSockets (RFC 6455) provide real-time bidirectional communication but differ from HTTP in ways that create new security gaps: persistent connections, no built-in auth, browser auto-sends cookies on upgrade, and traditional logs miss all message traffic.

**Real-world incidents:**

- Gitpod CSWSH (2023): weak origin validation → full account takeover via hijacked WS connections
- Spring CVE-2018-1270: crafted STOMP messages → RCE

## Transport Security

- **Always WSS** (`wss://`), never `ws://` in production
- **Only RFC 6455** — drop Hixie-76 and hybi-00 (legacy, vulnerable)
- **Disable `permessage-deflate` compression** unless needed (CRIME/BREACH-like info leakage)
- **Proxy config**: pass `Upgrade` and `Connection: upgrade` headers; set proper read timeouts
- **WAF**: check WAF supports WebSocket inspection beyond handshake; if not, rely on server-side validation

## Authentication and Authorization

### Cross-Site WebSocket Hijacking (CSWSH)

Attack flow:

1. User is logged into your app (cookie set)
2. User visits malicious site
3. Malicious site opens WebSocket to your app
4. Browser sends cookies → attacker gets authenticated WS connection

**Defenses:**

- **Origin header allowlist** on every handshake — explicit list, no wildcards, no substring matching; browsers set this header and JS cannot override it
- **SameSite=Lax/Strict** cookies (reduces cross-site cookie transmission)
- **CSRF tokens** in handshake for apps with existing CSRF protection

### Session Management

- Long-lived WS connections outlive HTTP sessions → re-validate session periodically (e.g. every 30 min)
- Close WS connections on session expiry and logout
- Maintain session→connection mapping for immediate invalidation

### Token-Based Auth

- Pass token in query string (appears in logs — redact) or as first WS message after connect
- Rotate tokens in long-lived connections

### Per-Message Authorization

Don't assume connection = authorization. Check every action:

```js
if (message.action === "delete_user" && !user.hasRole("admin")) {
  ws.send({ type: "error", message: "Access denied" });
  return;
}
```

## Input Validation

All WS messages are untrusted user input:

- Validate with JSON schema + allowlists
- Set message size limits (≤64KB typical): `maxPayload: 64 * 1024`
- Rate limiting: 100 msg/min is a common starting point
- Use `JSON.parse()` not `eval()` for JSON
- For binary: check magic numbers, not content-type; scan uploads; safe deserialization
- Include nonces/timestamps to prevent replay attacks

## DoS Protection

Persistent connections amplify DoS risk:

- Per-user (preferred) or per-IP connection limits
- Message size limits + rate limiting
- Idle timeouts + ping/pong heartbeats to clean dead connections
- Backpressure controls to prevent memory exhaustion from fast producers

## Service Tunneling Risk

WebSockets can tunnel TCP services (VNC, SSH, FTP). If app has XSS, attacker can reach these tunneled services from victims' browsers. Add extra auth/access controls if tunneling is required.

## Monitoring and Logging

HTTP logs only capture the upgrade request — all subsequent messages are invisible. Log:

- Connection establishment/termination (user, IP, origin)
- Auth/authz events at handshake and message level
- Rate-limit violations, validation failures
- Abnormal disconnections and protocol errors

Never log: message contents, tokens, session IDs, PII.

## Testing Checklist

- Origin validation: connect from unauthorized domains
- Auth bypass: connect without credentials
- Message injection: XSS, SQLi, command injection payloads
- DoS: connection limits, message flooding, oversized messages
- Session: test expiry and logout behavior

**Tools**: wscat, OWASP ZAP (has WS testing), browser DevTools.

## Related Pages

- [WebSocket Security](../concepts/websocket-security.md)
- [TLS](../concepts/tls.md)
- [Input Validation](../concepts/input-validation.md)
- [Session Management](../concepts/session-management.md)
- [Authentication](../concepts/authentication.md)
