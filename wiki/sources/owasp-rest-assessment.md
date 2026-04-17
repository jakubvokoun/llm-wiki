---
title: "OWASP REST Assessment Cheat Sheet"
tags: [owasp, rest, api, security-testing, pentesting]
sources: [owasp-rest-assessment.md]
updated: 2026-04-16
---

# OWASP REST Assessment Cheat Sheet

## Summary

Guidance for security testing RESTful web services: discovering the hidden attack surface (no standard documentation), collecting full requests via proxy, identifying non-standard URL-embedded and header-based parameters, and optimizing fuzzing strategy.

## Key Takeaways

### Challenge of Testing REST APIs

- REST APIs have no standard documentation like SOAP's WSDL.
- Attack surface is hidden: parameters embedded in URLs, headers, JSON/XML bodies.
- Client-side code dynamically constructs calls — not visible in page links.
- Custom authentication makes standard tools less effective.

### Discovery Approach

1. Seek documentation (WADL, WSDL 2.0, developer guides, config files in framework projects).
2. Use a proxy (ZAP) to collect **full requests** including headers and bodies — not just URLs.

### Identifying Non-Standard Parameters

- **Header parameters**: look for abnormal HTTP headers.
- **URL-embedded parameters**: repeating patterns across URLs (dates, numbers, IDs).
  - Example: `http://server/srv/2013-10-21/use.php` — the date segment is a parameter.
- **Structured values**: JSON or XML parameter values.
- **Extensionless URL segments**: if tech normally uses extensions, the final segment may be a parameter.
  - Example: `http://server/svc/Grid.asmx/GetRelatedListItems`
- **High-variability segments**: a segment with hundreds of values across requests is likely a parameter.

### Verifying Parameters

Set suspected parameter to an invalid value:

- If path element → server returns `404`.
- If parameter → application returns an application-level error (the value is valid at web server level).

### Fuzzing Strategy

- Analyze collected values to determine valid vs. invalid ranges.
- Focus fuzzing on marginal invalid values (e.g., `0` for a positive integer field).
- Look for sequences that allow fuzzing beyond the current user's allocated range (IDOR risk).
- Always emulate the custom authentication mechanism when fuzzing.

## Related Pages

- [REST API Security](../concepts/rest-api-security.md)
- [Authorization](../concepts/authorization.md)
- [IDOR](../concepts/idor.md)
- [Input Validation](../concepts/input-validation.md)
- [OWASP REST Security Cheat Sheet](owasp-rest-security.md)
- [OWASP](../entities/owasp.md)
