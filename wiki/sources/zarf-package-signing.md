---
title: "Zarf Tutorial 5 — Package Signing and Verification"
tags: [zarf, supply-chain, cosign, signing, verification, airgap]
sources: [zarf-package-signing.md]
updated: 2026-04-23
---

# Zarf Tutorial 5 — Package Signing and Verification

Official Zarf tutorial covering cryptographic package signing with Cosign: generating keys, signing packages post-build, verifying signatures, and enforcing verification at deploy time.

## Key Takeaways

- `zarf tools gen-key` wraps Cosign key generation; produces `cosign.key` (private) and `cosign.pub` (public)
- Signing happens **after** package creation with `zarf package sign` — the package file is signed separately
- `zarf package verify` allows standalone verification without deploying
- `--key --verify` on deploy enforces verification; deployment fails if signature is invalid or missing
- Private key (`cosign.key`) must **never** be committed to version control
- Production environments should use cloud KMS (AWS KMS, GCP KMS, Azure Key Vault) instead of file-based keys

## Workflow

```bash
# 1. Generate key pair
zarf tools gen-key
# Produces: cosign.key, cosign.pub

# 2. Build package (unsigned)
zarf package create ./examples/wordpress

# 3. Sign the package
zarf package sign zarf-package-wordpress-amd64-26.0.0.tar.zst \
  --signing-key cosign.key \
  --signing-key-password <password>

# 4. Verify standalone
zarf package verify zarf-package-wordpress-amd64-26.0.0.tar.zst \
  --key cosign.pub

# 5. Deploy with verification enforced
zarf package deploy zarf-package-wordpress-amd64-26.0.0.tar.zst \
  --key cosign.pub --verify --confirm
```

## Verification Output

```
checksum verification status=PASSED
signature verification status=PASSED
```

## See Also

- [Zarf](../entities/zarf.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [Zarf Tutorial 3 — Deploy a Retro Arcade](zarf-retro-arcade.md)
