---
title: "OpenBao — Self-Initialization (initialize stanza)"
tags: [openbao, configuration, initialization, bootstrap]
sources: [openbao-config-self-init.md]
updated: 2026-07-03
---

# OpenBao — Self-Initialization (initialize stanza)

Request-driven, one-time provisioning of an [OpenBao](../entities/openbao.md) server on first startup.

## Key Takeaways

- The `initialize` stanza runs a sequence of API requests **once** on first server start — provisioning auth, audit, and secret mounts declaratively instead of manual post-start API calls.
- Requires an [**auto-unseal**](openbao-config-seal.md) mechanism. **No recovery keys are generated**; use the authenticated recovery-key rotation endpoints instead. The **root token is not returned** to the caller and is **revoked after use**.
- To repeat, wipe all storage and re-initialize. Debug with `TRACE` log level (**contains sensitive data**).
- Requests obey normal restrictions (audit logging, auth). Each `request` block: `operation` (see [policy capabilities](../concepts/openbao-policies.md)), `path`, optional `token` (defaults to root), `data`, `allow_failure`.
- Multiple `initialize`/`request` blocks run in file order; names must be unique and match `^[A-Za-z_][A-Za-z0-9_-]*$`. Built on the [Profile System](https://openbao.org/docs/concepts/profiles/).

## Related

- [Server config](openbao-config.md)
- [seal / auto-unseal](openbao-config-seal.md)
- [Policies](../concepts/openbao-policies.md)
- [OpenBao](../entities/openbao.md)
