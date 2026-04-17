---
title: "Multi-Factor Authentication (MFA)"
tags: [mfa, authentication, security, totp, fido, passkeys, u2f]
sources: [owasp-authentication.md]
updated: 2026-04-16
---

# Multi-Factor Authentication (MFA)

Multi-Factor Authentication (MFA) requires users to present two or more verification factors from different categories to authenticate. It is the single most effective control against password-based attacks: Microsoft analysis found MFA stops ~99.9% of account compromises.

## Authentication Factor Categories

| Factor             | Type       | Examples                                                |
| ------------------ | ---------- | ------------------------------------------------------- |
| Something you know | Knowledge  | Password, PIN, security question                        |
| Something you have | Possession | TOTP app, SMS, hardware token (U2F/FIDO), recovery code |
| Something you are  | Inherence  | Fingerprint, face, voice, iris                          |

MFA requires at least 2 **different** factor categories. Two passwords is not MFA.

## Common MFA Methods

### TOTP (Time-based One-Time Password)

RFC 6238. Authenticator apps (Authy, Google Authenticator, 1Password) generate 6-digit codes that rotate every 30 seconds. Shared secret stored on device and server. Susceptible to phishing (codes can be relayed in real time).

### SMS / Email OTP

Single-use codes sent via SMS or email. Weaker than TOTP — susceptible to SIM swapping (SMS) and email account compromise. NIST deprecated SMS as a secondary factor (though still commonly used).

### U2F / FIDO2 Hardware Tokens

Physical devices (YubiKey, etc.) that perform a challenge-response using public key cryptography. Bound to the specific origin URL → phishing-resistant. FIDO2/WebAuthn extends this to platform authenticators.

### Passkeys (FIDO2/WebAuthn)

Combines FIDO2 with cloud synchronization. Device-based biometric (fingerprint/face) authenticates to a platform authenticator (Windows Hello, Touch ID) which holds the FIDO2 credential. Passkeys:

- Are phishing-resistant (bound to origin)
- Sync across devices via platform (iCloud Keychain, Google Password Manager)
- Replace both password and second factor in one step
- Widely supported by major platforms and browsers

### Push Notifications

App-based push (e.g., Microsoft Authenticator, Duo). User approves on phone. Susceptible to MFA fatigue attacks (attacker spams push notifications hoping user approves).

## When to Require MFA

- All logins from unrecognized devices
- Sensitive operations (payment, admin actions, account settings changes)
- After account recovery or password reset
- Triggered by risk signals (unusual IP, geolocation)

## Security Questions

Security questions are **not** a second factor — they are another knowledge factor. They are often weak (predictable answers) and considered insufficient for high-risk operations.

## Implementation Notes

- Allow paste into MFA fields (supports authenticator app workflows)
- Provide recovery codes for lost authenticator
- Implement lockout on MFA attempts (separate from password lockout)
- MFA token should be single-use

## Related Pages

- [Authentication](authentication.md)
- [Password Security](password-security.md)
- [Adaptive Authentication](adaptive-authentication.md)
- [OWASP Authentication Cheat Sheet](../sources/owasp-authentication.md)
