---
title: "OWASP Input Validation Cheat Sheet"
tags: [owasp, input-validation, security, web]
sources: [owasp-input-validation.md]
updated: 2026-04-16
---

# OWASP Input Validation Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html

## Overview

Input validation ensures only properly formed data enters application workflows. It is a defense-in-depth measure, **not** the primary defense against XSS or SQL injection (output encoding and parameterized queries serve those roles). Validate all inputs from all sources — not just web browsers but also backend feeds, partners, and regulators.

## Validation Strategies

Two levels of validation:

- **Syntactic** — enforce correct format (SSN, date, zip code)
- **Semantic** — enforce correct values in business context (start < end date, price in range)

## Allowlist vs Denylist

Prefer allowlists. Denylists:

- Are trivially bypassed by attackers
- Block legitimate input (e.g. apostrophe in `O'Brian`)
- May be useful as a secondary layer but never as primary defense

Allowlist approach: define exactly what is permitted; everything else is rejected.

For fixed-option inputs (dropdowns, radio buttons): validate against the exact server-side set. Mismatch = high-severity security event (attacker tampering with client-side code).

## Implementation Techniques

- Framework validators (Django Validators, Apache Commons Validators)
- JSON Schema / XML Schema (XSD) validation
- Type conversion with exception handling
- Range/length checks
- Regex covering whole string (`^...$`), avoid `.` or `\S` wildcards
- Avoid ReDoS-prone patterns

## Unicode Free-form Text

Three approaches:

1. **Normalization** — canonical encoding, remove invalid chars
2. **Category allowlisting** — Unicode categories (letters, digits) covers multiple scripts
3. **Individual character allowlisting** — fine-grained control (allow `'` for names)

## Client-side vs Server-side

Client-side validation = UX only. Always validate server-side; JS can be disabled or bypassed via proxy.

## File Upload Validation

See [File Upload Security](../concepts/file-upload-security.md).

Key points:

- Validate extension against allowlist
- Enforce max file size
- Rename on storage (random filename, never user-supplied)
- Scan for malware
- Never trust Content-Type header; verify via image rewriting libraries
- Deny: `.htaccess`, `.htpasswd`, `crossdomain.xml`, executable scripts

## Email Address Validation

RFC 5321 format is complex; prefer minimal validation + mail server feedback.

Minimum checks:

- Contains `@`
- No dangerous characters (backticks, quotes, null bytes)
- Domain: letters/numbers/hyphens/dots only
- Local part ≤ 63 chars, total ≤ 254 chars

Semantic validation via verification email:

- Token ≥ 32 chars, cryptographically random, single-use, time-limited (≤ 8 hours)

Disposable emails: nearly impossible to block. Sub-addressing (`user+tag@example.org`): don't strip `+` tags — it's not recommended.

## Related Pages

- [Input Validation](../concepts/input-validation.md)
- [File Upload Security](../concepts/file-upload-security.md)
- [OWASP](../entities/owasp.md)
