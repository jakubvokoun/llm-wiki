---
title: "Perfect Forward Secrecy"
tags: [cryptography, tls, key-management, security]
sources: [owasp-key-management.md]
updated: 2026-04-16
---

# Perfect Forward Secrecy (PFS)

A property of a cryptographic protocol ensuring that compromise of long-term keys does not retroactively compromise past session keys.

## How It Works

PFS is achieved by using **ephemeral keys** — session keys generated fresh for each connection that are not derived from or stored with the long-term private key.

Without PFS:

- Attacker records encrypted traffic.
- Later compromises the server's long-term private key.
- Retroactively decrypts all recorded sessions.

With PFS (ephemeral keys):

- Each session uses a unique key generated via ephemeral Diffie-Hellman (DHE) or Elliptic Curve Diffie-Hellman (ECDHE).
- Session key is discarded after the session ends.
- Compromise of long-term key only exposes identity/authentication, not past session content.

## TLS Implementation

In TLS, PFS is provided by cipher suites using:

- **ECDHE** (Elliptic Curve Diffie-Hellman Ephemeral) — preferred; faster and stronger per bit.
- **DHE** (Diffie-Hellman Ephemeral) — older, computationally heavier.

Cipher suites with PFS: `ECDHE-RSA-AES256-GCM-SHA384`, `ECDHE-ECDSA-CHACHA20-POLY1305`, etc.

Cipher suites without PFS: those using `RSA` key exchange directly (e.g., `TLS_RSA_WITH_AES_128_CBC_SHA`).

## Why It Matters

- Protects against "harvest now, decrypt later" (HNDL) attacks.
- Critical for communications that need to remain confidential long after the session ends.
- Increasingly important in the context of quantum computing threats.

## Related Pages

- [Key Management](key-management.md)
- [HSTS](hsts.md)
- [HTTP Security Headers](http-security-headers.md)
