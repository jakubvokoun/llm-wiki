---
title: "OpenBao — Seal / Unseal"
tags: [openbao, seal, unseal, shamir, auto-unseal, kms, encryption]
sources:
  [
    openbao-concept-seal.md,
    openbao-internals-architecture.md,
    openbao-internals-security.md,
    openbao-config-seal.md,
    openbao-config-seal-transit.md,
  ]
updated: 2026-07-03
---

# OpenBao — Seal / Unseal

How [OpenBao](../entities/openbao.md) protects its master encryption key at rest and gates all access behind an unseal step.

## Key hierarchy

Most data is encrypted with the **encryption key** (in the _keyring_) → the keyring is encrypted by the **root key** → the root key is encrypted by the **unseal key**. Unsealing is the process of obtaining the plaintext root key so the encryption key can be recovered.

## Sealed state

A freshly started server is **sealed**: it knows where/how to reach storage but can't decrypt anything. Before unsealing, the only possible operations are unseal and seal-status. Sealing (via API, single root operator) throws away the in-memory root key — useful to lock down fast on a detected intrusion. A node stays unsealed until resealed, restarted, or a storage error occurs.

## Shamir seal (default)

Uses [Shamir's Secret Sharing](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing) to split the unseal key into **shares** (default 5) with a required **threshold** (default 3). `bao operator unseal` adds shares one at a time (stateful, any order, from different machines). Each node in a cluster must be unsealed independently. Downside: awkward to automate.

## Auto-unseal

Delegates protecting the unseal key to a trusted device/service (cloud [KMS](key-management.md), HSM, or another OpenBao [Transit engine](../sources/openbao-config-seal-transit.md)) — configured via the [`seal` stanza](../sources/openbao-config-seal.md). At startup OpenBao asks the device to decrypt the root key. Simplifies operations and [Raft](openbao-integrated-storage.md) joins.

- With auto-unseal, initialization yields **recovery keys** (Shamir-split) instead of unseal keys. Recovery keys authorize quorum operations (e.g. `generate-root`, rekey) but **cannot** themselves unseal.
- **Critical risk:** auto-unseal creates a hard lifecycle dependency on the seal mechanism. If the KMS key becomes unavailable the cluster can't unseal; **if it's permanently deleted the cluster is unrecoverable, even from backups.** Guard it (e.g. AWS SCPs).

## Seal migration

Switching seal types requires brief full-cluster downtime and both old+new seals available. Back up first. Per-node: update the [`seal` config](../sources/openbao-config-seal.md) (add new auto-seal block, or `disabled = "true"` on the old), bring the node up, and `bao operator unseal -migrate`. Do standbys one at a time (retain quorum with Integrated Storage), then step down the active node so a migrated standby takes over.

## Related

- [Seal config](../sources/openbao-config-seal.md)
- [Transit seal](../sources/openbao-config-seal-transit.md)
- [Architecture](../sources/openbao-internals-architecture.md)
- [Key Management](key-management.md)
- [OpenBao](../entities/openbao.md)
- [source summary](../sources/openbao-concept-seal.md)
