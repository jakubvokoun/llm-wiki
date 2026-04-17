---
title: "OWASP DOM based XSS Prevention Cheat Sheet"
tags: [owasp, xss, dom, javascript, browser-security]
sources: [owasp-dom-xss.md]
updated: 2026-04-16
---

# OWASP DOM based XSS Prevention Cheat Sheet

Source: OWASP Cheat Sheet Series — DOM based XSS Prevention

## Key Takeaways

DOM-based XSS is a **client-side injection issue** — the attack is injected into the application at runtime in the browser, not during server-side processing (which is how Reflected/Stored XSS work). This makes it harder to detect via server-side controls.

## Core Concept: Rendering Contexts

The browser parses HTML through different **rendering contexts**, each with distinct encoding requirements:

| Subcontext     | Where it appears                    | Required encoding                 |
| -------------- | ----------------------------------- | --------------------------------- |
| HTML           | `element.innerHTML`                 | HTML encode → JS encode           |
| HTML attribute | `element.setAttribute(attr, val)`   | JS encode only (in DOM context)   |
| Event handler  | `onclick=`, `setTimeout(str)`       | **Avoid untrusted data entirely** |
| CSS            | `element.style.x`                   | URL encode → JS encode            |
| URL            | `element.setAttribute("href", val)` | URL encode → JS encode            |

## 7 Rules

1. **HTML subcontext** (`innerHTML`, `outerHTML`, `document.write`): HTML encode then JavaScript encode.
2. **HTML attribute subcontext** (via JS, e.g. `setAttribute`): JavaScript encode only — do NOT HTML attribute encode (causes double encoding).
3. **Event handler / JS code subcontext**: Avoid placing untrusted data here. JS encoding does not reliably prevent execution in these contexts.
4. **CSS subcontext**: URL encode then JS encode.
5. **URL attribute subcontext**: URL encode then JS encode.
6. **Prefer safe sinks**: Use `textContent` (does not execute code) instead of `innerHTML`.
7. **Fix existing vulns**: Replace `innerHTML` with `textContent`/`innerText`. Never use `eval()` with user input.

## 10 Guidelines for Secure JS Development

1.  Treat untrusted data as displayable text only.
2.  Always JS encode and delimit untrusted data as quoted strings in templated JS.
3.  Build dynamic UI with `document.createElement()`, `element.setAttribute()`, `element.appendChild()` — not innerHTML.
4.  Avoid `innerHTML`, `outerHTML`, `document.write()`, `document.writeln()` with untrusted data.
5.  Avoid implicit `eval()` methods (`setTimeout(str)`, `setInterval(str)`, `new Function(str)`).
6.  Place untrusted data on the right side of expressions only.
7.  Be aware of character set issues when URL encoding in DOM.
8.  Limit object property access via `object[x]` — add indirection layer.
9.  Use JS sandboxes/sanitizers: [DOMPurify](https://github.com/cure53/DOMPurify), [js-xss](https://github.com/leizongmin/js-xss), [sanitize-html](https://github.com/apostrophecms/sanitize-html).
10. Use `JSON.parse()` — never `eval()` for JSON.

## Common Pitfalls

- **Encoding misconceptions**: HTML encoding does NOT protect inside `<script>` tags (`&#x61;lert(1)` executes). Also, encoding is lost when you read `.value` from a DOM element.
- **`innerText` is NOT always safe**: If applied to a `<script>` tag, it executes code.
- **Complex contexts**: Data can pass through multiple encoding contexts — track carefully.
- **Library inconsistencies**: ESAPI uses allowlist encoding; many others use denylists.
- **Detection**: Use Semgrep variant analysis to find dangerous source→sink flows (e.g. `location.hash` → `document.write`).

## Related Pages

- [DOM XSS concept](../concepts/dom-xss.md)
- [Input Validation](../concepts/input-validation.md)
- [Content Security Policy](../concepts/content-security-policy.md)
