---
title: "Zarf Tutorial 3 — Deploy a Retro Arcade"
tags: [zarf, kubernetes, oci, cosign, supply-chain]
sources: [zarf-retro-arcade.md]
updated: 2026-04-23
---

# Zarf Tutorial 3 — Deploy a Retro Arcade

Official Zarf tutorial deploying the dos-games package directly from an OCI registry with inline Cosign signature verification.

## Key Takeaways

- Zarf packages can be deployed directly from OCI registries using the `oci://` URI scheme — no manual download needed
- `--key` flag verifies the package's Cosign signature before deploying; fails fast if signature invalid
- `zarf connect` commands are defined in the package and auto-open a browser session
- Demonstrates the full online → airgap-ready workflow: same `zarf package deploy` command works for local files and OCI registries

## Commands

```bash
# Deploy from OCI with signature verification
zarf package deploy oci://ghcr.io/zarf-dev/packages/dos-games:1.3.0 \
  --key=https://zarf.dev/cosign.pub

# Connect to the deployed service
zarf connect games

# Remove
zarf package list
zarf package remove dos-games --confirm
```

## See Also

- [Zarf](../entities/zarf.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [Zarf Tutorial 5 — Package Signing and Verification](zarf-package-signing.md)
