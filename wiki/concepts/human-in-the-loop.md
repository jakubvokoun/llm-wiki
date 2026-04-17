---
title: "Human-in-the-Loop (AI Agents)"
tags: [ai, agents, security, human-oversight, risk-management]
sources: [owasp-ai-agent-security.md]
updated: 2026-04-15
---

# Human-in-the-Loop (HITL)

Human-in-the-loop controls require human approval before an AI agent executes high-impact or irreversible actions.

## Why It Matters

Autonomous AI agents can take actions with real-world consequences: sending emails, executing code, deleting records, making financial transactions. Without HITL controls, a single prompt injection or misunderstanding can cause significant harm.

## Risk-Based Action Classification

| Risk Level | Example Actions                                            | Policy                              |
| ---------- | ---------------------------------------------------------- | ----------------------------------- |
| LOW        | Read operations, safe queries, document retrieval          | Auto-approve                        |
| MEDIUM     | File writes, API calls, database reads                     | Log; optionally queue for review    |
| HIGH       | Send email, execute code, external communications          | Require human approval              |
| CRITICAL   | Database deletion, financial transfers, credential changes | Mandatory approval + action preview |

## HITL Controls

### Action Preview

Before executing a high-risk action, show the human:

- What the action is
- Risk level
- Exact parameters (sanitized for display)
- Agent's explanation for why it wants to do this

### Approval Flow

- Queue pending actions with unique IDs
- Present to human via UI, notification, or callback
- Human approves, modifies, or rejects
- Support time-bounded approvals (auto-reject if not responded to within N minutes)

### Interrupt and Rollback

- Allow humans to stop an in-progress agent run
- Support rollback for reversible actions where possible
- Provide audit trail of all decisions and their outcomes

## Autonomy Boundaries

Not all actions need the same treatment. HITL should be calibrated to risk:

- **Over-supervision** reduces agent utility and causes approval fatigue
- **Under-supervision** creates unacceptable risk

Good HITL systems learn the user's approval patterns and adapt thresholds over time.

## Related Concepts

- [ai-agent-security](ai-agent-security.md)
- [prompt-injection](prompt-injection.md)
- [multi-agent-systems](multi-agent-systems.md)

## Sources

- [OWASP AI Agent Security Cheat Sheet](../sources/owasp-ai-agent-security.md)
