# Authentication Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html

## Introduction

**Authentication** (**AuthN**) is the process of verifying that an individual, entity, or website is who or what it claims to be by determining the validity of one or more authenticators (like passwords, fingerprints, or security tokens) that are used to back up this claim.

**Digital Identity** is the unique representation of a subject engaged in an online transaction. A digital identity is always unique in the context of a digital service but does not necessarily need to be traceable back to a specific real-life subject.

**Identity Proofing** establishes that a subject is actually who they claim to be. This concept is related to KYC concepts and it aims to bind a digital identity with a real person.

**Session Management** is a process by which a server maintains the state of an entity interacting with it. This is required for a server to remember how to react to subsequent requests throughout a transaction. Sessions are maintained on the server by a session identifier which can be passed back and forth between the client and server when transmitting and receiving requests. Sessions should be unique per user and computationally very difficult to predict.

## Authentication General Guidelines

### User IDs

The primary function of a User ID is to uniquely identify a user within a system. Ideally, User IDs should be randomly generated to prevent the creation of predictable or sequential IDs, which could pose a security risk, especially in systems where User IDs might be exposed or inferred from external sources.

### Usernames

Usernames are easy-to-remember identifiers chosen by the user and used for identifying themselves when logging into a system or service.

Users should be permitted to use their email address as a username, provided the email is verified during sign-up. Additionally, they should have the option to choose a username other than an email address.

### Authentication Solution and Sensitive Accounts

* Do **NOT** allow login with sensitive accounts (i.e. accounts that can be used internally within the solution such as to a backend / middleware / database) to any front-end user interface
* Do **NOT** use the same authentication solution (e.g. IDP / AD) used internally for unsecured access (e.g., public access / DMZ)

### Implement Proper Password Strength Controls

A key concern when using passwords for authentication is password strength. A "strong" password policy makes it difficult or even improbable for one to guess the password through either manual or automated means. The following characteristics define a strong password:

* Password Length
  + **Minimum** length for passwords should be enforced by the application.
    - If MFA is enabled passwords **shorter than 8 characters** are considered to be weak (NIST SP800-63B).
    - If MFA is not enabled passwords **shorter than 15 characters** are considered to be weak (NIST SP800-63B).
  + **Maximum** password length should be **at least 64 characters** to allow passphrases (NIST SP800-63B).
* Do not silently truncate passwords.
* Allow usage of **all** characters including unicode and whitespace. There should be no password composition rules limiting the type of characters permitted.
* Ensure credential rotation when a password leak occurs, at the time of compromise identification or when authenticator technology changes. Avoid requiring periodic password changes.
* Include a password strength meter to help users create a more complex password (e.g., zxcvbn-ts library).
* Block common and previously breached passwords (e.g., Pwned Passwords service).

### Implement Secure Password Recovery Mechanism

See the Forgot Password Cheat Sheet for details.

### Store Passwords in a Secure Fashion

See the Password Storage Cheat Sheet for details.

### Compare Password Hashes Using Safe Functions

Where possible, the user-supplied password should be compared to the stored password hash using a secure password comparison function. Ensure the comparison function:

* Has a maximum input length, to protect against denial of service attacks with very long inputs.
* Explicitly sets the type of both variables, to protect against type confusion attacks.
* Returns in constant time, to protect against timing attacks.

### Change Password Feature

When developing a change password feature, ensure:

* The user is authenticated with an active session.
* Current password verification is required.

### Transmit Passwords Only Over TLS or Other Strong Transport

The login page and all subsequent authenticated pages must be exclusively accessed over TLS or other strong transport.

### Require Re-authentication for Sensitive Features

In order to mitigate CSRF and session hijacking, it's important to require the current credentials for an account before updating sensitive account information such as the user's password or email address -- or before sensitive transactions.

### Reauthentication After Risk Events

Reauthentication is critical when an account has experienced high-risk activity such as account recovery, password resets, or suspicious behavior patterns.

#### When to Trigger Reauthentication

* **Suspicious Account Activity** — When unusual login patterns, IP address changes, or device enrollments occur
* **Account Recovery** — After users reset their passwords or change sensitive account details
* **Critical Actions** — For high-risk actions like changing payment details or adding new trusted devices

#### Reauthentication Mechanisms

* **Adaptive Authentication** — Use risk-based authentication models that adapt to the user's behavior and context
* **Multi-Factor Authentication (MFA)** — Require an additional layer of verification for sensitive actions or events
* **Challenge-Based Verification** — Prompt users to confirm their identity with a challenge question or secondary method

### TLS Client Authentication

TLS Client Authentication, also known as two-way TLS authentication, consists of both browser and server sending their respective TLS certificates during the TLS handshake process. This approach is appropriate when:

* It is acceptable that the user has access to the website only from a single computer/browser.
* The website requires an extra step of security.
* It is also a good thing to use when the website is for an intranet.

### Authentication and Error Messages

Incorrectly implemented error messages in the case of authentication functionality can be used for the purposes of user ID and password enumeration. An application should respond (both HTTP and HTML) in a generic manner.

Using any of the authentication mechanisms (login, password reset, or password recovery), an application must respond with a generic error message regardless of whether:
* The user ID or password was incorrect.
* The account does not exist.
* The account is locked or disabled.

#### Correct response examples

* Login: "Login failed; Invalid user ID or password."
* Password recovery: "If that email address is in our database, we will send you an email to reset your password."
* Account creation: "A link to activate your account has been emailed to the address provided."

### Protect Against Automated Attacks

| Attack Type | Description |
| --- | --- |
| Brute Force | Testing multiple passwords from a dictionary or other source against a single account. |
| Credential Stuffing | Testing username/password pairs obtained from the breach of another site. |
| Password Spraying | Testing a single weak password against a large number of different accounts. |

#### Multi-Factor Authentication

Multi-factor authentication (MFA) is by far the best defense against the majority of password-related attacks, including brute-force attacks (Microsoft analysis: stops 99.9% of account compromises).

#### Login Throttling / Account Lockout

The most common protection against these attacks is to implement account lockout, which prevents any more login attempts for a period after a certain number of failed logins.

The counter of failed logins should be associated with the account itself, rather than the source IP address. Consider:
* The number of failed attempts before the account is locked out (lockout threshold).
* The time period that these attempts must occur within (observation window).
* How long the account is locked out for (lockout duration).

Some applications use exponential lockout, where the lockout duration starts as a very short period but doubles after each failed login attempt.

#### CAPTCHA

CAPTCHA should be viewed as a defense-in-depth control to make brute-force attacks more time-consuming and expensive, rather than as a preventative. Consider requiring it only after a small number of failed login attempts.

## Logging and Monitoring

Enable logging and monitoring of authentication functions to detect attacks/failures on a real-time basis:
* Ensure that all failures are logged and reviewed
* Ensure that all password failures are logged and reviewed
* Ensure that all account lockouts are logged and reviewed

## Use of Authentication Protocols That Require No Password

### OAuth 2.0 and 2.1

OAuth is an **authorization** framework for delegated access to APIs. OAuth 2.1 is an IETF Working Group draft that consolidates OAuth 2.0 and widely adopted best practices.

### OpenID Connect (OIDC)

**OpenID Connect 1.0 (OIDC)** is an identity layer **on top of OAuth**. It defines how a client (relying party) verifies the end user's identity using an ID Token (a signed JWT) and how to obtain user claims in an interoperable way. Use **OIDC for authentication/SSO**; use **OAuth for authorization** to APIs.

OIDC implementation guidance:
* **Validate ID Tokens** on the relying party: issuer (`iss`), audience (`aud`), signature (per provider JWKs), expiration (`exp`).
* Prefer **well-maintained libraries/SDKs** and provider discovery/JWKS endpoints.
* Use the **UserInfo** endpoint when additional claims beyond the ID Token are required.

### SAML

Security Assertion Markup Language (SAML) is often considered to compete with OpenId. The most recommended version is 2.0. Unlike OpenId, it is XML-based and provides more flexibility. SAML is often the choice for enterprise applications and intranet websites.

### FIDO

The Fast Identity Online (FIDO) Alliance has created protocols to facilitate online authentication:
* **UAF (Universal Authentication Framework)** — passwordless authentication using device biometrics
* **U2F (Universal Second Factor)** — adds a hardware token second factor
* **FIDO2/WebAuthn/Passkeys** — modern standard enabling biometric + cloud-synced credentials, widely supported (Windows Hello, Mac Touch ID)

## Password Managers

Web applications should not make the job of password managers more difficult:
* Use standard HTML forms for username and password input with appropriate `type` attributes.
* Avoid plugin-based login pages.
* Implement a reasonable maximum password length (at least 64 characters).
* Allow any printable characters in passwords.
* Allow users to paste into the username, password, and MFA fields.

## Changing A User's Registered Email Address

Recommended process (with MFA):
1. Confirm the validity of the user's authentication cookie/token.
2. Ask the user to submit a proposed new email address.
3. Request MFA for identity verification.
4. Store the proposed new email address as a pending change.
5. Create time-limited nonces and send notification email to current address and confirmation email to new address.

## Adaptive or Risk Based Authentication

More advanced applications can require different authentication stages depending on environmental and contextual attributes (sensitivity of data, time of day, user location, IP address, device fingerprint). Examples:
* Require MFA for first login from a particular device but not subsequent logins.
* Allow low risk access with device fingerprint, require MFA for sensitive operations.
