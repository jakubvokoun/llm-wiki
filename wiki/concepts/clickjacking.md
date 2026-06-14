---
title: "Clickjacking"
tags: [clickjacking, ui-redress, web-security, csp]
sources: [owasp-css-security.md]
updated: 2026-06-14
---

# Clickjacking

A UI-redress attack where a victim is tricked into clicking something different from what they perceive — typically by loading the target site in a transparent or disguised `<iframe>` overlaid on attacker-controlled content. The user thinks they click the attacker's page; the click actually lands on the framed, authenticated target (a "like", a transfer, a permission grant).

## Variants

- **Frame overlay** — transparent iframe of the target positioned under a decoy button.
- **CSS-based** — attacker-supplied HTML/CSS makes an entire region clickable or repositions elements. The LinkedIn case: user-controlled CSS caused a full-page clickjack where clicking anywhere loaded an attacker URL. See [CSS Security](css-security.md).
- **Cursorjacking / likejacking** — visual misdirection of the cursor or social-widget framing.

## Defenses

- **`Content-Security-Policy: frame-ancestors`** — the modern, primary control; specifies who may frame the page (`'none'` or an allowlist). See [Content Security Policy](content-security-policy.md) and [HTTP Security Headers](http-security-headers.md).
- **`X-Frame-Options: DENY|SAMEORIGIN`** — older header, still useful for legacy browsers; superseded by `frame-ancestors`.
- Sanitize/limit any user-supplied HTML/CSS so it cannot reposition or overlay page elements ([input validation](input-validation.md)).
- Sensitive actions: require re-authentication or interaction that cannot be framed.

## Related

- [Content Security Policy](content-security-policy.md) · [HTTP Security Headers](http-security-headers.md) · [CSS Security](css-security.md) · [Tabnabbing](tabnabbing.md)

## Sources

- [OWASP CSS Security Cheat Sheet](../sources/owasp-css-security.md)
