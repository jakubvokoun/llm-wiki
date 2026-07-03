---
title: "OpenBao — UI Config"
tags: [openbao, configuration, ui, web-interface, tls]
sources: [openbao-config-ui.md]
updated: 2026-07-03
---

# OpenBao — UI Config

Enabling the [OpenBao](../entities/openbao.md) built-in web interface.

## Key Takeaways

- The web UI (CRUD on secrets, auth, unseal, and more) is **not activated by default**. Enable with `ui = true` at the top level of the server config. Client-only nodes don't need it.
- The UI is served on the same port as the [listener](openbao-config-listener-tcp.md) at the `/ui/` path — at least one `listener` stanza is required. Binding to `127.0.0.1` limits access to the local machine.
- **TLS note:** the cert must be valid for every DNS name / IP (SAN) used to reach the UI. With a self-signed cert, browsers must install the root CA or they'll warn "untrusted" — installing the CA reduces MITM risk.

## Related

- [Server config](openbao-config.md)
- [listener/tcp](openbao-config-listener-tcp.md)
- [OpenBao](../entities/openbao.md)
