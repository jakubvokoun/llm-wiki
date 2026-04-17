---
title: "Adaptive Authentication"
tags:
  [adaptive-authentication, risk-based-authentication, security, mfa, context]
sources: [owasp-authentication.md]
updated: 2026-04-16
---

# Adaptive Authentication

Adaptive authentication (also called risk-based authentication) adjusts the required authentication strength dynamically based on contextual signals and risk assessment, rather than always requiring the same factors.

## Core Concept

Instead of applying uniform authentication requirements to all requests, the system evaluates risk at login time (and potentially mid-session) and escalates authentication requirements only when risk warrants it:

- Low risk → session token sufficient
- Medium risk → TOTP challenge
- High risk → hardware token / biometric MFA
- Suspicious → block + notify

## Risk Signals

Common signals used to assess authentication risk:

| Signal Category       | Examples                                                  |
| --------------------- | --------------------------------------------------------- |
| Geolocation           | Unusual country, impossible travel                        |
| IP address            | Known bad actor IPs, TOR exit nodes, data center IPs      |
| Device fingerprint    | New device, unknown browser/OS                            |
| Time of day           | Access outside normal hours                               |
| Behavioral biometrics | Typing rhythm, mouse patterns                             |
| Access pattern        | Unusual volume of requests, privilege escalation attempts |
| Account history       | Recent password reset, failed MFA attempts                |

## Common Patterns

**New device detection:** Require MFA for first login from a new device; skip on recognized devices. Devices tracked via persistent cookie + browser fingerprint.

**Step-up authentication:** Allow low-risk operations (read balance) with session token; require MFA for sensitive operations (send payment, change settings).

**Continuous risk assessment:** Re-evaluate risk signals mid-session; trigger re-authentication if risk score changes significantly.

**Anomaly-based blocking:** Block or require verification for logins that look like credential stuffing or account takeover.

## Implementation Considerations

- **Risk scoring model**: rule-based, ML-based, or hybrid; must have clear thresholds → actions mapping
- **Action options**: allow, CAPTCHA, step-up MFA, block, revoke session
- **Minimize friction**: re-authentication should not disrupt normal user experience
- **Token management**: invalidate and rotate tokens after step-up authentication
- **Cross-device/tab consistency**: synchronize risk state across concurrent sessions
- **Monitoring**: alert on suspicious patterns; notify users of unusual access
- **Regulatory alignment**: ensure risk policies align with corporate and compliance requirements (e.g., PCI DSS, SOC 2)

## Relation to Zero Trust

Adaptive authentication is a practical implementation of Zero Trust principles: rather than implicitly trusting an authenticated session indefinitely, continuous verification of identity and context is performed throughout the session.

## Related Pages

- [Authentication](authentication.md)
- [Multi-Factor Authentication](mfa.md)
- [Zero Trust Architecture](zero-trust.md)
- [OWASP Authentication Cheat Sheet](../sources/owasp-authentication.md)
