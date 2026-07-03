---
title: "OpenBao — What is OpenBao?"
tags: [openbao, secrets-management, overview]
sources: [openbao-what-is-openbao.md]
updated: 2026-07-03
---

# OpenBao — What is OpenBao?

Overview of [OpenBao](../entities/openbao.md) as an identity-based secrets and encryption management system.

## Key Takeaways

- A **secret** is anything you tightly control access to (API keys, passwords, certificates). OpenBao gates encryption services behind authentication + authorization and keeps an audit trail.
- Solves **credential sprawl**: centralizes secrets otherwise scattered across source code, config files, and env vars in plaintext.
- Works primarily with **tokens**, each associated with a path-based **policy** that constrains actions/paths per client.
- **Core workflow (4 stages):** Authenticate → Validate (against trusted sources: GitHub, LDAP, AppRole…) → Authorize (policy match, declarative allow/deny) → Access (token issued per identity's policies).
- **Key features:** secure secret storage (encrypted at rest), [dynamic secrets](../concepts/openbao-leases.md) generated on demand, data encryption without storage, leasing & renewal, and revocation (including trees of secrets, aiding key rolling and intrusion lockdown).

## Related

- [OpenBao](../entities/openbao.md)
- [Secrets Management](../concepts/secrets-management.md)
- [Tokens](../concepts/openbao-tokens.md)
- [Policies](../concepts/openbao-policies.md)
