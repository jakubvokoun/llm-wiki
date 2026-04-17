# HTTP Strict Transport Security Cheat Sheet

## Introduction

HTTP Strict Transport Security (HSTS) is an opt-in security enhancement specified by a web application through a special response header. Once a supported browser receives this header, it will:

* Prevent communications over HTTP to the specified domain.
* Send all communications over HTTPS.
* Prevent HTTPS click-through prompts.

Specified in RFC 6797 (published end of 2012).

## Threats HSTS Addresses

* User bookmarks or manually types `http://example.com` → HSTS automatically redirects to HTTPS.
* Web app inadvertently contains HTTP links or serves content over HTTP → HSTS redirects.
* MITM attacker intercepts with invalid certificate hoping user accepts it → HSTS does not allow override.

## Examples

Simple example (lacks `includeSubDomains`, dangerous):
```
Strict-Transport-Security: max-age=63072000
```

With subdomains (more secure, blocks HTTP-only subdomains):
```
Strict-Transport-Security: max-age=63072000; includeSubDomains
```

Short max-age for initial rollout:
```
Strict-Transport-Security: max-age=86400; includeSubDomains
```

**Recommended (for HSTS preload list submission):**
```
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```

**Warning:** `preload` has **permanent consequences** — it prevents users from accessing your site and subdomains over HTTP. Read preload removal details before using.

## Problems

* HSTS can be used to identify users without cookies (privacy leak).
* Omitting `includeSubDomains` permits cookie-related attacks via subdomains.
* `secure` flag on cookies reduces but does not eliminate all such attacks.

## Browser Support

Supported by all modern browsers (as of September 2019), except Opera Mini.

## References

* Chromium Projects HSTS preload list
* OWASP TLS Protection Cheat Sheet
* sslstrip tool — demonstrates SSL stripping attacks HSTS defends against
