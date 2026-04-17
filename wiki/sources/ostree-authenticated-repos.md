---
title: "OSTree Authenticated Remote Repositories"
tags: [ostree, atomic-linux, authentication, mtls, http, access-control]
sources: [ostree-authenticated-repos.md]
updated: 2026-04-17
---

# OSTree Authenticated Remote Repositories

OSTree speaks to a **generic webserver**, so any standard HTTP authentication mechanism works.
There is no special OSTree server protocol.

## Authentication methods

### Mutual TLS (recommended)

Each device gets a unique client certificate. The webserver validates it before serving content.

```ini
# /etc/ostree/remotes.d/myremote.conf
[remote "myremote"]
url=https://updates.example.com/ostree
tls-client-cert-path=/etc/ostree/client.crt
tls-client-key-path=/etc/ostree/client.key
```

### HTTP Basic authentication

Supported but has management drawbacks (credential rotation, leakage in logs/URLs).

### Cookies

Cookie-based authentication supported since [ostreedev/ostree#531](https://github.com/ostreedev/ostree/pull/531).
Enables integration with **AWS CloudFront signed cookies** for private S3-backed repos.

## Use cases

| Method     | Use case                                                  |
| ---------- | --------------------------------------------------------- |
| mTLS       | Per-device fleet access, zero-knowledge auth              |
| Basic auth | Simple private repos (dev/test, not recommended for prod) |
| Cookies    | CDN-gated repos (CloudFront, Fastly)                      |

## Related pages

- [OSTree Data Formats](ostree-formats.md) — archive format and static webserver model
- [OSTree Buildsystem and Repository Management](ostree-buildsystem-and-repos.md) — repo setup
- [TLS](../concepts/tls.md) — mTLS background
- [OSTree](../entities/ostree.md) — OSTree entity page
