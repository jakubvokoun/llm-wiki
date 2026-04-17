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

1. If the source is a URL or non-markdown file, use `convert_to_markdown(uri)` to fetch/convert it. Before saving, strip web boilerplate: navigation menus, headers/footers, cookie banners, sidebar widgets, social share buttons, comment sections, subscription prompts, and repeated link lists. Keep only the article/document body. Save the cleaned result to `raw/<slug>.md`.
2. Read the source file from `raw/`
3. Discuss key takeaways with the user
4. Write a summary page in `wiki/sources/<slug>.md`
5. Update or create entity pages in `wiki/entities/` for notable people, orgs, products
6. Update or create concept pages in `wiki/concepts/` for key ideas
7. Run `nix-shell --run "prettier --write <file>"` on every wiki page created or updated in steps 4–6
8. Update `wiki/index.md` — add the new source and any new pages
9. Append to the `## [YYYY-MM-DD]` block in `wiki/log.md` (create it if needed):
   ```
   - **ingest (1):** <slug>
   - **concepts:** new concepts created
   - **entities:** new entities created
   - **updated:** pages updated
   ```

A single source typically touches 5–15 wiki pages.

> **Formatting rule:** After writing or updating any wiki page, always run `nix-shell --run "prettier --write <file>"` before moving on.

### Query

When answering a question:

1. Read `wiki/index.md` to find relevant pages
2. Read the relevant pages
3. Synthesize an answer with citations (link to wiki pages and/or raw sources)
4. If the answer is valuable enough to keep, offer to file it as a new page in `wiki/analyses/`
5. If filed, run `nix-shell --run "prettier --write <file>"` on the new page, then append to the `## [YYYY-MM-DD]` block in `wiki/log.md`:
   ```
   - **query:** <question summary>. Filed as: wiki/analyses/<slug>.md
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
4. Append to the `## [YYYY-MM-DD]` block in `wiki/log.md`:
   ```
   - **lint:** Issues found: N. Fixed: M. Notes.
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

Append-only. One `## [YYYY-MM-DD]` block per day; each block is a bullet list:

```markdown
## [YYYY-MM-DD]

- **init:** (first day only) Wiki bootstrapped.
- **ingest (N):** slug1, slug2, ...
- **queue (N):** slug1, slug2, ...
- **concepts:** concept1, concept2, ...
- **entities:** entity1, entity2, ...
- **updated:** page1, page2, ...
- **query:** question summary. Filed as: wiki/analyses/slug.md
- **lint:** Issues found: N. Fixed: M. Notes.
```

Omit bullet types that don't apply on a given day. If the day's block already exists, append to it — merging into existing same-type bullets rather than adding duplicate lines. E.g. if `**concepts:**` already exists, extend the comma-separated list; if `**queue (N):**` already exists, merge the items and update the count.

```bash
grep "^## \[" wiki/log.md | tail -10   # last 10 days
```

### Process queue

When told to process the queue:

1. Read `queue.md`, collect all unchecked URLs (`- [ ]`)
2. **Phase 1 — Fetch (parallel haiku subagents):** Spawn one `claude-haiku-4-5-20251001` subagent per URL **in parallel**. Each subagent:
   1. Calls `convert_to_markdown(url)` via the markitdown MCP tool
   2. Strips web boilerplate (nav, footer, cookie banners, sidebars, share buttons) — keeps article body only
   3. Writes cleaned result to `raw/<slug>.md`
   4. Returns the slug (e.g. `owasp-rest-security`)

   The large markdown content stays in each subagent's context — it never enters yours.

3. **Phase 2 — Ingest (use `claude-sonnet-4-6`):** For each slug returned from Phase 1:
   1. Run the full **Ingest** operation (steps 2–8) for that source
   2. Mark the URL as done: `- [x] <url> <!-- ingested YYYY-MM-DD -->`
   3. Run `/clear` to reset context before processing the next URL
4. Append to the `## [YYYY-MM-DD]` block in `wiki/log.md` (create it if needed):
   ```
   - **queue (N):** slug1, slug2, ...
   - **concepts:** concepts created
   - **entities:** entities created
   - **updated:** pages updated
   ```

## Tips

- Read `wiki/index.md` first on every session to orient yourself
- Read only the tail of `wiki/log.md` (last 30–50 lines) to see recent days
- Never modify files in `raw/` — read only
- Prefer updating existing pages over creating new ones for minor additions
- Every new page must be added to `wiki/index.md`
- Cross-link liberally — the graph is the value
