---
title: "Multi-Agent Systems Security"
tags: [ai, agents, security, multi-agent, trust, communication]
sources: [owasp-ai-agent-security.md]
updated: 2026-04-15
---

# Multi-Agent Systems Security

Security considerations for systems where multiple AI agents communicate and collaborate.

## Threat Model

Multi-agent systems amplify single-agent risks:

- **Cascading failures**: A compromised agent passes malicious instructions to downstream agents
- **Privilege escalation**: A lower-trust agent convinces a higher-trust agent to perform forbidden actions
- **Trust spoofing**: An agent impersonates a trusted agent to gain elevated permissions
- **Memory poisoning propagation**: Injected data in one agent's memory spreads through the pipeline

## Trust Architecture

Assign each agent a trust level:

- `UNTRUSTED` — external/user-facing agents
- `INTERNAL` — internal pipeline agents
- `PRIVILEGED` — agents with elevated tool access
- `SYSTEM` — agents performing infrastructure operations

Rules:

- Agents should not receive system-level fields unless PRIVILEGED or SYSTEM
- Lower-trust agents cannot request higher-trust operations from higher-trust agents
- Trust levels are based on agent identity, not claimed permissions

## Secure Inter-Agent Communication

### Message Signing

All messages between agents should be:

1. Signed by the sender (asymmetric or HMAC key)
2. Timestamped
3. Verified by recipient: signature + freshness (5-minute window to prevent replay attacks)
4. Logged with sender/recipient/type/timestamp

### Payload Sanitization

Even signed messages from internal agents should be sanitized for injection content — a compromised internal agent could relay malicious payloads.

### Recipient Authorization

Agents should only be allowed to message specific recipient agents, defined at registration time.

## Circuit Breakers

Prevent cascading failures by implementing circuit breakers per agent:

- Track failure count over time window
- When failures exceed threshold (e.g., 5 failures), open the circuit
- While open: reject all messages from that agent
- Recovery timeout (e.g., 60s) before retry

## Isolation

- Run each agent in an isolated execution environment
- Don't share memory stores across agents unless explicitly designed
- Separate tool permissions per agent — don't inherit parent agent's tools

## Related Concepts

- [ai-agent-security](ai-agent-security.md)
- [prompt-injection](prompt-injection.md)
- [human-in-the-loop](human-in-the-loop.md)

## Sources

- [OWASP AI Agent Security Cheat Sheet](../sources/owasp-ai-agent-security.md)
