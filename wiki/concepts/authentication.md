---
title: "Authentication"
tags:
  [authentication, security, identity, passwords, mfa, oauth, oidc, saml, fido]
sources: [owasp-authentication.md]
updated: 2026-04-16
---

# Authentication

Authentication (AuthN) is the process of verifying that an individual, entity, or website is who or what it claims to be. It is distinct from:

- **Authorization** (AuthZ) — what an authenticated identity is permitted to do
- **Identity Proofing** — binding a digital identity to a real-world person (KYC)

## Core Concepts

**User ID vs Username:** User IDs should be randomly generated (not sequential). Usernames are human-chosen aliases. Either can serve as login identifier; email-as-username requires verified email.

**Session Management:** After authentication, the server maintains state via a session identifier. Sessions must be unique, computationally hard to predict, and transmitted only over TLS.

## Authentication Factors

Authentication factors fall into three categories:

- **Something you know**: password, PIN, security question
- **Something you have**: hardware token (U2F/FIDO), TOTP authenticator app, SMS code
- **Something you are**: fingerprint, face, voice (biometrics)

Multi-Factor Authentication (MFA) combines two or more distinct factors.

## Password-Based Authentication

**Strength requirements (NIST SP800-63B):**

- Minimum 8 chars with MFA; 15 chars without MFA
- Maximum at least 64 chars (to allow passphrases)
- No composition rules (no forced uppercase/lowercase/special chars)
- Block known-breached passwords (Have I Been Pwned)
- No periodic rotation — rotate on breach only

**Password operations:**

- Store with adaptive hashing (bcrypt, scrypt, Argon2) — see Password Storage
- Compare with constant-time functions (prevent timing attacks)
- Require current password to change password (prevent session hijacking abuse)
- Never silently truncate passwords

## Error Message Security

Return generic error messages for all authentication failures to prevent user enumeration:

- ✅ "Login failed; Invalid user ID or password."
- ✅ "If that email address is in our database, we will send you an email to reset your password."
- ❌ "Login for User foo: invalid password." (reveals valid username)

Use constant-time processing paths to prevent timing-based enumeration.

## Automated Attack Protection

| Attack              | Defense                                                              |
| ------------------- | -------------------------------------------------------------------- |
| Brute Force         | Account lockout (exponential backoff), CAPTCHA after N failures, MFA |
| Credential Stuffing | MFA, breached password checks, behavioral anomaly detection          |
| Password Spraying   | MFA, lockout per account (not IP)                                    |

MFA stops ~99.9% of account compromise attacks (Microsoft).

**Account lockout:** Associate counter with the account, not the source IP. Exponential backoff preferred over fixed lockout durations.

## Passwordless / Federated Protocols

| Protocol                | Use Case                                                                              |
| ----------------------- | ------------------------------------------------------------------------------------- |
| OAuth 2.0/2.1           | Authorization delegation to APIs                                                      |
| OIDC                    | Authentication/SSO (identity layer on OAuth); validate `iss`, `aud`, signature, `exp` |
| SAML 2.0                | Enterprise SSO/federation; XML-based; preferred for intranet/enterprise               |
| FIDO2/WebAuthn/Passkeys | Passwordless biometric; cloud-synced; phishing-resistant                              |

## Re-authentication

Require re-authentication before:

- Changing password or email
- Sensitive financial transactions
- Adding new devices or trusted methods

Also trigger after: suspicious login patterns, IP changes, account recovery.

Mechanisms: MFA, adaptive/risk-based challenges, session invalidation + token rotation.

## Adaptive / Risk-Based Authentication

Adjust authentication strength based on context:

- First login from new device → require MFA
- Unusual geolocation or IP → step-up challenge
- Low-risk operation (read-only) → session token sufficient
- High-risk operation (payment) → MFA required

## Related Pages

- [Password Security](password-security.md)
- [Multi-Factor Authentication](mfa.md)
- [Adaptive Authentication](adaptive-authentication.md)
- [Authorization](authorization.md)
- [Zero Trust Architecture](zero-trust.md)
- [OWASP Authentication Cheat Sheet](../sources/owasp-authentication.md)
