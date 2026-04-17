---
title: "OWASP Authentication Cheat Sheet"
tags: [owasp, authentication, security, passwords, mfa, oauth, oidc, saml, fido]
sources: [owasp-authentication.md]
updated: 2026-04-16
---

# OWASP Authentication Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html

## Key Takeaways

**Authentication** (AuthN) is the process of verifying an individual, entity, or website is who it claims to be. It is distinct from **authorization** (what they can do) and from **identity proofing** (binding a digital identity to a real person).

## Core Guidelines

### User IDs and Usernames

- User IDs should be randomly generated to prevent predictable/sequential IDs
- Allow email address as a username (if verified at sign-up)
- Do not allow login with sensitive/internal accounts on front-end interfaces
- Do not reuse the same authentication solution for internal and public access

### Password Strength Controls (NIST SP800-63B)

- **Minimum length**: 8 chars with MFA; 15 chars without MFA
- **Maximum length**: at least 64 chars (to allow passphrases)
- No silent truncation; no character composition rules
- Allow all characters including unicode and whitespace
- Avoid mandatory periodic rotation; encourage strong passwords + MFA instead
- Use password strength meters (e.g., zxcvbn)
- Block common and breached passwords (e.g., Have I Been Pwned API)

### Secure Password Operations

- Use constant-time comparison functions to prevent timing attacks
- Require current password verification before changing password
- All login pages and authenticated pages must use TLS

### Re-authentication

- Require re-auth before sensitive operations (email/password change, financial transactions)
- Trigger re-auth after: suspicious activity, account recovery, critical actions
- Use MFA, adaptive authentication, or challenge-based verification

### Error Messages

- Always return generic error messages (prevent user enumeration)
  - Login: "Login failed; Invalid user ID or password."
  - Password recovery: "If that email address is in our database, we will send you an email to reset your password."
  - Account creation: "A link to activate your account has been emailed to the address provided."
- Use constant-time responses to prevent timing-based enumeration

### Protection Against Automated Attacks

| Attack Type         | Description                                         |
| ------------------- | --------------------------------------------------- |
| Brute Force         | Testing multiple passwords against a single account |
| Credential Stuffing | Using credentials breached from another site        |
| Password Spraying   | Testing one weak password across many accounts      |

Defenses:

- **MFA**: stops 99.9% of account compromises (Microsoft analysis)
- **Account lockout**: associate counter with account, not IP; use exponential backoff
- **CAPTCHA**: defense-in-depth, not preventative; apply after N failed attempts
- Credential stuffing: see Credential Stuffing Prevention Cheat Sheet

## Passwordless Authentication Protocols

### OAuth 2.0 / 2.1

Authorization framework for delegated access to APIs. OAuth 2.1 consolidates 2.0 + best practices.

### OpenID Connect (OIDC)

Identity layer on top of OAuth. Use OIDC for authentication/SSO; OAuth for API authorization.

- Validate ID tokens: `iss`, `aud`, signature (JWKs), `exp`
- Use well-maintained libraries and provider discovery endpoints

### SAML 2.0

XML-based, enterprise-preferred for intranet/federation. Preferred for enterprise SSO (SAP, SharePoint + ADFS).

### FIDO / Passkeys

- **UAF**: passwordless using device biometrics
- **U2F**: hardware token second factor; protects against phishing via URL-based key lookup
- **FIDO2/WebAuthn/Passkeys**: modern standard; biometric + cloud sync (Windows Hello, Touch ID)

## Adaptive / Risk-Based Authentication

Require different authentication levels based on: data sensitivity, time of day, user location, IP address, device fingerprint. Example: MFA for first login from new device, step-up for financial operations.

## Related Pages

- [Authentication](../concepts/authentication.md)
- [Password Security](../concepts/password-security.md)
- [Multi-Factor Authentication](../concepts/mfa.md)
- [Adaptive Authentication](../concepts/adaptive-authentication.md)
- [OWASP](../entities/owasp.md)
