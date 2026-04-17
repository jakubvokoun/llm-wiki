---
title: "OWASP Security Terminology Cheat Sheet"
tags:
  [
    owasp,
    security,
    terminology,
    glossary,
    encoding,
    cryptography,
    authentication,
    authorization,
  ]
sources: [owasp-security-terminology.md]
updated: 2026-04-16
---

# OWASP Security Terminology Cheat Sheet

Source: `raw/owasp-security-terminology.md`

## Key Takeaways

Precise definitions for commonly confused security terms — critical for correct implementation.

## Data Handling Terms

| Term              | Definition                                                              | Purpose                               | Reversible? |
| ----------------- | ----------------------------------------------------------------------- | ------------------------------------- | ----------- |
| **Encoding**      | Transform data into different format using public scheme                | Compatibility/usability, NOT security | Yes         |
| **Escaping**      | Prefix special chars with signal character to prevent misinterpretation | Prevent injection (XSS, SQLi)         | Yes         |
| **Sanitization**  | Remove/replace dangerous characters or content                          | Clean "dirty" input to policy         | Lossy       |
| **Serialization** | Convert object to storable/transmittable format                         | Persistence and communication         | Yes         |

Key: encoding ≠ security control. Escaping is a sub-type of encoding.

Insecure Deserialization: untrusted data used to reconstruct objects → RCE (Remote Code Execution).

## Cryptographic Terms

| Term                   | Purpose                                                     | Reversible?    | Examples                |
| ---------------------- | ----------------------------------------------------------- | -------------- | ----------------------- |
| **Encryption**         | Confidentiality — only key holders can read                 | Yes (with key) | AES, RSA                |
| **Hashing**            | Integrity — small change = different hash                   | No (one-way)   | SHA-256, Argon2, bcrypt |
| **Digital Signatures** | Authenticity + non-repudiation — prove origin and integrity | No             | JWT sig, GPG            |

Signing mechanism: sender signs hash with _private key_; receiver verifies with _public key_.

## Identity Terms

- **Authentication (AuthN):** "Who are you?" — verify identity
- **Authorization (AuthZ):** "Are you allowed?" — verify permissions; occurs _after_ AuthN

## Federated Identity Terms

| Term                        | Definition                                         | Example                            |
| --------------------------- | -------------------------------------------------- | ---------------------------------- |
| **Identity Provider (IdP)** | Creates/manages identity, provides AuthN services  | Google, Okta, Azure AD             |
| **Relying Party (RP)**      | App that relies on IdP for user AuthN              | Your app using "Login with Google" |
| **Service Provider (SP)**   | SAML equivalent of RP                              | Enterprise app using SAML          |
| **Principal**               | Entity being authenticated (user, service, device) | The logged-in user                 |

## Related Pages

- [Encoding and Escaping](../concepts/encoding-and-escaping.md)
- [Cryptographic Primitives](../concepts/cryptographic-primitives.md)
- [Federated Identity](../concepts/federated-identity.md)
- [Authentication](../concepts/authentication.md)
- [Authorization](../concepts/authorization.md)
- [Input Validation](../concepts/input-validation.md)
