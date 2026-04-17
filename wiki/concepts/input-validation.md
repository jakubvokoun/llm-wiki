---
title: "Input Validation"
tags: [input-validation, security, web, owasp]
sources: [owasp-input-validation.md]
updated: 2026-04-16
---

# Input Validation

Input validation ensures only properly formed data enters an application's processing pipeline. It is a defense-in-depth layer — not the primary defense against XSS or SQL injection, which require output encoding and parameterized queries respectively.

## Two Levels

| Level         | Focus                  | Example                           |
| ------------- | ---------------------- | --------------------------------- |
| **Syntactic** | Correct format         | ZIP code matches `\d{5}(-\d{4})?` |
| **Semantic**  | Correct business value | Start date < end date             |

## Allowlist vs Denylist

**Prefer allowlists.** Define what is permitted; reject everything else.

Denylists (blocking `'`, `1=1`, `<script>`) are:

- Trivially bypassed with encoding/obfuscation
- Prone to false positives (block `O'Brian`)
- Useful only as supplementary layer

For fixed-set inputs (dropdowns): validate server-side against the same set. Any mismatch = high-severity event — attacker is tampering with client code.

## Validation Techniques

- **Framework validators** — Django Validators, Apache Commons Validators
- **Schema validation** — JSON Schema, XML Schema (XSD)
- **Type conversion** with exception handling
- **Range and length checks**
- **Anchored regex** — `^...$`, avoid `.` or `\S` wildcards; beware [ReDoS](../concepts/redos.md)

## Free-form Unicode Text

Not "hard to validate" — just different techniques:

1. **Normalize** — canonical encoding, strip invalid chars
2. **Category allowlist** — Unicode categories (letters, digits) cover all scripts globally
3. **Individual allowlist** — allow specific chars like `'` for names

Input validation is **not** the XSS defense here — context-aware output encoding is.

## Client-side vs Server-side

Client-side validation is UX only. Always duplicate on the server — JS can be disabled or bypassed via web proxy.

## Where to Validate

All external input:

- Web browser submissions
- API calls
- Backend partner/vendor feeds over extranets
- Regulatory data imports

## Related Pages

- [File Upload Security](file-upload-security.md)
- [OWASP Input Validation Cheat Sheet](../sources/owasp-input-validation.md)
- [Prompt Injection](prompt-injection.md) — analogous validation problem for LLM inputs
