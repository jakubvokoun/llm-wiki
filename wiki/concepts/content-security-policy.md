---
title: "Content Security Policy (CSP)"
tags: [csp, xss, browser-security, clickjacking, http-headers, defense-in-depth]
sources: [owasp-content-security-policy.md]
updated: 2026-04-16
---

# Content Security Policy (CSP)

Content Security Policy (CSP) is a browser security mechanism delivered via HTTP response headers that restricts what resources a page can load and execute. It is a **defense-in-depth** layer against XSS, clickjacking, and cross-site leaks — not a substitute for secure coding.

## What CSP Defends Against

| Threat                          | CSP Mechanism                          |
| ------------------------------- | -------------------------------------- |
| XSS via inline script injection | Block inline script execution          |
| XSS via remote script injection | Restrict script-src to trusted origins |
| XSS via eval() and similar      | Block unsafe-eval                      |
| Phishing via injected forms     | Restrict form-action targets           |
| Clickjacking                    | `frame-ancestors` directive            |
| Cross-site leaks                | Framing restrictions                   |

## Policy Delivery

**HTTP header (preferred):** `Content-Security-Policy: ...` — send on all responses, full feature support.

**Report-only header:** `Content-Security-Policy-Report-Only: ...` — non-blocking, logs violations. Use before enforcing to detect issues.

**Meta tag:** `<meta http-equiv="Content-Security-Policy" content="...">` — use when headers are out of control (CDN). No framing/sandbox/reporting support.

Run both enforcement and report-only headers simultaneously: strict report-only policy catches issues while loose enforced policy avoids breaking legitimate functionality.

## CSP Types

### Strict CSP (Recommended)

Uses nonce or hash mechanism with `strict-dynamic`. Harder to bypass than allowlist-based CSP.

### Granular/Allowlist-Based (Legacy)

Allowlists of trusted origins per resource type. Frequently bypassed through open redirects, JSONP endpoints, or CDN-hosted attacker content.

## Strict CSP Mechanisms

### Nonce-Based

```
Content-Security-Policy:
  script-src 'nonce-{RANDOM}' 'strict-dynamic';
  object-src 'none';
  base-uri 'none';
```

- Generate a cryptographically random nonce per HTTP response (not page)
- Add `nonce="..."` to all legitimate `<script>` tags
- **Critical:** use a real HTML templating engine — do not middleware-inject nonces into all script tags (attacker scripts would also receive them)

### Hash-Based

```
Content-Security-Policy:
  script-src 'sha256-{HASH}' 'strict-dynamic';
  object-src 'none';
  base-uri 'none';
```

- Hash of exact inline script content (sha256/sha384/sha512)
- Any change to script content (including whitespace) breaks the hash
- Browser developer tools report the expected hash for blocked scripts

### strict-dynamic

Allows scripts dynamically created by a trusted (nonced/hashed) script to also execute, without explicitly listing each source. CSP Level 3, widely supported in modern browsers.

## Core Directives Reference

### Fetch Directives (limit resource sources)

| Directive     | Controls                                          |
| ------------- | ------------------------------------------------- |
| `default-src` | Fallback for all other fetch directives           |
| `script-src`  | JavaScript execution                              |
| `style-src`   | CSS stylesheets                                   |
| `img-src`     | Images                                            |
| `connect-src` | Fetch, XHR, WebSocket, EventSource                |
| `font-src`    | Web fonts                                         |
| `object-src`  | Plugins (`<object>`, `<embed>`) — set to `'none'` |
| `media-src`   | Audio/video                                       |
| `frame-src`   | `<iframe>` content                                |

### Navigation Directives

| Directive         | Controls                                           |
| ----------------- | -------------------------------------------------- |
| `form-action`     | Form submission targets                            |
| `frame-ancestors` | Who can embed this page (replaces X-Frame-Options) |

### Document Directives

| Directive  | Controls                                                              |
| ---------- | --------------------------------------------------------------------- |
| `base-uri` | `<base>` element URLs (set to `'none'` to prevent base-tag injection) |
| `sandbox`  | Page capabilities (form submission, scripts)                          |

### Reporting

| Directive    | Notes                                                                       |
| ------------ | --------------------------------------------------------------------------- |
| `report-to`  | Modern reporting; uses JSON-based Reporting API                             |
| `report-uri` | Legacy; deprecated but use alongside `report-to` for backward compatibility |

### Special Source Values

| Value              | Meaning                                                      |
| ------------------ | ------------------------------------------------------------ |
| `'none'`           | Nothing allowed                                              |
| `'self'`           | Same origin only                                             |
| `'unsafe-inline'`  | Allow inline scripts/styles (avoid — defeats XSS protection) |
| `'unsafe-eval'`    | Allow eval() (avoid)                                         |
| `'strict-dynamic'` | Trust scripts loaded by trusted scripts                      |
| `'nonce-{value}'`  | Trust scripts with matching nonce                            |
| `'sha256-{hash}'`  | Trust scripts with matching hash                             |

## Sample Policies

**Strict nonce-based (recommended for SPAs/dynamic apps):**

```
Content-Security-Policy: script-src 'nonce-{RANDOM}' 'strict-dynamic'; object-src 'none'; base-uri 'none';
```

**Strict hash-based (recommended for static sites):**

```
Content-Security-Policy: script-src 'sha256-{HASH}' 'strict-dynamic'; object-src 'none'; base-uri 'none';
```

**Basic self-origin:**

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

## Code Refactoring for CSP

- Move inline `<script>` blocks to external `.js` files
- Replace inline event handlers (`onclick="..."`) with `addEventListener()` calls
- Remove or replace `eval()`, `Function()`, `setTimeout(string)` calls

## Related Pages

- [Input Validation](input-validation.md)
- [OWASP Content Security Policy Cheat Sheet](../sources/owasp-content-security-policy.md)
