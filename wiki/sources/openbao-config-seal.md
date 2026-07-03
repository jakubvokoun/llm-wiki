---
title: "OpenBao — Seal Config (overview)"
tags: [openbao, configuration, seal, auto-unseal, kms, hsm]
sources: [openbao-config-seal.md]
updated: 2026-07-03
---

# OpenBao — Seal Config (overview)

The `seal` stanza configures the [seal type](../concepts/openbao-seal-unseal.md) for auto-unsealing [OpenBao](../entities/openbao.md).

## Key Takeaways

- The `seal` stanza selects an HSM/KMS mechanism to encrypt/decrypt the **root key** (auto-unseal). It is **optional** — if omitted, OpenBao uses **Shamir** secret sharing to split the root key.
- Syntax: `seal "<type>" { ... }`. Env vars take precedence over file values for options that read both.
- **Available seal types** (most referenced upstream, only Transit ingested here): [`transit`](openbao-config-seal-transit.md) (another OpenBao/Vault Transit engine — good for k8s auto-unseal chaining), and cloud/HSM providers: [AWS KMS](https://openbao.org/docs/configuration/seal/awskms/), [Azure Key Vault](https://openbao.org/docs/configuration/seal/azurekeyvault/), [GCP Cloud KMS](https://openbao.org/docs/configuration/seal/gcpckms/), [OCI KMS](https://openbao.org/docs/configuration/seal/ocikms/), [AliCloud KMS](https://openbao.org/docs/configuration/seal/alicloudkms/), [KMIP](https://openbao.org/docs/configuration/seal/kmip/), [PKCS#11 / HSM](https://openbao.org/docs/configuration/seal/pkcs11/), and [Static Key](https://openbao.org/docs/configuration/seal/static/).
- Auto-unseal is a prerequisite for [self-initialization](openbao-config-self-init.md) and simplifies [Raft](openbao-config-storage-raft.md) cluster joins (challenge answered automatically).

## Related

- [Seal / Unseal](../concepts/openbao-seal-unseal.md)
- [transit seal](openbao-config-seal-transit.md)
- [Server config](openbao-config.md)
- [OpenBao](../entities/openbao.md)
