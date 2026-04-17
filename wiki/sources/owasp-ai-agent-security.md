---
title: "OWASP AI Agent Security Cheat Sheet"
tags: [owasp, ai, agents, llm, security, prompt-injection]
sources: [owasp-ai-agent-security.md]
updated: 2026-04-15
---

# OWASP AI Agent Security Cheat Sheet

Security best practices for AI agent architectures — autonomous LLM-powered systems that can reason, plan, use tools, maintain memory, and take actions.

## Key Takeaways

AI agents introduce security risks beyond traditional LLM prompt injection due to their autonomy and tool access. The combination of tool permissions, persistent memory, and multi-agent communication creates novel attack surfaces.

## Key Risks

| Risk                    | Description                                                            |
| ----------------------- | ---------------------------------------------------------------------- |
| Prompt Injection        | Direct (user input) or indirect (external documents, emails, websites) |
| Tool Abuse              | Overly permissive tools exploited for unintended actions               |
| Data Exfiltration       | Sensitive info leaked via tool calls or outputs                        |
| Memory Poisoning        | Malicious data persisted to influence future sessions                  |
| Goal Hijacking          | Agent objectives manipulated to serve attacker purposes                |
| Excessive Autonomy      | High-impact actions without human oversight                            |
| Cascading Failures      | Compromised agent propagates attack through multi-agent system         |
| Denial of Wallet (DoW)  | Unbounded loops causing excessive API/compute costs                    |
| Sensitive Data Exposure | PII or credentials in agent context or logs                            |

## Controls

### Tool Security & Least Privilege

- Allowlist specific paths, operations, file patterns per tool
- Separate tool sets for different trust levels
- Require explicit authorization for sensitive operations (`send_email`, `execute_code`, `database_write`, `file_delete`)
- Tool authorization middleware pattern: check `SENSITIVE_TOOLS` list before execution

### Input Validation & Prompt Injection Defense

- All external data (documents, emails, API responses) is untrusted
- Use delimiters between instructions and data
- Content filtering for known injection patterns
- Consider separate LLM validation pass for untrusted content

### Memory & Context Security

- Validate and sanitize before storing in memory
- Isolate memory between users/sessions (user_id scoping)
- Memory expiration (TTL) and size limits
- Cryptographic integrity checks (checksum per content + user_id)
- Scan for sensitive patterns before persistence (SSN, credit card, API keys)

### Human-in-the-Loop

- Risk levels: LOW (reads) → MEDIUM (writes) → HIGH (email, code exec) → CRITICAL (deletion, financial)
- Auto-approve LOW; queue MEDIUM+ for human review
- Provide action previews with risk level and parameters
- Allow interrupt and rollback

### Output Validation & Guardrails

- Schema validation for structured outputs (Pydantic)
- PII filtering before outputting responses
- Detect exfiltration patterns (encoded data in URLs, large webhook payloads)
- Rate limiting on agent actions (e.g., 100 calls/60s)

### Monitoring

- Log all tool calls with redacted sensitive fields
- Anomaly thresholds: >30 tool calls/min, >5 failed calls, >1 injection attempt, >$10/session
- CRITICAL events trigger immediate alerts

### Multi-Agent Security

- Trust levels: UNTRUSTED → INTERNAL → PRIVILEGED → SYSTEM
- Sign all inter-agent messages; verify signatures + freshness (5-minute window)
- Prevent replay attacks with timestamp validation
- Circuit breakers to prevent cascading failures
- Lower-trust agents cannot receive system-level fields

### Data Protection

- Auto-classify data: RESTRICTED (SSN, health, credit card, API keys), CONFIDENTIAL (salary, secrets), INTERNAL, PUBLIC
- RESTRICTED: fully redact from context, logs, and output
- CONFIDENTIAL: partially mask; fully redact from logs

## Do's and Don'ts

**Do:** least privilege tools, validate all external input, human-in-the-loop for high risk, isolate memory, monitor/anomaly-detect, schema validate outputs, sign inter-agent comms, classify data.

**Don't:** wildcard tool permissions, trust external content, unsandboxed code execution, unencrypted sensitive memory, ignore cost controls, unsanitized inter-agent data, log PII in plaintext.

## Related Pages

- [concepts/ai-agent-security](../concepts/ai-agent-security.md)
- [concepts/prompt-injection](../concepts/prompt-injection.md)
- [concepts/human-in-the-loop](../concepts/human-in-the-loop.md)
- [concepts/multi-agent-systems](../concepts/multi-agent-systems.md)
- [concepts/denial-of-wallet](../concepts/denial-of-wallet.md)
- [concepts/secrets-management](../concepts/secrets-management.md)
