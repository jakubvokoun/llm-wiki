---
title: "OWASP Transport Layer Security Cheat Sheet"
tags: [owasp, tls, ssl, certificates, cryptography, https]
sources: [owasp-tls-security.md]
updated: 2026-04-16
---

# OWASP Transport Layer Security Cheat Sheet

Source: `raw/owasp-tls-security.md`

## Overview

TLS provides three guarantees when correctly implemented: **confidentiality** (no eavesdropping), **integrity** (no tampering/replay), and **authentication** (server identity verified). Client identity is not verified unless client certificates (mTLS) are used.

## Protocol Versions

- **TLS 1.3** — current standard; prefer this
- **TLS 1.2** — acceptable if needed for compatibility
- **TLS 1.1, 1.0, SSL 3, SSL 2** — all deprecated; disable
- PCI DSS forbids TLS 1.0 in production

## Server Configuration

- **Ciphers**: prefer GCM ciphers; always disable null, anonymous, and EXPORT ciphers
- **Diffie-Hellman (TLS 1.3)**: use named groups via `supported_groups` extension (`x25519`, `prime256v1`, `ffdhe2048–8192` from RFC 7919)
- **Compression**: disable (prevents CRIME attack)
- **Patching**: keep TLS libraries current (e.g. Heartbleed-class vulnerabilities)

### DH Group Config Examples

```
# OpenSSL (openssl.cnf)
Groups = x25519:prime256v1:x448:ffdhe2048:ffdhe3072

# Apache
SSLOpenSSLConfCmd Groups x25519:secp256r1:ffdhe3072

# NGINX
ssl_ecdh_curve x25519:secp256r1:ffdhe3072;
```

## Certificate Guidance

| Aspect         | Recommendation                                              |
| -------------- | ----------------------------------------------------------- |
| Key size       | ≥2048 bits RSA; see NIST SP 800-57                          |
| Hash           | SHA-256 (not MD5, not SHA-1)                                |
| Domain name    | FQDN in SAN; CN for compatibility                           |
| Wildcard certs | Avoid unless genuinely needed; never cross trust levels     |
| CA type        | Public CA for internet apps; LetsEncrypt for free DV certs  |
| CAA records    | Use DNS CAA to restrict which CAs can issue for your domain |

### Certificate Validation Types

- **DV (Domain Validated)**: proof of domain control; minimum required
- **OV (Organization Validated)**: org info in cert subject
- **EV (Extended Validation)**: highest human verification; browsers no longer visually distinguish EV (deprecated UI since 2019)
- Security-wise all three are equivalent — attacker only needs domain control

## Application-Level Requirements

- **TLS everywhere**: all pages, not just login; HTTP port 80 only for redirect (HTTP 301)
- **No mixed content**: TLS pages must not load JS/CSS over HTTP
- **Secure cookie flag**: prevents cookies being sent over HTTP
- **Cache headers for sensitive data**: `Cache-Control: no-cache, no-store, must-revalidate`
- **HSTS header**: forces future requests over HTTPS, blocks certificate bypass

## Mutual TLS (mTLS)

Standard TLS only authenticates the server. mTLS adds client certificate authentication:

- Prevents MITM even if attacker has a trusted CA cert
- Suitable for high-value apps, internal APIs, service-to-service comms
- Challenges: cert lifecycle overhead, non-technical user friction

## Public Key Pinning

- HPKP (HTTP header-based pinning) deprecated and removed from browsers
- Still useful for mobile apps, thick clients, and server-to-server communication

## Testing Tools

Online: SSL Labs, CryptCheck, Hardenize, Observatory by Mozilla\
Offline: testssl.sh, SSLyze, SSLScan, O-Saft, CryptoLyzer

## Related Pages

- [TLS](../concepts/tls.md)
- [Certificate Management](../concepts/certificate-management.md)
- [HSTS](../concepts/hsts.md)
- [Perfect Forward Secrecy](../concepts/perfect-forward-secrecy.md)
- [HTTP Security Headers](../concepts/http-security-headers.md)
- [Database Security](../concepts/database-security.md)
