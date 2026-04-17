---
title: "Tabnabbing"
tags: [tabnabbing, browser-security, phishing, opener, javascript]
sources: [owasp-html5-security.md]
updated: 2026-04-16
---

# Tabnabbing

A phishing attack where a newly opened tab/window navigates the opener (parent) page to a malicious URL via the `window.opener` reference.

## Attack Flow

1. Victim on `legitimate.com` clicks a link that opens `attacker.com` in a new tab
2. `attacker.com` executes: `window.opener.location = 'https://fake-legitimate.com/login'`
3. Victim switches back to the original tab — it now shows a fake login page
4. Victim enters credentials, believing they're logging into the real site

## Root Cause

HTML links and `window.open()` with `target="_blank"` (or any non-self target) expose `window.opener` to the child page, giving it a reference back to the parent's `location` object.

## Mitigations

### HTML links

```html
<a href="..." rel="noopener noreferrer">External link</a>
```

- `noopener` — severs `window.opener` reference
- `noreferrer` — also strips Referer header from outgoing request

### JavaScript

```javascript
function openPopup(url, name, features) {
  var w = window.open(url, name, "noopener,noreferrer," + features);
  w.opener = null; // belt and suspenders
}
```

### HTTP header

```
Referrer-Policy: no-referrer
```

Add to all responses to strip referrer globally.

## Browser Support

Modern browsers (Chrome 88+, Firefox, Safari) treat `target="_blank"` as implicitly having `rel="noopener"`. However, explicit annotation is still recommended for older browser support and clarity.

## Related Concepts

- [dom-xss](dom-xss.md)
- [content-security-policy](content-security-policy.md)
- [http-security-headers](http-security-headers.md)

## Sources

- [OWASP HTML5 Security Cheat Sheet](../sources/owasp-html5-security.md)
