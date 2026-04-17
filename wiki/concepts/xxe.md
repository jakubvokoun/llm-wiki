---
title: "XXE (XML External Entity Injection)"
tags: [xml, injection, ssrf, owasp-top-10, security]
sources: [owasp-xxe-prevention.md]
updated: 2026-04-16
---

# XXE (XML External Entity Injection)

CWE-611 / OWASP Top 10 A4. XML parsers that process external entity references in untrusted input can be exploited to:

- Read arbitrary files on the server (`file:///etc/passwd`)
- Trigger [SSRF](ssrf.md) to internal services
- Scan internal ports
- Cause [DoS via Billion Laughs](denial-of-service.md) (recursive entity expansion)
- Exfiltrate data via Blind XXE (out-of-band channels)

## Attack Anatomy

```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<foo>&xxe;</foo>
```

The parser fetches and inlines the external resource as entity content.

## Root Cause

XML's DTD (Document Type Definition) mechanism allows defining entities that reference external URIs. Parsers with DTD/entity processing enabled will fetch those URIs.

## Defenses

1. **Disable DTDs entirely** — eliminates all XXE and Billion Laughs in one step
2. If DTDs required: disable external entity loading + external DTD loading + enable secure processing
3. Disable XInclude
4. Limit entity expansion depth
5. Use safe parser wrappers (defusedxml in Python, hardened factories in Java)

## Language Risk Summary

| Language     | Default Safe? | Action                                             |
| ------------ | ------------- | -------------------------------------------------- |
| Java         | No            | Explicitly disable DTDs on every parser            |
| .NET ≥4.5.2  | Yes           | Verify ASP.NET httpRuntime targetFramework         |
| .NET \<4.5.2 | No            | Set XmlResolver = null                             |
| PHP ≥8.0     | Yes           | —                                                  |
| PHP \<8.0    | No            | `libxml_set_external_entity_loader(null)`          |
| Python       | Partial       | Use defusedxml; still vulnerable to Billion Laughs |
| libxml2 ≥2.9 | Yes           | Avoid XML_PARSE_NOENT                              |

## See Also

- [OWASP XXE Prevention Cheat Sheet](../sources/owasp-xxe-prevention.md)
- [XML Security](xml-security.md)
- [Input Validation](input-validation.md)
- [SSRF](ssrf.md)
