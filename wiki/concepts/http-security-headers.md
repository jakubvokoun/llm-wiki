---
title: "HTTP Security Headers"
tags: [http-headers, browser-security, csp, hsts, cors, clickjacking]
sources: [owasp-http-headers.md]
updated: 2026-04-16
---

# HTTP Security Headers

HTTP security response headers are server-set directives that instruct browsers how to handle content, connections, and cross-origin interactions. They are low-effort, high-value controls that mitigate XSS, clickjacking, MIME confusion, downgrade attacks, and cross-origin data leakage.

## Essential Headers

### Anti-XSS / Content Control

| Header                    | Value                                        | Effect                                                            |
| ------------------------- | -------------------------------------------- | ----------------------------------------------------------------- |
| `Content-Security-Policy` | (see [CSP page](content-security-policy.md)) | Restricts allowed content origins; primary XSS defense            |
| `X-Content-Type-Options`  | `nosniff`                                    | Blocks MIME sniffing / MIME confusion attacks                     |
| `Content-Type`            | `text/html; charset=UTF-8`                   | Prevents MIME-based XSS; charset prevents charset-based XSS       |
| `X-XSS-Protection`        | `0`                                          | **Disable** — the legacy XSS filter can introduce vulnerabilities |

### Clickjacking Prevention

| Header            | Value  | Effect                                                             |
| ----------------- | ------ | ------------------------------------------------------------------ |
| `X-Frame-Options` | `DENY` | Prevents framing (use CSP `frame-ancestors` instead when possible) |

### Transport Security

| Header                      | Value                                          | Effect                                 |
| --------------------------- | ---------------------------------------------- | -------------------------------------- |
| `Strict-Transport-Security` | `max-age=63072000; includeSubDomains; preload` | Forces HTTPS; see [HSTS page](hsts.md) |

### Referrer & Cache

| Header            | Value                             | Effect                                 |
| ----------------- | --------------------------------- | -------------------------------------- |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Limits referrer info sent cross-origin |
| `Cache-Control`   | `no-store` (sensitive pages)      | Prevents caching of sensitive data     |

### Cross-Origin Isolation (COOP/COEP/CORP)

These three headers work together to enable cross-origin isolation — required for `SharedArrayBuffer` and protection against Spectre-class side-channel attacks:

| Header                         | Value          | Effect                                                    |
| ------------------------------ | -------------- | --------------------------------------------------------- |
| `Cross-Origin-Opener-Policy`   | `same-origin`  | Isolates browsing context to same-origin only             |
| `Cross-Origin-Embedder-Policy` | `require-corp` | Blocks cross-origin resources without explicit permission |
| `Cross-Origin-Resource-Policy` | `same-site`    | Limits which origins can load this resource               |

### CORS

| Header                        | Value                                                 | Effect                         |
| ----------------------------- | ----------------------------------------------------- | ------------------------------ |
| `Access-Control-Allow-Origin` | Specific origin (not `*` for authenticated endpoints) | Relaxes SOP for listed origins |

### Feature / Permission Control

| Header               | Value                                      | Effect                                            |
| -------------------- | ------------------------------------------ | ------------------------------------------------- |
| `Permissions-Policy` | `geolocation=(), camera=(), microphone=()` | Disables browser features; limits post-XSS damage |

## Headers to Remove (Information Disclosure)

- `Server` — remove or set to generic value.
- `X-Powered-By` — remove entirely.
- `X-AspNet-Version` / `X-AspNetMvc-Version` — disable in framework config.

## Deprecated Headers — Do Not Use

- `Expect-CT` — deprecated; remove from existing code.
- `Public-Key-Pins (HPKP)` — deprecated; dangerous.
- `X-XSS-Protection` — disable (`0`) rather than setting any positive value.

## Secure File Downloads

When serving user-provided files:

```
Content-Disposition: attachment
Content-Type: application/octet-stream
X-Content-Type-Options: nosniff
```

## Testing

- [Mozilla Observatory](https://observatory.mozilla.org/) — online header checker.
- [SecurityHeaders.com](https://securityheaders.com/) — detailed header scoring.
- SmartScanner — whole-site header audit.

## Related Pages

- [Content Security Policy](content-security-policy.md)
- [HSTS](hsts.md)
- [OWASP HTTP Headers source](../sources/owasp-http-headers.md)
