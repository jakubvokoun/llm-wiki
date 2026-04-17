---
title: "OWASP HTTP Strict Transport Security Cheat Sheet"
tags: [owasp, hsts, tls, https, browser-security]
sources: [owasp-hsts.md]
updated: 2026-04-16
---

# OWASP HTTP Strict Transport Security Cheat Sheet

Source: OWASP Cheat Sheet Series — HTTP Strict Transport Security

## Key Takeaways

HSTS (RFC 6797, 2012) is a browser-enforced security policy that forces HTTPS connections, eliminating a class of downgrade and SSL-stripping attacks. Once set, the browser enforces it client-side — the server cannot be bypassed via HTTP.

## Threats Addressed

| Threat                                      | How HSTS Helps                             |
| ------------------------------------------- | ------------------------------------------ |
| User types `http://` or uses HTTP bookmark  | Auto-redirects to HTTPS                    |
| App inadvertently serves HTTP links/content | Auto-redirects to HTTPS                    |
| MITM with invalid certificate               | User cannot override the certificate error |

## Header Examples

```
# Simple — lacks includeSubDomains (dangerous)
Strict-Transport-Security: max-age=63072000

# With subdomains — more secure, blocks HTTP on all subdomains
Strict-Transport-Security: max-age=63072000; includeSubDomains

# Short max-age for initial rollout
Strict-Transport-Security: max-age=86400; includeSubDomains

# Recommended — enables preload list submission
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```

## Preload List

- Maintained by Chrome, used by Firefox and Safari.
- Submit domain at [hstspreload.org](https://hstspreload.org).
- **Warning:** Preloading has **permanent consequences** — once submitted, all subdomains must support HTTPS or users cannot access them at all. Removal takes months.

## Risks and Problems

- **Misconfiguration risk:** If HSTS is set for a long duration and TLS cert expires/is revoked, users are locked out until max-age expires.
- **Privacy leak:** HSTS state persists in the browser and can be used to track users across sessions (HSTS super-cookie).
- **Cookie attacks:** Without `includeSubDomains`, subdomains can manipulate cookies. Always use `includeSubDomains` and set `Secure` flag on all cookies.

## Browser Support

All modern browsers (since September 2019), except Opera Mini.

## Related Pages

- [HSTS concept](../concepts/hsts.md)
- [HTTP Security Headers](../concepts/http-security-headers.md)
- [Content Security Policy](../concepts/content-security-policy.md)
