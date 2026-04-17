---
title: "OWASP Web Service Security Cheat Sheet"
tags: [owasp, soap, xml, web-services, tls, xxe, dos]
sources: [owasp-web-service-security.md]
updated: 2026-04-16
---

# OWASP Web Service Security Cheat Sheet

Source: `raw/owasp-web-service-security.md`

## Overview

Security rules for SOAP/XML web services. High-level guidance applicable across frameworks. Covers 13 areas from transport to DoS protection.

## Rules by Category

### Transport Confidentiality

- All communication involving sensitive data or auth must use TLS
- TLS adds integrity, replay protection, and server authentication beyond just encryption

### Server Authentication

- Validate TLS cert: trusted CA, not expired, not revoked, FQDN matches, private key proof

### User Authentication

- Basic Auth must be over TLS only (base64 is not encryption — credentials exposed)
- **Recommended**: Mutual TLS (mTLS) / client certificate authentication

### Message Integrity (Data at Rest)

- Public key encryption provides confidentiality but NOT integrity or sender identity
- **Use XML digital signatures** with sender's private key; recipient validates with sender's public cert

### Message Confidentiality

- Sensitive data: use strong cipher + adequate key length
- Data that must remain encrypted at rest after receipt: use **data encryption**, not just transport encryption

### Authorization

- Authorize every request (not just at connection time)
- Check both coarse-grained (method access) and fine-grained (resource access)
- Require re-challenge for sensitive changes (password, email, payment details)
- Admin functions should be in a **separate application** from normal web services

### Schema Validation (SOAP/XSD)

- Validate SOAP payloads against XSD schema
- XSD must define: max length, character set, and allowlist patterns for every parameter

### Content Validation (XML)

- Validate against malformed XML entities
- Protect against XML Bomb (Billion Laughs Attack) — recursive entity expansion
- Validate against XXE (XML External Entity) attacks
- Use strong allowlist validation for all inputs

### Output Encoding

- Apply standard XSS output encoding rules (AJAX/HTML consumers)

### Virus Scanning

- For SOAP attachments: inline virus scanning before writing to disk
- Keep virus definitions current

### Message Size

- Set appropriate SOAP message size limit
- No limit = easier DoS via oversized messages

### Availability / Resource Limiting

- Limit CPU, memory, open files, network connections, and processes
- Tune for max message throughput to avoid DoS-like saturation

### XML Denial of Service Protection

- Validate against: recursive payloads, oversized payloads, entity expansion, overlong element/action names
- Verify parser resistance with test cases

### Compliance

- Must comply with WS-I (Web Services Interoperability) Basic Profile minimum

## Related Pages

- [TLS](../concepts/tls.md)
- [Authentication](../concepts/authentication.md)
- [Authorization](../concepts/authorization.md)
- [Input Validation](../concepts/input-validation.md)
- [REST API Security](../concepts/rest-api-security.md)
