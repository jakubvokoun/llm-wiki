---
title: "Certificate Management"
tags: [certificates, tls, pki, ca, x509, caa]
sources: [owasp-tls-security.md]
updated: 2026-04-16
---

# Certificate Management

X.509 certificates bind a public key to an identity (domain/org), signed by a Certificate Authority (CA). Correct certificate management is a prerequisite for trustworthy TLS.

## Certificate Types by Validation Level

| Type                        | Validation                        | Browser Display                  | Security Value                |
| --------------------------- | --------------------------------- | -------------------------------- | ----------------------------- |
| DV (Domain Validated)       | Proof of domain control only      | No org info                      | Baseline; sufficient for most |
| OV (Organization Validated) | Official org contact verification | Org in cert subject              | Minimal extra security        |
| EV (Extended Validation)    | Highest human verification        | No visual distinction since 2019 | No additional crypto security |

All three are cryptographically equivalent — an attacker only needs domain control to issue a rogue DV cert. EV/OV do not raise the security bar.

## Key and Hash Requirements

- **Key size**: ≥2048-bit RSA or equivalent EC (NIST SP 800-57)
- **Hash algorithm**: SHA-256; avoid MD5 and SHA-1 (cryptographic weaknesses, untrusted by modern browsers)
- **SAN (subjectAlternativeName)**: FQDN must appear here; Chrome ignores commonName (CN)

## Wildcard Certificates

`*.example.org` is valid for all subdomains. Risks:

- Single private key across many systems — broader compromise impact
- Never share wildcard between systems at different trust levels (e.g. VPN gateway and public web server)
- If used: restrict to a subdomain (`*.internal.example.org`), use a reverse proxy to centralize the key

## CAA DNS Records

Certification Authority Authorization (CAA) records specify which CAs may issue certificates for your domain:

```
example.org. CAA 0 issue "letsencrypt.org"
```

CAs that are not listed should refuse to issue. Helps prevent unauthorized issuance through less-reputable CAs.

## Certificate Authorities

- **Public CAs**: required for internet-facing apps; browsers trust automatically
- **LetsEncrypt**: free DV certificates; automate via ACME protocol
- **Internal CA**: for internal apps; FQDN not exposed externally; clients must trust the internal root

## ACME Automation

ACME protocol (used by LetsEncrypt) automates certificate issuance and renewal. Reduces wildcard cert temptation and eliminates manual rotation errors.

## Related Concepts

- [TLS](tls.md) — how certificates are used in the protocol
- [Key Management](key-management.md) — private key storage and lifecycle
- [HSTS](hsts.md) — prevents downgrade after cert is established
