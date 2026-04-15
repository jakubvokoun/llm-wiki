# LLM Wiki — Schema

This is the configuration file for the LLM wiki. It tells Claude how the wiki is structured and how to operate on it.

## Directory layout

```
llm-wiki/
├── CLAUDE.md          ← this file (schema)
├── .mcp.json          ← MCP server config (markitdown)
├── shell.nix          ← nix shell providing markitdown-mcp
├── raw/               ← immutable source documents (you curate, LLM reads only)
│   └── assets/        ← locally downloaded images referenced by sources
└── wiki/              ← LLM-maintained markdown pages
    ├── index.md       ← content catalog (update on every ingest)
    └── log.md         ← append-only chronological record
```

## Page conventions

Every wiki page should have YAML frontmatter:

```yaml
---
title: "Page Title"
tags: [tag1, tag2]
sources: [filename-in-raw.md]
updated: YYYY-MM-DD
---
```

Page types and their location in `wiki/`:
- `wiki/sources/` — one summary page per raw source ingested
- `wiki/entities/` — people, organizations, products, places
- `wiki/concepts/` — ideas, frameworks, techniques, terms
- `wiki/analyses/` — comparisons, syntheses, answers to queries worth preserving

Internal links use standard markdown: `[[page-name]]` (Obsidian style) or `[label](../concepts/page.md)` (standard relative).

## MCP tools

### markitdown

The `markitdown` MCP server is available in this project (configured in `.mcp.json`, provided via `shell.nix` from nixpkgs unstable).

Tool: **`convert_to_markdown(uri)`**

Accepts `http:`, `https:`, `file:`, or `data:` URIs and returns the content as markdown. Use it to:
- Fetch a web page and save the result to `raw/` before ingesting
- Convert a local file (PDF, DOCX, etc.) to markdown on the fly

Example flows:
```
# Fetch a URL into raw/
convert_to_markdown("https://example.com/paper.html") → save to raw/paper.md → ingest

# Convert a local file
convert_to_markdown("file:///home/jakub/Downloads/report.pdf") → save to raw/report.md → ingest
```

The server runs over stdio. If it is not yet connected, restart Claude Code in this project directory so the MCP server is picked up.

## Operations

### Ingest

When told to ingest a source:

1. If the source is a URL or non-markdown file, use `convert_to_markdown(uri)` to fetch/convert it, then save the result to `raw/<slug>.md`
2. Read the source file from `raw/`
3. Discuss key takeaways with the user
4. Write a summary page in `wiki/sources/<slug>.md`
5. Update or create entity pages in `wiki/entities/` for notable people, orgs, products
6. Update or create concept pages in `wiki/concepts/` for key ideas
7. Update `wiki/index.md` — add the new source and any new pages
8. Append an entry to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] ingest | <Source Title>
   Summary sentence. Pages created/updated: list.
   ```

A single source typically touches 5–15 wiki pages.

### Query

When answering a question:

1. Read `wiki/index.md` to find relevant pages
2. Read the relevant pages
3. Synthesize an answer with citations (link to wiki pages and/or raw sources)
4. If the answer is valuable enough to keep, offer to file it as a new page in `wiki/analyses/`
5. If filed, append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] query | <Question Summary>
   Filed as: wiki/analyses/<slug>.md
   ```

### Lint

When asked to health-check the wiki:

1. Read `wiki/index.md` for a full inventory
2. Scan for:
   - Contradictions between pages
   - Stale claims superseded by newer sources
   - Orphan pages (no inbound links)
   - Concepts mentioned but lacking their own page
   - Missing cross-references between related pages
   - Data gaps worth filling with a web search
3. Report findings, suggest fixes, ask which to apply
4. Append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] lint
   Issues found: N. Fixed: M. Notes.
   ```

## index.md format

```markdown
# Wiki Index

## Sources
| Page | Summary | Date |
|------|---------|------|
| [Title](sources/slug.md) | One-line summary | YYYY-MM-DD |

## Entities
| Page | Type | Summary |
|------|------|---------|
| [Name](entities/name.md) | person/org/product | One-line |

## Concepts
| Page | Summary |
|------|---------|
| [Name](concepts/name.md) | One-line |

## Analyses
| Page | Summary | Date |
|------|---------|------|
| [Title](analyses/slug.md) | One-line | YYYY-MM-DD |
```

## log.md format

Append-only. Entries prefixed with `## [YYYY-MM-DD] <type> | <title>` so they're greppable:

```bash
grep "^## \[" wiki/log.md | tail -10   # last 10 events
grep "ingest" wiki/log.md              # all ingests
```

### Process queue

When told to process the queue:

1. Read `queue.md`, collect all unchecked URLs (`- [ ]`)
2. For each URL:
   1. `convert_to_markdown(url)` via the markitdown MCP tool
   2. Save result to `raw/<slug>.md`
   3. Run the full **Ingest** operation for that source
   4. Mark the URL as done: `- [x] <url> <!-- ingested YYYY-MM-DD -->`
3. Append a single entry to `wiki/log.md` covering all processed URLs:
   ```
   ## [YYYY-MM-DD] queue | N sources processed
   URLs: list. Pages created/updated: list.
   ```

## Tips

- Read `wiki/index.md` first on every session to orient yourself
- Read `wiki/log.md` tail to understand what was done recently
- Never modify files in `raw/` — read only
- Prefer updating existing pages over creating new ones for minor additions
- Every new page must be added to `wiki/index.md`
- Cross-link liberally — the graph is the value
