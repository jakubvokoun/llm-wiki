---
title: "OWASP Session Management Cheat Sheet"
tags: [owasp, session, cookies, authentication, csrf, security]
sources: [owasp-session-management.md]
updated: 2026-04-16
---

# OWASP Session Management Cheat Sheet

Source: `raw/owasp-session-management.md`

## Key Takeaways

Session IDs are temporarily equivalent to the strongest authentication method used. Compromise → full session hijacking.

## Session ID Requirements

| Property       | Requirement                                                              |
| -------------- | ------------------------------------------------------------------------ |
| **Entropy**    | ≥ 64 bits (prevents brute force; 64-bit at 10k guesses/sec = ~585 years) |
| **Length**     | ≥ 16 hex chars (64 bits at hex encoding)                                 |
| **Content**    | Meaningless — no PII, no decodable user data                             |
| **Name**       | Generic (e.g., `id`) — not `PHPSESSID`, `JSESSIONID` (fingerprinting)    |
| **Generation** | CSPRNG — not predictable PRNG                                            |

## Cookie Security Attributes

| Attribute      | Purpose                                              |
| -------------- | ---------------------------------------------------- |
| `Secure`       | Only send over HTTPS                                 |
| `HttpOnly`     | No JS access (blocks XSS theft)                      |
| `SameSite`     | Limits cross-site sending (CSRF mitigation)          |
| `Domain`       | Restrict to specific domain (avoid overly broad)     |
| `Path`         | Restrict to specific path                            |
| Non-persistent | No `Expires`/`Max-Age` → disappears on browser close |

## Session ID Life Cycle

- **Strict session management:** Only accept server-generated IDs (prevent fixation)
- **Regenerate on privilege change:** New session ID after login, role change, password change
- **Treat as untrusted input:** Validate IDs before processing

## Session Expiration

- **Idle timeout:** Expire after N minutes of inactivity (2-5 min high-value, 15-30 min low-risk)
- **Absolute timeout:** Expire regardless of activity (4-8 hrs for office apps)
- **Renewal timeout:** Auto-renew ID mid-session to limit hijacking window
- **Server-side enforcement:** Never rely only on client-side timers
- **Logout:** Invalidate server-side on logout + clear client cookie

## Storage Alternatives to Cookies

| Storage          | Scope                 | Duration   | Session Safe?               |
| ---------------- | --------------------- | ---------- | --------------------------- |
| `localStorage`   | Same origin           | Persistent | No — survives session close |
| `sessionStorage` | Same origin, same tab | Tab close  | Better — tab-scoped         |
| Web Workers      | In-memory, isolated   | Page close | Best — JS-inaccessible      |

## Session Attacks Detection

- **Brute force:** Multiple sequential requests with different IDs → rate limit + alert
- **Anomaly detection:** Changes in IP, User-Agent mid-session → alert/terminate
- **Log life cycle:** Creation, renewal, destruction of session IDs (log salted hash, not raw ID)
- **Simultaneous sessions:** Detect and optionally reject concurrent logons

## Client-Side Defenses

- Force logout on browser window close (JS `beforeunload`)
- Initial login timeout (pre-auth session renewal)
- Automatic client logout with countdown timer

## WAF Protections

WAFs can enforce `Secure`/`HttpOnly` flags on `Set-Cookie` headers, implement sticky sessions, and detect session fixation — useful when source code cannot be changed.

## Related Pages

- [Session Management](../concepts/session-management.md)
- [Authentication](../concepts/authentication.md)
- [Browser Storage Security](../concepts/browser-storage-security.md)
- [HTTP Security Headers](../concepts/http-security-headers.md)
- [HSTS](../concepts/hsts.md)
- [Content Security Policy](../concepts/content-security-policy.md)
