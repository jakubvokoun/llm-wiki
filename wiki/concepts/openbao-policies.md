---
title: "OpenBao — Policies (ACLs)"
tags: [openbao, policies, acl, authorization, hcl, security]
sources: [openbao-concept-policies.md, openbao-internals-security.md]
updated: 2026-07-03
---

# OpenBao — Policies (ACLs)

Path-based ACLs that grant or forbid access to [OpenBao](../entities/openbao.md) operations. **Deny by default** — an empty policy grants nothing.

## Authorization workflow

An admin configures an [auth method](openbao-auth-methods.md), writes HCL/JSON policies (referenced by name — like a symlink to a rule set), and **maps** auth-method data (e.g. LDAP groups) to policy names. On login OpenBao delegates auth, maps the result to policies, and issues a [token](openbao-tokens.md) with those policies attached. Re-authenticating yields a _new_ token with the same permissions.

## Syntax & matching

```hcl
path "secret/foo" { capabilities = ["read"] }
path "secret/*"   { capabilities = ["create","read","update","patch","delete","list","scan"] }
path "secret/super-secret" { capabilities = ["deny"] }  # deny always wins
```

- Glob `*` is only valid **as the last character** (prefix match, not regex); `+` matches one path segment.
- Rules use the **most-specific match** (exact or longest-prefix). Same pattern in multiple policies → **union** of capabilities; different patterns → highest-priority match by a documented priority ordering.

## Capabilities

`create` (POST/PUT), `read` (GET), `update` (POST/PUT), `patch` (PATCH), `delete` (DELETE), `list`, `scan` — plus non-HTTP `sudo` (access root-protected paths) and `deny` (always takes precedence). Capabilities map to the **HTTP verb, not the action** — e.g. generating DB creds is a `read`. `list`/`scan` keys are **not** filtered by policy — don't encode secrets in key names.

## Advanced

- **Templated policies** inject identity data, e.g. `path "secret/data/{{identity.entity.id}}/*"` — prefer IDs over names.
- **Parameter constraints:** `allowed_parameters`, `denied_parameters`, `required_parameters` (unsupported on KV v2), plus `pagination_limit`, path `expiration`, and `min/max_wrapping_ttl` (forces [response wrapping](https://openbao.org/docs/concepts/response-wrapping/)).
- **Built-in policies:** `default` (attached to all tokens unless excluded; editable) and `root` (can do _anything_ — revoke root tokens before production).

## Related

- [Tokens](openbao-tokens.md)
- [Auth methods](openbao-auth-methods.md)
- [Identity](openbao-identity.md)
- [Security model](../sources/openbao-internals-security.md)
- [OpenBao](../entities/openbao.md)
- [source summary](../sources/openbao-concept-policies.md)
