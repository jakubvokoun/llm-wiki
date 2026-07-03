---
title: "OpenBao — Declarative Plugins (OCI)"
tags: [openbao, configuration, plugins, oci, supply-chain-security]
sources: [openbao-config-plugins.md]
updated: 2026-07-03
---

# OpenBao — Declarative Plugins (OCI)

The `plugin` stanza — declaratively distributing [OpenBao](../entities/openbao.md) plugins as OCI images.

## Key Takeaways

- Plugins can be distributed as **OCI images**; OpenBao checks local cache, verifies integrity, and downloads/extracts only new or updated binaries on startup. Advantages: automated discovery/install, SHA256 integrity verification, version management via config, and registry-based supply-chain security (auth, scanning, immutable storage).
- A `plugin "<type>" "<name>"` block requires `version`, `binary_name`, `sha256sum`, and either `image` (OCI URL) or `command` (a manually-downloaded binary). Optional `args`/`env` (only with `plugin_auto_register=true`). Same type+name allowed across different versions → seamless upgrades.
- **Global toggles:** `plugin_download_behavior` (`fail` default / `warn`), `plugin_auto_download`, `plugin_auto_register`, `plugin_download_max_size` (512 MiB default). Manual equivalents: `bao plugin init` / `bao plugin register`.
- **Private registry auth** reuses Docker/Podman credential files (`~/.docker/config.json`, `DOCKER_CONFIG`, `REGISTRY_AUTH_FILE`, `$XDG_RUNTIME_DIR/containers/auth.json`) — in Kubernetes, mount an Image Pull Secret.
- **Image requirements:** static Go binary in the image root (`FROM scratch` recommended).

```hcl
plugin "secret" "aws" {
  image       = "ghcr.io/openbao/openbao-plugin-secrets-aws"
  version     = "v1.0.0"
  binary_name = "openbao-plugin-secrets-aws"
  sha256sum   = "9fdd8be7...144c"
}
```

## Related

- [Server config](openbao-config.md)
- [Secrets Management](../concepts/secrets-management.md)
- [Container Security](../concepts/container-security.md)
- [OpenBao](../entities/openbao.md)
