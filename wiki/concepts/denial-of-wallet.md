---
title: "Denial of Wallet (DoW)"
tags: [ai, agents, security, dos, cost, llm]
sources: [owasp-ai-agent-security.md]
updated: 2026-04-15
---

# Denial of Wallet (DoW)

Denial of Wallet is an attack against AI agent systems that causes excessive API calls or compute usage, resulting in significant unexpected costs.

## Mechanism

Unlike traditional DoS (which targets availability), DoW targets the **financial resources** of the system operator:

1. Attacker crafts input that causes the agent to enter loops, spawn sub-agents, or make many API calls
2. Each API call (LLM inference, tool execution) has a cost
3. Unbounded execution creates exponentially growing cost

Example attack vectors:

- Prompt causing infinite search loops ("keep searching until you find X")
- Tasks that spawn many sub-agents ("analyze each of these 10,000 documents separately")
- Recursive tool calls with no termination condition
- Adversarial input designed to maximize token consumption

## Mitigations

### Hard Limits

- Maximum tool calls per session (e.g., 100)
- Maximum tokens generated per session
- Maximum cost per session (e.g., $10)
- Maximum agent chain depth

### Rate Limiting

- Tool call rate per minute (e.g., 30 calls/min)
- API request rate per user/session

### Monitoring and Alerts

- Track cost per session in real-time
- Alert when cost exceeds threshold
- Automatically halt sessions that hit limits

### Design Controls

- Require explicit termination conditions for iterative tasks
- Cap sub-agent spawning depth
- Use cheaper models for initial screening tasks

## Relationship to Traditional DoS

DoW is a variant of resource exhaustion attacks. Traditional DoS exhausts compute/network capacity. DoW exhausts budget. Both deny service — one temporarily, one potentially permanently (account suspension or billing issues).

## Related Concepts

- [ai-agent-security](ai-agent-security.md)
- [human-in-the-loop](human-in-the-loop.md)

## Sources

- [OWASP AI Agent Security Cheat Sheet](../sources/owasp-ai-agent-security.md)
