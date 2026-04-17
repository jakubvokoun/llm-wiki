---
title: "Cryptographic Primitives"
tags:
  [
    cryptography,
    encryption,
    hashing,
    digital-signatures,
    confidentiality,
    integrity,
    authenticity,
  ]
sources: [owasp-security-terminology.md]
updated: 2026-04-16
---

# Cryptographic Primitives

## Three Core Primitives

### Encryption

- **Goal:** Confidentiality
- **Mechanism:** Transform plaintext → ciphertext using a secret key
- **Reversible:** Yes (with correct key)
- **Types:**
  - Symmetric: same key for encrypt/decrypt (AES)
  - Asymmetric: public key encrypts, private key decrypts (RSA)

### Hashing

- **Goal:** Integrity
- **Mechanism:** Transform data → fixed-size digest using a one-way function
- **Reversible:** No
- **Properties:** Small input change → completely different hash (avalanche effect)
- **Uses:** Password storage (with salt), file integrity verification, digital signatures
- **Algorithms:** SHA-256 (integrity), Argon2/bcrypt/scrypt (password storage — slow by design)

### Digital Signatures

- **Goal:** Authenticity + Non-repudiation
- **Mechanism:** Sign hash of message with _private key_; verify with _public key_
- **Provides:** Proof of origin (who sent it) + integrity (not tampered)
- **Examples:** JWT signatures, GPG, TLS certificate signatures, code signing

## Security Properties Triangle

| Property        | Primitive          | Question answered            |
| --------------- | ------------------ | ---------------------------- |
| Confidentiality | Encryption         | Can others read this?        |
| Integrity       | Hashing            | Was this tampered with?      |
| Authenticity    | Digital Signatures | Did this really come from X? |
| Non-repudiation | Digital Signatures | Can X deny sending this?     |

## Common Confusions

- **Encryption ≠ Hashing:** Encryption is reversible; hashing is not
- **Hashing ≠ Encryption:** Don't say "we encrypted the password" when you mean hashed
- **Encoding ≠ Encryption:** Base64 is NOT encryption; it provides no confidentiality

## Related Pages

- [Key Management](key-management.md)
- [Password Security](password-security.md)
- [Perfect Forward Secrecy](perfect-forward-secrecy.md)
- [OWASP Security Terminology](../sources/owasp-security-terminology.md)
