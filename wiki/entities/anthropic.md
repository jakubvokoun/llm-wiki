---
title: "Anthropic"
tags: [anthropic, ai, llm, mcp, entity]
sources: [owasp-mcp-security.md]
updated: 2026-04-16
---

# Anthropic

AI safety company; creator of the Claude family of LLM models and the Model Context Protocol (MCP).

## Key Products / Initiatives

- **Claude** — family of LLM models (Haiku, Sonnet, Opus series)
- **Model Context Protocol (MCP)** — open protocol introduced November 2024 standardizing how AI applications connect to external tools, data, and services
- **Claude Code** — AI coding assistant (CLI + IDE integrations)

## MCP

MCP is Anthropic's answer to fragmented AI tool integrations — a "USB-C port for AI" replacing custom per-integration code with a single protocol. Widely adopted by IDE plugins (Cursor, etc.) and AI desktop apps.

See [MCP Security](../concepts/mcp-security.md) for security implications.
