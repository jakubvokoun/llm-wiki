---
title: "OpenBao — Transit Seal Config"
tags: [openbao, configuration, seal, transit, auto-unseal]
sources: [openbao-config-seal-transit.md]
updated: 2026-07-03
---

# OpenBao — Transit Seal Config

Using another OpenBao/Vault **Transit** secret engine as the auto-unseal mechanism for [OpenBao](../entities/openbao.md). See [seal overview](openbao-config-seal.md).

## Key Takeaways

- Activated by a `seal "transit"` block **or** `VAULT_SEAL_TYPE=transit`. Encrypts/decrypts the root key against a remote Transit engine — a common way to **auto-unseal one OpenBao cluster using another** (useful in [Kubernetes](../sources/openbao-k8s.md) so pods don't need Shamir keys).
- **Required params:** `address` (target cluster, or `VAULT_ADDR`), `token` (`VAULT_TOKEN`), `key_name`, `mount_path`. Optional: `namespace`, `disable_renewal`, full `tls_*` set, and `disabled` (set true when migrating away from an autoseal).
- The auth token needs `update` on `<mount>/encrypt/<key>` and `<mount>/decrypt/<key>`. It **should be an [orphan](../concepts/openbao-tokens.md) + periodic token** (no max TTL) so the seal doesn't break when a parent expires. Prefer supplying the token via **env var**, not the file.
- Supports **key rotation** via the Transit engine's rotate endpoints; old key versions must be retained to decrypt older data.

## Related

- [Seal config](openbao-config-seal.md)
- [Seal / Unseal](../concepts/openbao-seal-unseal.md)
- [Tokens](../concepts/openbao-tokens.md)
- [OpenBao](../entities/openbao.md)
