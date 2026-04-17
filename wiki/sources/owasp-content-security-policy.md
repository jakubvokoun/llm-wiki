---
title: "OWASP Content Security Policy Cheat Sheet"
tags: [owasp, csp, xss, clickjacking, browser-security, http-headers]
sources: [owasp-content-security-policy.md]
updated: 2026-04-16
---

# OWASP Content Security Policy Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html

## Key Takeaways

Content Security Policy (CSP) is a browser-enforced **defense-in-depth** mechanism that restricts what content a page can load and execute. It does not prevent vulnerabilities from existing, but makes exploitation significantly harder. CSP is **not a substitute** for secure coding practices — it's an additional layer.

## What CSP Defends Against

1. **XSS** — restricts inline scripts, remote scripts, unsafe JS functions (eval), form submission targets, and object tags
2. **Clickjacking** — via `frame-ancestors` directive (replaces `X-Frame-Options`)
3. **Cross-site leaks** — via framing restrictions

## Policy Delivery Methods

| Method                                       | Notes                                                                           |
| -------------------------------------------- | ------------------------------------------------------------------------------- |
| `Content-Security-Policy` header             | Preferred; full feature support; send on all responses                          |
| `Content-Security-Policy-Report-Only` header | Non-blocking; reports violations; use for testing before enforcement            |
| `<meta http-equiv>` tag                      | Use when headers are out of control (CDN); no framing/sandbox/reporting support |

Both enforcement and report-only headers can be used simultaneously (e.g., loose enforced + strict report-only).

**Never use** `X-Content-Security-Policy` or `X-WebKit-CSP` — obsolete.

## CSP Types

### Granular/Allowlist-Based (Legacy Approach)

Fine-grained allowlists of permitted sources. Difficult to maintain and frequently bypassable.

### Strict CSP (Modern Best Practice)

Uses a small number of fetch directives + nonce or hash mechanism. Harder to bypass.

## Strict CSP Mechanisms

### Nonce-Based

```
Content-Security-Policy: script-src 'nonce-{RANDOM}' 'strict-dynamic'; object-src 'none'; base-uri 'none';
```

- Generate a cryptographically random nonce per HTTP response
- Add `nonce="..."` attribute to legitimate script tags
- **Warning**: don't use middleware to add nonces to all script tags — attacker-injected scripts would also receive the nonce

### Hash-Based

```
Content-Security-Policy: script-src 'sha256-{HASHED_INLINE_SCRIPT}' 'strict-dynamic'; object-src 'none'; base-uri 'none';
```

- SHA hash of exact inline script content
- Any change to the script (including whitespace) invalidates the hash

### strict-dynamic

Allows scripts loaded by a nonced/hashed script to also execute, without explicitly listing each one. CSP Level 3, widely supported.

## Key Directives

### Fetch Directives

| Directive     | Purpose                                 |
| ------------- | --------------------------------------- |
| `default-src` | Fallback for all other fetch directives |
| `script-src`  | Script execution sources                |
| `style-src`   | Stylesheet sources                      |
| `img-src`     | Image sources                           |
| `connect-src` | Fetch/XHR/WebSocket connections         |
| `font-src`    | Font sources                            |
| `object-src`  | Plugin sources (set to `'none'`)        |
| `media-src`   | Audio/video sources                     |
| `child-src`   | Nested browsing contexts and workers    |

### Navigation Directives

| Directive         | Purpose                                        |
| ----------------- | ---------------------------------------------- |
| `form-action`     | Restricts form submission targets              |
| `frame-ancestors` | Restricts embedding (replaces X-Frame-Options) |

### Document Directives

| Directive  | Purpose                                                 |
| ---------- | ------------------------------------------------------- |
| `base-uri` | Restricts `<base>` element URLs                         |
| `sandbox`  | Restricts page actions (form submission, scripts, etc.) |

### Reporting

| Directive    | Purpose                                                                             |
| ------------ | ----------------------------------------------------------------------------------- |
| `report-to`  | Modern violation reporting endpoint                                                 |
| `report-uri` | Legacy reporting endpoint (deprecated; use alongside `report-to` for compatibility) |

### Special Source Values

| Value             | Meaning                              |
| ----------------- | ------------------------------------ |
| `'none'`          | Nothing allowed                      |
| `'self'`          | Same origin only                     |
| `'unsafe-inline'` | Allows inline scripts/styles (avoid) |
| `'unsafe-eval'`   | Allows eval() (avoid)                |

## Sample Policies

**Nonce-based Strict (recommended):**

```
Content-Security-Policy: script-src 'nonce-{RANDOM}' 'strict-dynamic'; object-src 'none'; base-uri 'none';
```

**Hash-based Strict:**

```
Content-Security-Policy: script-src 'sha256-{HASH}' 'strict-dynamic'; object-src 'none'; base-uri 'none';
```

**Basic self-origin only:**

```
Content-Security-Policy: default-src 'self'; frame-ancestors 'self'; form-action 'self';
```

**Prevent all framing (anti-clickjacking):**

```
Content-Security-Policy: frame-ancestors 'none';
```

**Force HTTPS:**

```
Content-Security-Policy: upgrade-insecure-requests;
```

## Refactoring for CSP Compliance

- Move inline scripts to external `.js` files
- Replace inline event handlers (`onclick="..."`) with `addEventListener` calls
- Avoid `eval()` and similar text-to-code functions

## Related Pages

- [Content Security Policy](../concepts/content-security-policy.md)
- [Input Validation](../concepts/input-validation.md)
- [OWASP](../entities/owasp.md)
