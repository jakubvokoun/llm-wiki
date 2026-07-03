---
title: "Server-Side Request Forgery (SSRF)"
tags: [ssrf, injection, web-security, owasp-top-10, cloud]
sources: [owasp-xxe-prevention.md, owasp-xml-security.md]
updated: 2026-06-14
---

# Server-Side Request Forgery (SSRF)

An attack where the server is tricked into making HTTP (or other protocol) requests to a destination chosen by the attacker. Because the request originates from the server, it can reach **internal services, cloud metadata endpoints, and other resources that are not reachable from the outside**. OWASP Top 10 category (A10:2021).

## Why it is dangerous

- **Internal network access** — hit services bound to `localhost` or private ranges (admin panels, databases, `169.254.169.254`).
- **Cloud credential theft** — the classic target is the instance metadata service (IMDSv1: `http://169.254.169.254/latest/meta-data/iam/security-credentials/`), which can yield temporary cloud credentials.
- **Port scanning / recon** of the internal network via response-timing or error differences.
- **Protocol smuggling** — `file://`, `gopher://`, `dict://` to read files or talk to non-HTTP services.

## Common entry points

- URL/parameter fetchers (webhooks, PDF/image generators, link previews, import-from-URL).
- **[XXE](xxe.md)** — an external entity (`SYSTEM "http://internal/"`) makes the XML parser issue the request; SSRF is one of the primary impacts of XXE.
- Misparsed redirects and open proxies.

## Defenses

- **Allowlist** destinations (scheme + host + port); never rely on a denylist. See [input validation](input-validation.md).
- Resolve the hostname and **validate the resolved IP** against private/link-local ranges — re-validate after DNS resolution to defeat DNS-rebinding and TOCTOU.
- Disable unneeded URL schemes and **follow-redirect** behavior.
- Use IMDSv2 (token-bound) or block metadata IPs at the network layer ([cloud architecture security](cloud-architecture-security.md)).
- Network egress controls / a [WAF](web-application-firewall.md) as defense-in-depth, not the primary control.

## Related

- [XXE](xxe.md)
- [XML Security](xml-security.md)
- [Input Validation](input-validation.md)
- [Cloud Architecture Security](cloud-architecture-security.md)

## Sources

- [OWASP XML External Entity Prevention](../sources/owasp-xxe-prevention.md)
- [OWASP XML Security](../sources/owasp-xml-security.md)
