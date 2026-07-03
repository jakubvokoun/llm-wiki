---
title: "OpenBao — Installing"
tags: [openbao, installation, hardening, supply-chain-security]
sources: [openbao-install.md]
updated: 2026-07-03
---

# OpenBao — Installing

Installation options for [OpenBao](../entities/openbao.md) and post-install hardening.

## Key Takeaways

- **Install paths:** package manager (Homebrew, FreeBSD `pkg`, Arch `pacman -Sy openbao`, Fedora/RHEL via EPEL `dnf install openbao`), container registries, precompiled binary, from source, or [Helm on Kubernetes](openbao-k8s-helm.md).
- **Container images** are published (Alpine + RHEL UBI variants) to `ghcr.io`, `quay.io`, and `docker.io` under `openbao/openbao` (and `-ubi`).
- **Binary:** the single `bao` binary is all that is needed; place it on `PATH`. Verify with `bao -h`.
- **Post-install hardening — swap:** memory paging (swap) can leak secrets to disk. Disable or encrypt swap. The provided systemd unit sets `MemorySwapMax=0`; Docker: run with `--memory-swappiness=0`; macOS swap is always encrypted; Windows: `fsutil behavior set encryptpagingfile 1`.
- **Artifact verification:** SHA-256 checksums, GPG signatures (OpenBao release key), and Cosign/Rekor (Sigstore) transparency-log verification are all supported.

## Related

- [OpenBao](../entities/openbao.md)
- [Run OpenBao on Kubernetes](openbao-k8s-helm-run.md)
- [Secrets Management](../concepts/secrets-management.md)
