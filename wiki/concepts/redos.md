---
title: "ReDoS (Regular Expression Denial of Service)"
tags: [security, dos, regex, nodejs, javascript]
sources: [owasp-nodejs-security.md]
updated: 2026-04-16
---

# ReDoS — Regular Expression Denial of Service

A Denial of Service attack that exploits backtracking behavior in regex engines, causing them to take exponential time for specially crafted inputs.

## How It Works

Most regex engines (including JavaScript's built-in engine) use backtracking. Certain regex patterns cause the engine to explore an exponential number of paths when faced with a crafted input that almost-but-not-quite matches:

**Vulnerable pattern example:**

```
^(([a-z])+.)+[A-Z]([a-z])+$
```

**Attack input:** `aaaa...aaaaAaaaaa...aaaa` (long string that fails to match)

The engine backtracks exponentially through all permutations of how the grouped repetitions could match, hanging the process.

## What Makes a Regex "Evil"

- **Grouping with repetition**: `(X+)+` or `(X|Y)+`
- **Alternation with overlapping**: `(a|a)+`
- **Nested quantifiers**: `(a+)+`

## Impact on Node.js

Node.js runs on a single-threaded event loop. A blocking ReDoS attack on a single regex call:

- Blocks the entire event loop.
- Makes the server completely unresponsive to all other requests.
- Effectively a single-request DoS.

## Detection Tools

- `vuln-regex-detector` — static analysis for vulnerable regex patterns.
- `safe-regex` npm package — detects catastrophic backtracking.
- Online tools: regex101.com, regexploit.

## Mitigations

1. **Avoid complex regexes** with nested quantifiers or alternation with overlap.
2. **Use a regex auditing tool** (`vuln-regex-detector`) in CI.
3. **Set timeouts** on regex execution where possible.
4. **Use non-backtracking regex engines** (RE2, available via `re2` npm package):
   ```javascript
   const RE2 = require("re2");
   const re = new RE2("^(([a-z])+.)+[A-Z]([a-z])+$");
   ```
5. **Input length limits** — bound the size of input passed to complex regexes.

## Related Pages

- [Node.js Security](nodejs-security.md)
- [Input Validation](input-validation.md)
- [OWASP Node.js Security Cheat Sheet](../sources/owasp-nodejs-security.md)
