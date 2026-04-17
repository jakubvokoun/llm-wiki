---
title: "Encoding and Escaping"
tags: [encoding, escaping, sanitization, xss, injection, input-handling]
sources: [owasp-security-terminology.md]
updated: 2026-04-16
---

# Encoding and Escaping

## Definitions

**Encoding:** Transform data into a different format using a publicly known scheme for compatibility/transport. NOT a security control. Always reversible.

- Examples: Base64, URL encoding, HTML entity encoding

**Escaping:** Sub-type of encoding. Prefix specific characters with a signal character (backslash, `&`, etc.) so a parser treats them as data, not control characters.

- Examples: `\'` in SQL, `\n` in strings, `&lt;` in HTML
- Security purpose: prevent injection (XSS, SQLi)

**Sanitization:** Remove, replace, or modify dangerous characters/content to make input conform to a security policy. Lossy/destructive.

- Examples: strip `<script>` tags from HTML, remove path traversal `../` sequences
- Use as secondary defense; prefer parameterized queries or output escaping

**Serialization:** Convert object/data structure to a storable/transmittable format. Reversible.

- Security risk: **Insecure Deserialization** — untrusted data reconstructed into objects → potential RCE (OWASP Top 10 A08)

## Key Distinctions

- Encoding ≠ security: Base64 is not encryption; URL encoding is not protection
- Output escaping context matters: HTML escaping ≠ SQL escaping ≠ JS escaping
- Sanitization is lossy: it changes or removes data; escaping preserves it safely
- Context-aware encoding is required: encode for the target output context (HTML body vs HTML attribute vs JavaScript vs URL)

## Security Applications

| Technique                     | Defense Against     |
| ----------------------------- | ------------------- |
| HTML entity encoding          | XSS in HTML context |
| JavaScript escaping           | XSS in JS context   |
| SQL parameterization          | SQL injection       |
| URL encoding                  | URL injection       |
| HTML sanitization (DOMPurify) | Rich HTML XSS       |

## Related Pages

- [Input Validation](input-validation.md)
- [DOM-based XSS](dom-xss.md)
- [Content Security Policy](content-security-policy.md)
- [OWASP Security Terminology](../sources/owasp-security-terminology.md)
