---
title: "OpenBao — Seal/Unseal (concept)"
tags: [openbao, seal, unseal, shamir, auto-unseal]
sources: [openbao-concept-seal.md]
updated: 2026-07-03
---

# OpenBao — Seal/Unseal (concept)

Source summary for [OpenBao](../entities/openbao.md)'s seal/unseal concept. Full synthesis: [Seal / Unseal](../concepts/openbao-seal-unseal.md).

## Key Takeaways

- Encryption key (keyring) ← root key ← unseal key. A started server is **sealed** and can do nothing but unseal until the root key is reconstructed.
- **Shamir seal** (default): unseal key split into shares (default 5, threshold 3); `bao operator unseal` adds shares statefully; each node unseals independently.
- **Auto-unseal:** a KMS/HSM/Transit engine decrypts the root key at startup; initialization yields **recovery keys** (authorize quorum ops, can't unseal). **Permanent loss of the seal key = unrecoverable cluster.**
- Sealing discards the in-memory root key (fast intrusion lockdown). Seal migration needs downtime + both seals available.

## Related

- [Seal / Unseal](../concepts/openbao-seal-unseal.md)
- [Seal config](openbao-config-seal.md)
- [OpenBao](../entities/openbao.md)
