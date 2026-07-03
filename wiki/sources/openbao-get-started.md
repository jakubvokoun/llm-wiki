---
title: "OpenBao — Developer Quick Start"
tags: [openbao, getting-started, dev-server, kv]
sources: [openbao-get-started.md]
updated: 2026-07-03
---

# OpenBao — Developer Quick Start

Storing and retrieving a first secret with the [OpenBao](../entities/openbao.md) client libraries.

## Key Takeaways

- **Start a dev server:** `bao server -dev -dev-root-token-id="dev-only-token"` — an in-memory, insecure server that listens on HTTP `:8200`. **Never use in production**; the root token grants full access.
- **Client libraries:** official **Go** library `github.com/openbao/openbao/api/v2`; examples also given in **Bash (curl)**.
- **Authenticate:** point the client at `http://127.0.0.1:8200` and `SetToken(...)` (here the dev root token); real deployments use proper [auth methods](../concepts/openbao-auth-methods.md).
- **Write/read a secret** via the **KV v2** engine mounted at `secret/`: `client.KVv2("secret").Put/Get(...)`, or the HTTP API at `/v1/secret/data/<path>` with the `X-Vault-Token` header.
- For app integration without code changes, see the OpenBao Agent (`/docs/agent-and-proxy/agent/`).

## Related

- [OpenBao](../entities/openbao.md)
- ['Dev' server & tokens](../concepts/openbao-tokens.md)
- [Auth methods](../concepts/openbao-auth-methods.md)
