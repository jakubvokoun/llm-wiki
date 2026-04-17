---
title: "OWASP HTTP Security Response Headers Cheat Sheet"
tags: [owasp, http-headers, browser-security, csp, hsts, cors]
sources: [owasp-http-headers.md]
updated: 2026-04-16
---

# OWASP HTTP Security Response Headers Cheat Sheet

Source: OWASP Cheat Sheet Series — HTTP Headers

## Key Takeaways

HTTP response headers are low-effort, high-value security controls. Proper configuration mitigates XSS, clickjacking, MIME confusion, information disclosure, and cross-origin attacks.

## Headers Reference

| Header                         | Status           | Recommended Value                              | Protects Against                      |
| ------------------------------ | ---------------- | ---------------------------------------------- | ------------------------------------- |
| `X-Frame-Options`              | Use CSP instead  | `DENY`                                         | Clickjacking                          |
| `X-XSS-Protection`             | ❌ Disable       | `0`                                            | Legacy XSS filter (creates new vulns) |
| `X-Content-Type-Options`       | ✅ Always        | `nosniff`                                      | MIME sniffing                         |
| `Referrer-Policy`              | ✅ Always        | `strict-origin-when-cross-origin`              | Referrer leakage                      |
| `Content-Type`                 | ✅ Always        | `text/html; charset=UTF-8`                     | XSS via MIME confusion                |
| `Cache-Control`                | Sensitive pages  | `no-store`                                     | Cached sensitive data                 |
| `Strict-Transport-Security`    | ✅ HTTPS sites   | `max-age=63072000; includeSubDomains; preload` | MITM / SSL strip                      |
| `Expect-CT`                    | ❌ Deprecated    | —                                              | —                                     |
| `Content-Security-Policy`      | ✅ Always        | See CSP cheatsheet                             | XSS, injection                        |
| `Access-Control-Allow-Origin`  | If CORS needed   | Specific origin, not `*`                       | Cross-origin data leakage             |
| `Cross-Origin-Opener-Policy`   | Browser contexts | `same-origin`                                  | Spectre/cross-origin attacks          |
| `Cross-Origin-Embedder-Policy` | Browser contexts | `require-corp`                                 | Cross-origin resource loading         |
| `Cross-Origin-Resource-Policy` | Resources        | `same-site`                                    | Cross-origin resource inclusion       |
| `Permissions-Policy`           | ✅ Always        | Disable unused features                        | Feature abuse after XSS               |
| `Server`                       | ✅ Remove        | `webserver` (or remove)                        | Fingerprinting                        |
| `X-Powered-By`                 | ✅ Remove        | —                                              | Tech stack fingerprinting             |
| `X-Robots-Tag`                 | Selective        | `noindex, nofollow`                            | Crawler exposure                      |
| `X-DNS-Prefetch-Control`       | Optional         | `off`                                          | DNS leakage                           |
| `Public-Key-Pins`              | ❌ Deprecated    | —                                              | —                                     |

## Key Points

- **X-XSS-Protection should be disabled** — can introduce XSS in otherwise safe sites. Use CSP instead.
- **Cache-Control `no-cache` ≠ no caching** — it permits caching but requires revalidation. Use `no-store` for strictly sensitive data.
- **CORS `*` caution** — fine for public APIs, dangerous for authenticated endpoints.
- **COOP + COEP + CORP** work together to enable `SharedArrayBuffer` and protect against Spectre-class attacks.
- **Permissions-Policy** limits browser feature surface after XSS — disable geolocation, camera, microphone etc.
- **Secure file download headers**: always use `Content-Disposition: attachment` + `nosniff` for user-provided file serving.

## Implementation Examples

```nginx
# Nginx
add_header "X-Frame-Options" "DENY" always;
add_header "X-Content-Type-Options" "nosniff" always;
add_header "Strict-Transport-Security" "max-age=63072000; includeSubDomains; preload" always;
```

```apache
# Apache (unset first to avoid duplicates)
Header unset X-Frame-Options
Header always set X-Frame-Options "DENY"
```

```js
// Express with helmet
const helmet = require("helmet");
app.use(helmet());
```

## Related Pages

- [HTTP Security Headers concept](../concepts/http-security-headers.md)
- [Content Security Policy](../concepts/content-security-policy.md)
- [HSTS](../concepts/hsts.md)
