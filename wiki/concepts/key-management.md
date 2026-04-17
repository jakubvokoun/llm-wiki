---
title: "Key Management"
tags: [cryptography, key-management, security, nist, fips, hsm]
sources: [owasp-key-management.md]
updated: 2026-04-16
---

# Key Management

The full lifecycle management of cryptographic keys: generation, distribution, storage, escrow, accountability, and compromise recovery.

## Key Types

| Type                         | Purpose                                    |
| ---------------------------- | ------------------------------------------ |
| Symmetric encryption key     | Encrypt/decrypt data at rest or in transit |
| Asymmetric key pair          | Digital signatures, key establishment      |
| HMAC key                     | Data origin authentication                 |
| MAC key                      | Integrity protection                       |
| Key Encryption Key (KEK)     | Encrypt other keys for storage/transport   |
| Trust anchors / certificates | Device authentication, CA chains           |

## Lifecycle Phases (NIST SP 800-57)

### Generation

- Must occur within a FIPS 140-2 or 140-3 compliant cryptographic module.
- Random values must be generated within the same module.
- Hardware modules preferred over software.

### Distribution

- Transport only via secure channels.
- Receiving module must also be FIPS 140-2/140-3 compliant.

### Storage

- Never store in plaintext.
- Use HSM (Hardware Security Module) or isolated cryptographic vault.
- Application-level code must never read raw key material — all operations occur inside the vault.
- Apply integrity protections (MAC or digital signature on stored keys).
- Encrypt keys for offline storage with a KEK of equal or greater strength.

### Escrow and Backup

- Essential for encryption keys — lost key = lost data.
- Encrypt backup database with FIPS-validated module.
- **Never** escrow signing keys (non-repudiation would be broken).

### Accountability and Audit

- Log who can view plaintext keys, when, and what data they protect.
- Periodic audits of the security plan, procedures, and protective mechanisms.
- Uniquely identify keys; track associations with users, data, and other keys.

### Key Compromise and Recovery

- Compromised confidentiality key → all data encrypted with it may be exposed.
- Compromised integrity key → all authenticated data is suspect.
- Compromised CA signing key → fraudulent certificates and CRLs can be issued.

**Compromise-recovery plan must include:**

- Contact list for notification and recovery personnel.
- Re-key procedure.
- Key inventory (all keys + their uses + certificate locations).
- Revocation enforcement policy.
- Monitoring of re-keying operations.

## Key Usage Principle

Use each key for exactly one purpose. Reasons:

1. Multi-purpose keys weaken both usages.
2. Limiting scope limits blast radius of compromise.
3. Different uses have different retention and rotation requirements.

## Key Strength

- Consult `NIST SP 800-57 Table 2` for algorithm-to-algorithm strength equivalence.
- Always encrypt a key with another key of equal or greater strength.
- For Elliptic Curve: length must meet or exceed comparable symmetric key strength.

## Memory Management

- Keys in memory long-term can become "burned in" — split into frequently-rotated components.
- Plan for recovery from memory media corruption.

## Trust Stores

- Guard against injection of unauthorized root certificates.
- Integrity-protect all stored objects.
- Require authentication and authorization for key export.
- Implement a secure trust store update process.

## Perfect Forward Secrecy

Use [ephemeral keys](perfect-forward-secrecy.md) so that compromise of long-term signing key doesn't retroactively expose past sessions.

## Tools

- **HSM** (Hardware Security Module) — gold standard for key protection.
- **AWS KMS, Azure Key Vault, HashiCorp Vault** — managed cryptographic vaults.
- FIPS-validated software libraries for environments where HSM is unavailable.

## Related Pages

- [Perfect Forward Secrecy](perfect-forward-secrecy.md)
- [Secrets Management](secrets-management.md)
- [OWASP Key Management Cheat Sheet](../sources/owasp-key-management.md)
