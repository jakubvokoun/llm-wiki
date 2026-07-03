---
title: "OpenBao — TCP Listener Config"
tags: [openbao, configuration, listener, tls, acme, networking]
sources: [openbao-config-listener-tcp.md]
updated: 2026-07-03
---

# OpenBao — TCP Listener Config

The `tcp` [listener](openbao-config.md) stanza for [OpenBao](../entities/openbao.md) — the primary way OpenBao serves its API.

## Key Takeaways

- Binds an `address` (default `127.0.0.1:8200`) and `cluster_address` (default one port higher, `:8201`). Multiple `listener` stanzas → must also set `api_addr` and `cluster_addr`. Supports IPv4/IPv6 and go-sockaddr templates.
- **TLS is assumed by default** — must explicitly `tls_disable = "true"` to opt out. Key params: `tls_cert_file`, `tls_key_file` (both reload on `SIGHUP` from the _startup_ path), `tls_min_version` (`tls12`)/`tls_max_version` (`tls13`), `tls_cipher_suites`, and mutual-TLS client auth via `tls_require_and_verify_client_cert` + `tls_client_ca_file`.
- **ACME:** enabled by default (Let's Encrypt prod CA) when `tls_cert_file` is empty. Strongly recommend setting `tls_acme_domains` (an allow-list) to prevent abuse; can disable HTTP/ALPN challenges.
- **Hardening defaults (v2.5.x):** `disable_unauthed_rekey_endpoints` and `disable_unauthed_generate_root_endpoints` now default to `true`.
- **Per-listener sub-stanzas:** `telemetry` (`unauthenticated_metrics_access`, `disallow_metrics`, `metrics_only` — used to split a dedicated metrics listener for Prometheus), `profiling` (`unauthenticated_pprof_access`), `custom_response_headers` (HSTS/CSP per status code; `X-Vault-` prefix rejected).
- `x_forwarded_for_authorized_addrs` trusts the LB's `X-Forwarded-For` so audit logs show the real client IP; PROXY protocol v1 supported.

## Related

- [Server config](openbao-config.md)
- [UI](openbao-config-ui.md)
- [telemetry](openbao-config-telemetry.md)
- [Security model](openbao-internals-security.md)
- [OpenBao](../entities/openbao.md)
