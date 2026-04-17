---
title: "OWASP MCP Security Cheat Sheet"
tags: [owasp, mcp, ai, security, prompt-injection, tool-poisoning, supply-chain]
sources: [owasp-mcp-security.md]
updated: 2026-04-16
---

# OWASP MCP Security Cheat Sheet

Source: OWASP Cheat Sheet Series — MCP (Model Context Protocol) Security

## Summary

Comprehensive security guidance for Model Context Protocol deployments. MCP (introduced by Anthropic, Nov 2024) standardizes how AI applications connect to external tools — but creates a new attack surface where LLMs autonomously invoke tools against sensitive systems.

## Architecture

```
User ↔ MCP Host (AI App) ↔ MCP Client ↔ MCP Server(s) ↔ Tools / Data / APIs
```

- **MCP Host**: AI application (Claude Desktop, Cursor, IDE plugins)
- **MCP Client**: Connects to servers, passes tool definitions to LLM
- **MCP Server**: Exposes tools, resources, prompts via JSON-RPC
- **Transports**: `stdio` (local) or HTTP/SSE (remote)

Critical: the LLM sees _all_ tool descriptions from _all_ servers in context — enabling cross-server attacks.

## Key Risks

| Risk               | Description                                                                 |
| ------------------ | --------------------------------------------------------------------------- |
| Tool Poisoning     | Malicious instructions in tool descriptions/schemas manipulate LLM behavior |
| Rug Pull           | Server mutates tool definitions after approval                              |
| Tool Shadowing     | Malicious server description overrides behavior of other servers' tools     |
| Confused Deputy    | Server acts with its own broad privileges, not user's                       |
| Data Exfiltration  | Prompt injection encodes sensitive data in legitimate tool calls            |
| Over-Scoped Tokens | Broad OAuth scopes (full Gmail vs. read-only) create aggregation risk       |
| Supply Chain       | Typosquatted/compromised MCP packages from public registries                |
| Message Tampering  | JSON-RPC payloads modified after TLS termination by proxies                 |
| Sandbox Escape     | Local MCP servers with full host access                                     |

## 12 Best Practices (Summary)

1.  **Least Privilege** — per-server scoped credentials, narrow OAuth scopes, ephemeral tokens
2.  **Tool Schema Integrity** — inspect full schema, pin definitions with SHA-256, use `mcp-scan`
3.  **Sandbox Isolation** — containers/chroot, restrict FS access, separate sensitive servers
4.  **Human-in-the-Loop** — explicit approval for destructive/financial/data-sharing ops; show full parameters
5.  **Input/Output Validation** — treat all MCP inputs as untrusted; sanitize outputs before LLM re-injection; SSRF allowlist
6.  **Auth & Transport** — OAuth 2.0+PKCE, TLS everywhere, bind session to user context, 127.0.0.1 only
7.  **Message-Level Signing** — ECDSA P-256 signatures, nonce+timestamp, mutual signing, fail closed
8.  **Multi-Server Isolation** — each server = independent untrusted domain; monitor cross-server data flows
9.  **Supply Chain** — verified sources, checksums, typosquatting vigilance, dependency scanning, `mcp-scan`
10. **Monitoring & Auditing** — log all invocations with parameters; SIEM integration; redact PII
11. **Consent & Installation** — consent dialogs, show exact command, re-prompt on definition change
12. **Tool Return Injection** — treat responses as untrusted input; strip `<IMPORTANT>`/`<system>` tags; structured extraction

## Key Tool: mcp-scan

[mcp-scan](https://github.com/invariantlabs-ai/mcp-scan) — automated scanner to detect poisoned tool descriptions, cross-server shadowing, and post-installation mutations.

## Related Wiki Pages

- [MCP Security](../concepts/mcp-security.md)
- [Tool Poisoning](../concepts/tool-poisoning.md)
- [Prompt Injection](../concepts/prompt-injection.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [AI Agent Security](../concepts/ai-agent-security.md)
- [Human-in-the-Loop](../concepts/human-in-the-loop.md)
- [Anthropic](../entities/anthropic.md)
