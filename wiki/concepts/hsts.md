---
title: "HTTP Strict Transport Security (HSTS)"
tags: [hsts, tls, https, browser-security, transport-security]
sources: [owasp-hsts.md]
updated: 2026-04-16
---

# HTTP Strict Transport Security (HSTS)

HSTS is a browser-enforced security policy declared via the `Strict-Transport-Security` HTTP response header. Once received, the browser refuses all HTTP connections to that domain for the duration of `max-age`, enforcing HTTPS at the client — no server redirect needed.

**Standardized:** RFC 6797 (2012). **Browser support:** all modern browsers.

## How It Works

1. Site sends `Strict-Transport-Security` header over HTTPS.
2. Browser records the domain + `max-age` in an internal HSTS list.
3. For all future requests to that domain within `max-age`, the browser automatically upgrades HTTP → HTTPS.
4. If the TLS certificate is invalid, the browser **cannot be bypassed** — it does not show a click-through warning.

## Header Syntax

```
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```

| Directive           | Effect                                                  |
| ------------------- | ------------------------------------------------------- |
| `max-age=N`         | Browser enforces HTTPS for N seconds from last receipt  |
| `includeSubDomains` | Applies policy to all subdomains                        |
| `preload`           | Signals consent to be included in browser preload lists |

## Recommended Values

| Use case                 | Header                                         |
| ------------------------ | ---------------------------------------------- |
| Initial rollout (safe)   | `max-age=86400; includeSubDomains`             |
| Production               | `max-age=63072000; includeSubDomains`          |
| Preload list eligibility | `max-age=63072000; includeSubDomains; preload` |

## HSTS Preload

- Chrome maintains the preload list; Firefox and Safari use it too.
- Submit at [hstspreload.org](https://hstspreload.org).
- **Warning:** Preloading is permanent — users cannot access the site or ANY subdomain over HTTP. Removal takes months. Only preload if ALL subdomains will permanently support HTTPS.

## Risks

| Risk                      | Detail                                                         |
| ------------------------- | -------------------------------------------------------------- |
| Misconfiguration lock-out | Long max-age + expired/revoked cert = users locked out         |
| HSTS super-cookie         | HSTS state can track users across sessions (privacy leak)      |
| Subdomain cookie attacks  | Without `includeSubDomains`, subdomains can manipulate cookies |

**Mitigation:** Start with a short `max-age`, verify all subdomains support HTTPS, then increase.

## What HSTS Does NOT Cover

- First visit over HTTP before HSTS is received (mitigated by preload list).
- Non-HSTS-supporting browsers (e.g. Opera Mini).
- Certificate validity (that's handled by PKI/CT).

## Related Pages

- [HTTP Security Headers](http-security-headers.md)
- [Content Security Policy](content-security-policy.md)
- [OWASP HSTS source](../sources/owasp-hsts.md)
