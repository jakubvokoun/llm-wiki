---
title: "Browser Storage Security"
tags: [browser-storage, localstorage, sessionstorage, indexeddb, xss, cookies]
sources: [owasp-html5-security.md]
updated: 2026-04-16
---

# Browser Storage Security

Security considerations for client-side storage: localStorage, sessionStorage, and IndexedDB.

## Storage Types

| API                  | Scope         | Persistence      | JavaScript Accessible  |
| -------------------- | ------------- | ---------------- | ---------------------- |
| `localStorage`       | Origin        | Until cleared    | Yes                    |
| `sessionStorage`     | Tab/window    | Until tab closes | Yes                    |
| IndexedDB            | Origin        | Until cleared    | Yes                    |
| Cookies (`httpOnly`) | Origin + path | Configurable     | **No** (with httpOnly) |

## Core Rules

### Never store in localStorage/sessionStorage:

- **Session identifiers** — Use `httpOnly` cookies instead; localStorage is fully readable by any script
- **Sensitive credentials** — Passwords, tokens, private keys
- **PII** — Personal data that shouldn't be accessible to JS

### Never trust data from storage:

- XSS can **write** malicious data to storage
- Any data retrieved must be validated/sanitized before use
- Don't assume stored data matches what you put there

### Prefer sessionStorage over localStorage:

- `sessionStorage` is scoped to the tab/window and cleared on close
- Reduces window of exposure for transient data (e.g., form state)

## XSS and Storage

A single XSS vulnerability can:

1. **Exfiltrate** all localStorage/sessionStorage data
2. **Poison** storage with malicious values that trigger future attacks
3. **Steal session tokens** stored in localStorage

This is why `httpOnly` cookies are the correct mechanism for session tokens — JavaScript cannot read them even under XSS.

## Origin Isolation

All apps on the same origin share the same localStorage. If hosting multiple apps on `example.com`, all share storage. Mitigations:

- Use subdomains (`app1.example.com`, `app2.example.com`)
- Apply strict CSP to limit what scripts can execute

## IndexedDB

- Vulnerable to injection if queries aren't parameterized
- Also readable/writable by XSS — same trust model as localStorage
- Don't store sensitive data

## PII Input Handling

Prevent browser from autocaching sensitive form inputs:

```html
<input
  autocomplete="off"
  spellcheck="false"
  autocorrect="off"
  autocapitalize="off"
/>
```

Apply to: password, username, credit card, address, phone, SSN fields.

## Related Concepts

- [dom-xss](dom-xss.md)
- [content-security-policy](content-security-policy.md)
- [authentication](authentication.md)

## Sources

- [OWASP HTML5 Security Cheat Sheet](../sources/owasp-html5-security.md)
