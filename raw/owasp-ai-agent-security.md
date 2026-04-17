# AI Agent Security Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/AI_Agent_Security_Cheat_Sheet.html

## Introduction

AI agents are autonomous systems powered by LLMs that can reason, plan, use tools, maintain memory, and take actions. This expanded capability introduces unique security risks beyond traditional LLM prompt injection.

## Key Risks

- **Prompt Injection (Direct & Indirect)**: Malicious instructions injected via user input or external data sources (websites, documents, emails)
- **Tool Abuse & Privilege Escalation**: Agents exploiting overly permissive tools
- **Data Exfiltration**: Sensitive info leaked through tool calls, API requests, or outputs
- **Memory Poisoning**: Malicious data persisted in agent memory to influence future sessions
- **Goal Hijacking**: Manipulating agent objectives to serve attacker purposes
- **Excessive Autonomy**: High-impact actions without appropriate human oversight
- **Cascading Failures**: Compromised agents in multi-agent systems propagating attacks
- **AI Console Malicious Configuration**: Developer consoles compelled to consume malicious configuration data
- **Denial of Wallet (DoW)**: Excessive API/compute costs through unbounded agent loops
- **Sensitive Data Exposure**: PII, credentials in agent context or logs
- **Supply Chain Attacks**: Compromising third-party tools, APIs, or data sources

## Best Practices

### 1. Tool Security & Least Privilege

- Grant agents minimum tools required for their specific task
- Implement per-tool permission scoping (read-only vs. write, specific resources)
- Use separate tool sets for different trust levels
- Require explicit tool authorization for sensitive operations
- Use allowlists for allowed paths, operations, and file patterns
- Example: Restrict `file_reader` to `/app/reports/*`, read-only, blocking `*.env`, `*.key`, `*secret*`

### 2. Input Validation & Prompt Injection Defense

- Treat all external data as untrusted (user messages, retrieved documents, API responses, emails)
- Implement input sanitization before including external content in agent context
- Use delimiters and clear boundaries between instructions and data
- Apply content filtering for known injection patterns
- Consider separate LLM calls to validate/summarize untrusted content
- See LLM Prompt Injection Prevention Cheat Sheet for detailed techniques

### 3. Memory & Context Security

- Validate and sanitize data before storing in agent memory
- Implement memory isolation between users/sessions
- Set memory expiration and size limits
- Audit memory contents for sensitive data before persistence
- Use cryptographic integrity checks for long-term memory (checksums per user_id + content)
- Scan for sensitive data patterns (SSN, credit card, passwords, API keys) before storing

### 4. Human-in-the-Loop Controls

- Require explicit approval for high-impact or irreversible actions
- Implement action previews before execution
- Set autonomy boundaries based on action risk levels
- Provide clear audit trails of agent decisions and actions
- Allow users to interrupt and rollback agent operations
- Risk classification: LOW (reads), MEDIUM (writes), HIGH (financial/deletion/external comms), CRITICAL (irreversible/security-sensitive)

### 5. Output Validation & Guardrails

- Validate agent outputs before execution or display
- Implement output filtering for sensitive data leakage
- Use structured outputs with schema validation (e.g., Pydantic)
- Set boundaries on output actions (rate limits, scope limits)
- Apply content safety filters to generated responses
- Detect exfiltration attempts (encoded data in URLs, large payloads to webhooks)

### 6. Monitoring & Observability

- Log all agent decisions, tool calls, and outcomes (redact sensitive fields)
- Implement anomaly detection for unusual behavior (excessive tool calls, failed calls, injection attempts)
- Track token usage and costs per session/user
- Set up alerts for security-relevant events (CRITICAL severity triggers immediate alert)
- Maintain audit trails for compliance and forensics
- Anomaly thresholds: >30 tool calls/minute, >5 failed tool calls, >1 injection attempt, >$10 cost/session

### 7. Multi-Agent Security

- Implement trust boundaries between agents (UNTRUSTED, INTERNAL, PRIVILEGED, SYSTEM)
- Validate and sanitize inter-agent communications
- Prevent privilege escalation through agent chains
- Isolate agent execution environments
- Apply circuit breakers to prevent cascading failures
- Sign messages between agents; verify signatures and freshness (5-minute expiry to prevent replay attacks)
- Lower-trust agents cannot receive system-level fields

### 8. Data Protection & Privacy

- Minimize sensitive data in agent context
- Implement data classification (PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED)
- Apply encryption for data at rest and in transit
- Enforce data retention and deletion policies
- Comply with privacy regulations (GDPR, CCPA)
- Auto-classify data using regex patterns (SSN, credit cards, health terms, API keys)
- Apply RESTRICTED handling: fully redact from context, logs, and output

## Do's and Don'ts

**Do:**
- Apply least privilege to all agent tools and permissions
- Validate and sanitize all external inputs
- Implement human-in-the-loop for high-risk actions
- Isolate memory and context between users/sessions
- Monitor agent behavior and set up anomaly detection
- Use structured outputs with schema validation
- Sign and verify inter-agent communications
- Classify data and apply appropriate protections

**Don't:**
- Give agents unrestricted tool access or wildcard permissions
- Trust content from external sources (websites, emails, documents)
- Allow agents to execute arbitrary code without sandboxing
- Store sensitive data in agent memory without encryption/redaction
- Let agents make high-impact decisions without human oversight
- Ignore cost controls (unbounded loops → Denial of Wallet)
- Pass unsanitized data between agents in multi-agent systems
- Log sensitive data (PII, credentials) in plain text

## References

- OWASP LLM Top 10
- OWASP LLM Prompt Injection Prevention Cheat Sheet
- NIST AI Risk Management Framework
- OpenAI Safety Best Practices
- Google Secure AI Framework (SAIF)
