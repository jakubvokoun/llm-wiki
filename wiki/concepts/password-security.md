---
title: "Password Security"
tags: [passwords, security, authentication, hashing, nist, breached-passwords]
sources: [owasp-authentication.md]
updated: 2026-04-16
---

# Password Security

Password security covers the full lifecycle of passwords: strength requirements, secure storage, safe comparison, recovery, and transmission.

## Strength Requirements (NIST SP800-63B)

- **Minimum length**: 8 chars with MFA; 15 chars without MFA
- **Maximum length**: at least 64 chars (to support passphrases)
- **No composition rules**: do not mandate uppercase, lowercase, numbers, or special characters
- **No periodic rotation**: rotate only on breach or suspected compromise
- **Allow all characters**: including unicode, whitespace, emojis
- **Block breached passwords**: check against Have I Been Pwned or similar corpus
- **Provide strength meter**: help users create stronger passwords (e.g., zxcvbn library)

Rationale: Composition rules cause users to follow predictable patterns (Password1!, Password2!). Length is the dominant factor in password strength.

## Secure Storage

Passwords must never be stored in plaintext or reversibly encrypted. Use adaptive one-way hashing:

**Recommended algorithms:**

- **Argon2id**: OWASP/NIST recommended winner of Password Hashing Competition
- **bcrypt**: well-established, widely supported
- **scrypt**: memory-hard, good second choice
- **PBKDF2**: acceptable, especially for FIPS compliance

Key parameters: work factor / cost parameter should be tuned so hashing takes ~100ms on current hardware. See OWASP Password Storage Cheat Sheet.

## Safe Comparison

Password comparison must be:

- **Constant-time**: prevents timing attacks (attacker infers correctness from response time)
- **Type-safe**: prevents type confusion attacks
- **Length-limited**: prevents DoS with very long inputs

Use framework-provided functions (e.g., `password_verify()` in PHP, `bcrypt.compare()` in Node).

## Transmission

- Passwords must only be transmitted over TLS
- The login form itself must be served over TLS (not just the form action)
- TLS failure allows form action manipulation → credentials exfiltrated to attacker

## Password Recovery

- Implement time-limited, single-use recovery tokens
- Send recovery link to verified email only
- Return generic message: "If that address is in our database, we will send a reset link."
- See OWASP Forgot Password Cheat Sheet

## Changing Password

- Verify current password before allowing change (prevents session-hijacking abuse)
- User must be in active authenticated session
- Send notification to current email on password change

## Breached Password Detection

- HIBP (Have I Been Pwned) Passwords API: k-anonymity model (send first 5 chars of SHA-1 hash)
- Self-hosted: downloadable HIBP corpus
- NCSC top 100k passwords list

## Long Password DoS

Certain hashing implementations (bcrypt with certain wrappers) can be exploited with very long passwords, causing excessive CPU usage. Mitigations:

- Enforce a reasonable maximum password length (64–128 chars)
- Or pre-hash with SHA-256 before bcrypt (though this has tradeoffs)

## Related Pages

- [Authentication](authentication.md)
- [Multi-Factor Authentication](mfa.md)
- [OWASP Authentication Cheat Sheet](../sources/owasp-authentication.md)
