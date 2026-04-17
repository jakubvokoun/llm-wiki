---
title: "AI Agent Security"
tags: [ai, agents, llm, security, prompt-injection, tool-security]
sources: [owasp-ai-agent-security.md]
updated: 2026-04-15
---

# AI Agent Security

Security practices for autonomous AI agents — LLM-powered systems that can reason, plan, use tools, maintain memory, and take actions.

## What Makes Agents Different

Traditional LLMs respond to prompts. Agents also:

- Execute tools (shell commands, APIs, file system, email)
- Maintain persistent memory across sessions
- Operate in multi-agent pipelines
- Take real-world actions (financial transactions, deployments, communications)

This autonomy dramatically expands the attack surface.

## Key Threat Model

| Threat                      | Mechanism                                                        |
| --------------------------- | ---------------------------------------------------------------- |
| Prompt injection (direct)   | Malicious user input hijacks agent behavior                      |
| Prompt injection (indirect) | Malicious content in external data (documents, emails, websites) |
| Tool abuse                  | Overly permissive tools used for unintended actions              |
| Memory poisoning            | Malicious data persisted to influence future sessions            |
| Goal hijacking              | Agent objectives manipulated by attacker                         |
| Denial of Wallet (DoW)      | Unbounded loops causing excessive API costs                      |
| Cascading failures          | Compromised agent attacks other agents in pipeline               |
| Data exfiltration           | Sensitive data leaked via tool calls or outputs                  |

## Control Framework

### Tool Security (Least Privilege)

- Allowlist specific paths/operations per tool
- Separate tool sets by trust level
- Require explicit authorization for: `send_email`, `execute_code`, `database_write`, `file_delete`

### Input Handling

- All external data is untrusted — user input, documents, API responses, emails
- Delimiters between instructions and external data
- Content filtering for injection patterns
- See [prompt-injection](prompt-injection.md)

### Memory Security

- Validate + sanitize before storing
- Isolate memory per user/session
- TTL and size limits
- Integrity checksums (content + user_id)
- Scan for PII/secrets before persistence

### Human-in-the-Loop

- LOW risk (reads): auto-approve
- MEDIUM (writes): log + optionally queue
- HIGH (email, code exec): require human approval
- CRITICAL (deletion, financial): mandatory approval + preview
- See [human-in-the-loop](human-in-the-loop.md)

### Multi-Agent Security

- Trust tiers: UNTRUSTED → INTERNAL → PRIVILEGED → SYSTEM
- Sign all messages; verify signature + timestamp (5-min replay window)
- Circuit breakers for cascading failure prevention
- See [multi-agent-systems](multi-agent-systems.md)

### Monitoring

- Log all tool calls (redact sensitive fields)
- Anomaly thresholds: tool call rate, failed calls, injection attempts, session cost
- CRITICAL events trigger immediate alerts

## Related Concepts

- [prompt-injection](prompt-injection.md)
- [human-in-the-loop](human-in-the-loop.md)
- [multi-agent-systems](multi-agent-systems.md)
- [denial-of-wallet](denial-of-wallet.md)
- [secrets-management](secrets-management.md)

## Sources

- [OWASP AI Agent Security Cheat Sheet](../sources/owasp-ai-agent-security.md)
