---
title: "DOM-based XSS"
tags: [xss, dom, javascript, browser-security, injection]
sources: [owasp-dom-xss.md, owasp-html5-security.md]
updated: 2026-04-16
---

# DOM-based XSS

DOM-based Cross-Site Scripting (DOM XSS) is a **client-side injection vulnerability** where attacker-controlled data is used by JavaScript to modify the DOM in an unsafe way. Unlike Reflected and Stored XSS (server-side injection issues), DOM XSS occurs entirely in the browser — the server never sees the malicious payload.

## Key Distinction

| Type          | Where injected     | When it happens                 |
| ------------- | ------------------ | ------------------------------- |
| Reflected XSS | Server response    | Server-side request processing  |
| Stored XSS    | Server response    | Persistent storage, server-side |
| DOM XSS       | DOM via JavaScript | Client-side runtime in browser  |

## Sources (Input)

Common untrusted data sources:

- `location.hash`, `location.search`, `location.href`
- `document.referrer`
- `window.name`
- `postMessage` data
- Data from `localStorage`/`sessionStorage` if tainted

## Sinks (Dangerous Output Methods)

**Never pass untrusted data to these:**

| Sink                                      | Risk                        |
| ----------------------------------------- | --------------------------- |
| `element.innerHTML` / `outerHTML`         | Parses and executes HTML+JS |
| `document.write()` / `document.writeln()` | Executes HTML               |
| `element.setAttribute("onclick", ...)`    | Executes code string        |
| `setTimeout(str)` / `setInterval(str)`    | Evaluates string as JS      |
| `eval()` / `new Function(str)`            | Direct code execution       |
| CSS `url()`                               | Can execute `javascript:`   |

**Safe sinks:**

| Sink                                         | Why safe                          |
| -------------------------------------------- | --------------------------------- |
| `element.textContent`                        | Text only, no parsing             |
| `element.innerText`                          | Text only (except in `<script>`)  |
| `element.setAttribute(safe_attr, val)`       | Safe for non-event, non-URL attrs |
| `document.createElement()` + `appendChild()` | Structural DOM, no parsing        |

## Encoding Rules by Subcontext

Context-appropriate encoding is required — one-size-fits-all does NOT work:

| Subcontext                  | Required encoding                    |
| --------------------------- | ------------------------------------ |
| HTML subcontext (innerHTML) | HTML encode → JS encode              |
| HTML attribute (via JS)     | JS encode only                       |
| Event handler               | **Avoid — JS encoding insufficient** |
| CSS                         | URL encode → JS encode               |
| URL attribute               | URL encode → JS encode               |

## Detection

- **Manual:** Trace source → sink flows in JavaScript.
- **Automated:** Semgrep variant analysis, browser devtools.
- **Scanners:** DOM-based XSS-aware DAST tools.

## Mitigations

1. **Prefer safe sinks** — use `textContent` over `innerHTML`.
2. **Sanitize where unavoidable** — [DOMPurify](https://github.com/cure53/DOMPurify), [sanitize-html](https://github.com/apostrophecms/sanitize-html).
3. **Context-aware encoding** — OWASP ESAPI, OWASP Java Encoder.
4. **CSP** — blocks execution of injected scripts even if DOM XSS occurs.
5. **Avoid `eval()`** — treat as banned function; use `JSON.parse()` instead.
6. **Never place untrusted data in event handler attributes or JS code strings.**

## Related Pages

- [Input Validation](input-validation.md)
- [Content Security Policy](content-security-policy.md)
- [OWASP DOM XSS Prevention source](../sources/owasp-dom-xss.md)
