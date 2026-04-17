---
title: "XML Security"
tags: [xml, xxe, dos, schema, ssrf, injection]
sources: [owasp-xml-security.md, owasp-xxe-prevention.md]
updated: 2026-04-16
---

# XML Security

XML's flexibility and DTD feature set create a wide attack surface. Key threat categories:

## Threat Categories

### Entity Expansion (DoS)

DTD entity references can be nested recursively or expanded quadratically:

- **Billion Laughs:** 9-level nested entities → ~3×10⁹ expansions → memory exhaustion
- **Quadratic Blowup:** one large entity referenced N times → O(n²) memory
- **Primary defense:** disable DTD parsing entirely

### XXE (External Entity Injection)

See [XXE](xxe.md). Allows file read, SSRF, port scanning, brute force. Root cause: DTD `SYSTEM` entity pointing to `file://` or `http://` URIs.

### Schema-Level Attacks

- **No schema:** structural injection (extra tags alter business logic)
- **Weak schema (DTD):** no numeric range, length, or pattern enforcement
- **Schema poisoning:** attacker modifies DTD file (incorrect permissions) or intercepts remote DTD (MitM, DNS poisoning)

### Malformed Document DoS

- Coercive parsing: deeply nested unclosed tags exhaust parser stack
- Recovery mode inconsistencies: parsers normalizing CDATA sections unexpectedly

### SSRF via Entities

Parameter entity chains can exfiltrate file contents to attacker-controlled HTTP endpoints.

## Defenses

| Threat                    | Defense                                                    |
| ------------------------- | ---------------------------------------------------------- |
| Billion Laughs / XXE      | Disable DTD entirely                                       |
| Schema injection          | Use XSD with strict types; avoid inline DTDs               |
| Remote schema MitM        | Fetch over HTTPS; verify integrity; use local copy         |
| Unbounded elements        | Set explicit `maxOccurs`                                   |
| Numeric edge cases        | `positiveInteger` for IDs/quantities; `decimal` for prices |
| Parser malformed handling | Use strict W3C-conformant parsers; disable recovery mode   |

## See Also

- [XXE](xxe.md) — external entity injection details
- [OWASP XML Security Cheat Sheet](../sources/owasp-xml-security.md)
- [OWASP XXE Prevention Cheat Sheet](../sources/owasp-xxe-prevention.md)
- [Input Validation](input-validation.md)
- [SSRF](ssrf.md)
