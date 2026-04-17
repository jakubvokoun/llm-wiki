# llm-wiki

A personal knowledge base built and maintained by an LLM (Claude). Raw sources are ingested, summarized, and cross-linked into a browsable wiki.

## Structure

```
raw/      ← immutable source documents (fetched/converted by Claude)
wiki/     ← LLM-maintained markdown pages
  index.md       ← full content catalog
  log.md         ← append-only ingest/query history
  sources/       ← one summary page per ingested source
  entities/      ← people, organizations, products
  concepts/      ← ideas, frameworks, techniques
  analyses/      ← comparisons, syntheses, answers
```

## Usage

Open in Claude Code (the MCP server for markitdown is wired up via `.mcp.json`).

**Ingest a URL:**
> "Ingest https://example.com/article"

**Ask a question:**
> "What are the main approaches to secret management in Kubernetes?"

**Process the queue:**
> "Process the queue" — bulk-ingests all unchecked URLs in `queue.md`

**Health-check:**
> "Lint the wiki"

See `CLAUDE.md` for the full schema and operation details.
