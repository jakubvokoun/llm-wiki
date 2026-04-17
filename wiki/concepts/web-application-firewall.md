---
title: "Web Application Firewall (WAF)"
tags: [waf, security, firewall, cloud, ddos, xss, sqli]
sources: [owasp-secure-cloud-architecture.md]
updated: 2026-04-15
---

# Web Application Firewall (WAF)

A WAF monitors or blocks HTTP traffic based on rules, typically deployed as a first line of defense at application entry points.

## Purpose

- Block known attack payloads (XSS, SQLi, RCE)
- Allow only specific request types and patterns
- Rate-limit sensitive endpoints
- Provide early detection before traffic reaches application code

## Deployment

Attach to entry points:

- Load balancers
- API gateways
- CDN edge nodes

## Provider Rulesets

Cloud providers maintain curated rulesets:

- **AWS**: AWS Managed Rules (WAF)
- **GCP**: Cloud Armor WAF Rules
- **Azure**: Core Rule Sets (CRS) via Application Gateway WAF

Managed rulesets are generic — they won't cover every app-specific attack.

## Custom Rules

Supplement managed rules with application-specific rules:

- Allowlist valid routes (block web scraping / enumeration)
- Rate-limit authentication and sensitive API endpoints
- Technology-specific protections (known CVEs in frameworks)
- Geo-blocking if appropriate

## WAF Limitations

- Not a substitute for secure application code
- False positives require ongoing tuning
- Cannot inspect encrypted payloads (at layers below TLS termination)
- Advanced attackers can evade WAF rules — defense in depth required

## Related to DDoS

WAF rate limits provide basic L7 DDoS mitigation. For volumetric or sophisticated DDoS, combine with:

- AWS Shield (Standard/Advanced)
- GCP Cloud Armor Managed Protection
- Azure DDoS Protection

## Related Concepts

- [cloud-architecture-security](cloud-architecture-security.md)

## Sources

- [OWASP Secure Cloud Architecture Cheat Sheet](../sources/owasp-secure-cloud-architecture.md)
