---
title: "OpenBao — Security Model"
tags: [openbao, security, threat-model, encryption, internals]
sources: [openbao-internals-security.md]
updated: 2026-07-03
---

# OpenBao — Security Model

The threat model and cryptographic protections of [OpenBao](../entities/openbao.md).

## Key Takeaways

- **Goals:** confidentiality, integrity, availability, accountability, authentication — data secure at rest and in transit, all access authenticated/authorized and auditable.
- **In the threat model:** eavesdropping on any OpenBao communication, tampering with data at rest/in transit, unauthenticated/unauthorized access, access without accountability, confidentiality of stored secrets, availability under failure.
- **Out of scope:** arbitrary control of the storage backend (attacker can delete/corrupt/rollback), leakage of the _existence_ of secrets, memory analysis of a running process, flaws in external systems/plugins/host, compromised clients, or a malicious operator supplying bad config.
- **Three systems, no mutual trust:** client ↔ server over **TLS** (client verifies server; every request needs a client token — tokenless clients may only log in). Server ↔ server (cluster) uses **mutually-authenticated TLS**; nodes authenticate via an unseal challenge before joining.
- **Barrier crypto:** all data leaving OpenBao is encrypted with **AES-256-GCM** with random 96-bit nonces; the GCM auth tag is verified on read to detect tampering. Storage backends are untrusted by design.
- **Internal (authorized-attacker) defense:** auth method → policy list → randomly-generated client token → per-request ACL. **Default deny**; merged policies grant the union, matched by most-specific/longest-prefix path. **root** policy + **sudo** capability for privileged paths.
- **Unseal:** Shamir's Secret Sharing splits the root key (default 5 shares, threshold 3) so no single holder can decrypt — a two-person-rule "bank vault" analogy.

## Related

- [Seal / Unseal](../concepts/openbao-seal-unseal.md)
- [Policies](../concepts/openbao-policies.md)
- [Architecture](openbao-internals-architecture.md)
- [Key Management](../concepts/key-management.md)
