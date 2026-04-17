---
title: "Transport Layer Security (TLS)"
tags: [tls, ssl, cryptography, https, certificates, mTLS]
sources: [owasp-tls-security.md]
updated: 2026-04-16
---

# Transport Layer Security (TLS)

TLS is the standard cryptographic protocol for securing network communication, most commonly used for HTTPS. It superseded SSL (v2 and v3 both deprecated with serious weaknesses).

## Guarantees

| Property        | Description                                                |
| --------------- | ---------------------------------------------------------- |
| Confidentiality | Prevents eavesdropping                                     |
| Integrity       | Prevents tampering and replay                              |
| Authentication  | Verifies server identity (and optionally client with mTLS) |

## Version History

| Version      | Status                               |
| ------------ | ------------------------------------ |
| SSL 2.0, 3.0 | Deprecated — serious weaknesses      |
| TLS 1.0, 1.1 | Deprecated — PCI DSS forbids TLS 1.0 |
| TLS 1.2      | Acceptable, legacy support           |
| TLS 1.3      | Current standard — prefer this       |

## Key Concepts

### Cipher Suites

TLS 1.3 reduces the cipher suite list significantly. For TLS 1.2, prefer GCM-based ciphers. Always disable: null ciphers, anonymous ciphers, EXPORT ciphers.

### Diffie-Hellman Key Exchange

TLS 1.3 restricts DH to named groups (`x25519`, `prime256v1`, `ffdhe2048–8192` per RFC 7919). This eliminates the client-has-no-say problem of earlier DHE and prevents CVE-2022-40735 / CVE-2002-20001 (DHEat DoS).

### Certificate Chain

Server presents a certificate signed by a CA. Browser/OS verifies chain up to a trusted root CA. See [Certificate Management](certificate-management.md).

## Mutual TLS (mTLS)

Standard TLS only authenticates the server. mTLS requires both sides to present certificates:

- **Use cases**: service-to-service APIs, internal microservices, high-assurance clients
- **Protection**: prevents MITM even when attacker holds a trusted CA cert (as in corporate TLS inspection)
- **Challenge**: certificate lifecycle management; breaks TLS inspection in corporate proxies
- Often implemented via [Service Mesh](service-mesh.md) (Istio, Linkerd) for automatic mTLS between pods

## Public Key Pinning

Pins expected public key in addition to standard chain validation. HPKP (browser header) is deprecated. Still applicable for mobile apps, thick clients, server-to-server.

## Application-Level Requirements

- Enforce TLS on **all** endpoints (not just login pages)
- Redirect HTTP → HTTPS (301), then enforce with [HSTS](hsts.md)
- Set `Secure` flag on all cookies
- No mixed content (HTTPS page must not load HTTP resources)
- Cache-Control headers to prevent sensitive data caching beyond TLS session

## Related Concepts

- [Certificate Management](certificate-management.md)
- [HSTS](hsts.md)
- [Perfect Forward Secrecy](perfect-forward-secrecy.md)
- [HTTP Security Headers](http-security-headers.md)
- [Service Mesh](service-mesh.md) — automatic mTLS between microservices
- [Database Security](database-security.md) — TLS for DB connections
