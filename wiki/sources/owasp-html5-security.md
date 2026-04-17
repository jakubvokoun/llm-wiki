---
title: "OWASP HTML5 Security Cheat Sheet"
tags:
  [
    owasp,
    html5,
    xss,
    cors,
    webstorage,
    postmessage,
    tabnabbing,
    csp,
    browser-security,
  ]
sources: [owasp-html5-security.md]
updated: 2026-04-16
---

# OWASP HTML5 Security Cheat Sheet

Source: `raw/owasp-html5-security.md`

## Summary

Security guidance for HTML5 APIs: postMessage, CORS, WebSockets, localStorage, Web Workers, tabnabbing, sandboxed iframes, and PII input handling.

## Communication APIs

### Web Messaging (postMessage)

| Risk                    | Mitigation                                                                    |
| ----------------------- | ----------------------------------------------------------------------------- |
| Sending to wrong origin | Always specify exact target origin as 2nd arg — never `*`                     |
| Receiving from attacker | Always check `event.origin` against allowlist                                 |
| XSS via eval            | Treat `event.data` as data, never `eval()` or `innerHTML`                     |
| Weak origin check       | Exact FQDN match — `indexOf(".owasp.org")` is insufficient (subdomain bypass) |

Safe pattern: `element.textContent = data` instead of `element.innerHTML = data`

### CORS

- Never use `Access-Control-Allow-Origin: *` for endpoints with sensitive data
- Allowlist specific trusted domains — don't blindly reflect `Origin` header
- CORS does **not** replace CSRF protection — still implement CSRF tokens
- Don't rely solely on `Origin` header — can be spoofed outside browser context
- Discard plain-HTTP requests from HTTPS origins (mixed content)

### Server-Sent Events

- Validate URL passed to `EventSource` constructor
- Check `event.origin` allowlist before processing messages
- Treat `event.data` as data — never evaluate as HTML/script

## Storage APIs

### localStorage / sessionStorage

Critical rules:

- **Never store session IDs** — always accessible to JavaScript (use `httpOnly` cookies instead)
- **Never store sensitive data** — any XSS vulnerability exfiltrates all stored data
- **Never trust stored data** — XSS can also write malicious data into storage
- Prefer `sessionStorage` (tab-scoped, cleared on close) over `localStorage` (persistent)
- Don't share origins across multiple apps — all apps on same origin share localStorage; use subdomains

### Client-side Databases (IndexedDB)

- Don't store sensitive information
- IndexedDB content is vulnerable to SQL injection if misused — validate and parameterize queries
- Data can be poisoned via XSS — never trust without validation

## Geolocation

- Always require explicit user input before calling `getCurrentPosition` or `watchPosition`
- Don't cache or persist location data beyond immediate need

## Web Workers

- Web Workers can issue XHR/CORS requests — apply same CORS rules
- Don't create Worker scripts from user-supplied input (enables code execution)
- Validate all messages exchanged with workers — never `eval()` worker messages

## Tabnabbing

**Attack**: A newly opened tab/window can navigate the opener page via `window.opener`. Used in phishing — malicious child page redirects parent to fake login.

**Mitigations**:

```html
<!-- HTML links -->
<a href="..." rel="noopener noreferrer">link</a>
```

```javascript
// JavaScript window.open
function openPopup(url, name, features) {
  var w = window.open(url, name, "noopener,noreferrer," + features);
  w.opener = null;
}
```

```
// HTTP header
Referrer-Policy: no-referrer
```

## Sandboxed Frames

`sandbox` attribute on `<iframe>` enables full restrictions by default:

1. Unique origin (no same-origin access)
2. Forms and scripts disabled
3. Links can't target other browsing contexts
4. Auto-triggering features blocked
5. Plugins disabled

Individual capabilities can be re-granted explicitly (e.g., `allow-scripts`, `allow-forms`).

Also: use `X-Frame-Options: DENY` or `SAMEORIGIN` to prevent framing by external pages. Framebusting JS (`if(window!==window.top)`) is unreliable — use HTTP headers instead.

## PII / Credential Input Protection

Prevent browser from caching sensitive input values:

```html
<input
  type="text"
  autocomplete="off"
  spellcheck="false"
  autocorrect="off"
  autocapitalize="off"
/>
```

Apply to: username, password, credit card, address, phone, email fields.

## Offline Applications

- Cache poisoning risk on insecure networks — require user confirmation before caching `manifest`
- Users should clean cache after using open/untrusted networks

## HTTP Headers

See [HTTP Security Headers](../concepts/http-security-headers.md) and [Content Security Policy](../concepts/content-security-policy.md).

Key headers for HTML5 contexts:

- `Content-Security-Policy` — restrict script sources, prevent XSS
- `X-Frame-Options` — prevent clickjacking/framing
- `Referrer-Policy` — prevent information leakage via referrer
- `CORS` headers — restrict cross-origin access

## Related Concepts

- [dom-xss](../concepts/dom-xss.md)
- [content-security-policy](../concepts/content-security-policy.md)
- [http-security-headers](../concepts/http-security-headers.md)
- [input-validation](../concepts/input-validation.md)
- [tabnabbing](../concepts/tabnabbing.md)
- [browser-storage-security](../concepts/browser-storage-security.md)
