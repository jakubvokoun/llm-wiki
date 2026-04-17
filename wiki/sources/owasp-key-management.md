---
title: "OWASP Key Management Cheat Sheet"
tags: [owasp, cryptography, key-management, security]
sources: [owasp-key-management.md]
updated: 2026-04-16
---

# OWASP Key Management Cheat Sheet

## Summary

Comprehensive guidance on cryptographic key management: algorithm selection, key lifecycle (generation → distribution → storage → escrow → audit → compromise recovery), trust stores, and FIPS 140-2/140-3 compliance requirements.

## Key Takeaways

### Algorithm Selection

- Identify security objectives first (confidentiality at rest, in transit, authenticity, integrity, key wrapping).
- Three classes: hash functions, symmetric-key, asymmetric-key algorithms.
- NSA CNSA 2.0 lists algorithms expected to withstand quantum computing advances.
- Use a single key for a single purpose only.

### Key Strength

- Consult `NIST SP 800-57` and `NIST SP 800-131a` for key length guidance per algorithm.
- Encrypt a key with another key of equal or greater strength.
- For Elliptic Curve, choose key length matching comparative strength of other algorithms in use.

### Memory Management

- Keys stored in memory too long can become "burned in" — split and rotate components frequently.
- Plan for memory media corruption and recovery.

### Perfect Forward Secrecy

- Use ephemeral keys so that compromise of long-term signing key doesn't expose past sessions.

### Key Lifecycle (NIST SP 800-57)

1. **Generation** — within FIPS 140-2/140-3 compliant cryptographic module; hardware preferred over software.
2. **Distribution** — secure channels, FIPS-compliant modules.
3. **Storage** — never plaintext; use HSM or cryptographic vault; application code should never touch raw key material.
4. **Escrow/Backup** — required for encryption keys; never escrow signing keys; encrypted with FIPS-compliant module.
5. **Accountability/Audit** — record who can view keys, when, what data they protect; audit periodically.
6. **Compromise Recovery** — documented plan with contacts, re-key method, key inventory, revocation policy.

### Trust Stores

- Protect against injection of third-party root certificates.
- Implement integrity controls and strict export policies.
- Secure the update process.

### Libraries

- Use only well-maintained, NIST/FIPS-validated crypto libraries.

## Related Pages

- [Key Management](../concepts/key-management.md)
- [Perfect Forward Secrecy](../concepts/perfect-forward-secrecy.md)
- [Secrets Management](../concepts/secrets-management.md)
- [OWASP](../entities/owasp.md)
