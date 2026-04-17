---
title: "OWASP XML Security Cheat Sheet"
tags: [owasp, xml, xxe, dos, injection, schema, ssrf]
sources: [owasp-xml-security.md]
updated: 2026-04-16
---

# OWASP XML Security Cheat Sheet

Source: `raw/owasp-xml-security.md`

## Summary

Covers the full XML attack surface: malformed documents, invalid documents, entity expansion attacks (XXE, Billion Laughs, quadratic blowup), schema poisoning, and SSRF via external entities. Two root attack surfaces: **malformed XML** (not well-formed) and **invalid XML** (well-formed but structurally/semantically unexpected).

## Attack Classes

### Malformed Document Attacks

- **Coercive parsing / DoS:** deeply nested open tags without closing tags exhaust stack; ~30,000 open elements caused stack overflow in Firefox 3.67
- **Asymmetric resource consumption:** malformed docs may take longer to parse; amplified by flood attacks
- **Recovery mode hazards:** parsers operating in recovery mode may normalize CDATA unexpectedly, causing integrity issues

### Invalid Document / Schema Attacks

- **Document without schema:** attacker injects extra tags to manipulate business logic (e.g., `<price>0</price>`)
- **Unrestrictive schema (DTD):** DTD cannot enforce max lengths, numeric ranges, or patterns — use XSD instead
- **Improper numeric types:** using `integer` allows negatives; use `positiveInteger`; `float`/`double` admit `Infinity`/`NaN` — use `decimal` for prices
- **Unbounded occurrences:** `maxOccurs="unbounded"` enables resource exhaustion — set explicit maximums

### Entity Expansion (DoS)

| Attack               | Mechanism                                                        |
| -------------------- | ---------------------------------------------------------------- |
| **Billion Laughs**   | Recursive nested entities → 3×10⁹ expansions → memory exhaustion |
| **Quadratic Blowup** | One large entity referenced N times → O(n²) memory               |
| **Recursive entity** | Circular entity references A→B→A                                 |

### XXE / SSRF

External entity references can be used to:

- Read local files (`file:///etc/passwd`)
- Trigger SSRF to internal HTTP/HTTPS/FTP services
- Perform internal port scanning (complete, error-based, timeout-based, time-based)
- Brute-force internal services (embed credentials in URI)
- Exfiltrate data via parameter entities and out-of-band HTTP calls

### Schema Poisoning

- **Embedded schema:** attacker controls inline DTD in the XML body
- **Incorrect local file permissions:** writable DTD file allows tampering
- **Remote schema via HTTP (MitM):** plaintext schema transmission enables tampering
- **DNS cache poisoning:** HTTPS schema references can be hijacked if DNS is compromised
- **Evil employee:** third-party hosted schemas can be modified to affect all users

## Hardening Recommendations

1. Use **XSD** (not DTD) — richer type constraints, no entity expansion risk
2. Validate every element: use `enumeration`, range (`minLength`/`maxLength`), `pattern`, `assertion`
3. Never use `maxOccurs="unbounded"` without rate-limiting
4. Disable DTD/external entity processing (see [XXE Prevention](owasp-xxe-prevention.md))
5. Use W3C-conformant parsers; disable recovery mode for untrusted input
6. Fetch schemas over HTTPS; verify integrity; prefer local copies
7. Restrict schema file permissions
8. Use `positiveInteger` for denominators; `decimal` for monetary values

## Related Concepts

- [XXE](../concepts/xxe.md) — entity injection attacks
- [XML Security](../concepts/xml-security.md)
- [Input Validation](../concepts/input-validation.md)
- [SSRF](../concepts/ssrf.md)
