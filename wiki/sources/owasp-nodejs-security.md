---
title: "OWASP Node.js Security Cheat Sheet"
tags: [owasp, nodejs, security, javascript]
sources: [owasp-nodejs-security.md]
updated: 2026-04-16
---

# OWASP Node.js Security Cheat Sheet

## Summary

Node.js-specific security practices across four categories: application security (event loop, input validation, CSRF, brute-force, HPP), Node.js Permission Model (v20+), error/exception handling, server security (cookies, helmet headers), and platform security (dangerous functions, ReDoS, SAST tools, strict mode).

## Key Takeaways

### Application Security

**Event Loop**

- All blocking operations must be async — CPU-intensive synchronous code blocks the entire server.
- Avoid race conditions where authenticated actions run synchronously but authentication is in a callback.

**Request Size Limits**

- Set per-content-type limits: `express.json({ limit: "1kb" })`.
- Validate `Content-Type` header — attackers can change it to bypass limits.

**Input Validation**

- Express URL parsing can produce string, array, or object from the same parameter name — validate types.
- Use `validator`, `express-mongo-sanitize` modules.

**Output Escaping**

- Use `escape-html` or `node-esapi` to prevent XSS.

**Brute Force Protection**

- Modules: `express-bouncer`, `express-brute`, `rate-limiter`.
- Also: `svg-captcha` for CAPTCHA, mongoose account lockout.

**CSRF**

- `csurf` is deprecated (security hole, unpatched) — use an alternative.

**HTTP Parameter Pollution (HPP)**

- Use `hpp` module: `app.use(hpp())` — discards all but the last value for duplicate parameters.

**API Response Minimization**

- Only return fields needed for the operation — avoid exposing full user objects.

**Access Control**

- Use `acl` module for ACL implementation with roles.

### Node.js Permission Model (v20+, stable in v23.5.0)

Restrict application privileges with `--permission` flag:

- `--allow-fs-read=<path>` — prevent Local File Inclusion (LFI)
- `--allow-fs-write=<path>`
- `--allow-child-process`, `--allow-worker`, `--allow-addons`, `--allow-wasi`

**Warning**: Symbolic links are followed even outside allowed paths — relative symlinks can bypass restrictions.

### Error & Exception Handling

- `process.on("uncaughtException", ...)` — clean up resources, log (not to user), then `process.exit()`.
- Always listen to `error` events on EventEmitter objects.
- First argument of async callbacks should be an Error object.
- Never show stack traces to users — only custom error messages.

### Server Security

**Cookie Flags**

- `httpOnly: true` — blocks client-side JS access (XSS mitigation).
- `secure: true` — HTTPS only.
- `sameSite: true` — CSRF mitigation.

**Helmet Headers**

- Use `app.use(helmet())` which wraps 14 security header middlewares.
- Key headers: HSTS, X-Frame-Options (clickjacking), CSP (XSS), X-Content-Type-Options (MIME sniffing), `X-Powered-By` removal.
- `X-XSS-Protection` should be set to `0` (disabled) — the browser's built-in XSS Auditor is broken; use CSP instead.
- Use `nocache` package for sensitive pages.

### Platform Security

**Dangerous Functions** (avoid with user input):

- `eval()` — leads to remote code execution.
- `child_process.exec` — arbitrary command execution on server.
- `fs` module — file inclusion/traversal if unsanitized input.
- `vm` module — use only in sandboxed context.

**ReDoS (Regex Denial of Service)**

- Evil regexes with grouping/repetition and alternating patterns can cause exponential slowdown.
- Use `vuln-regex-detector` to audit regexes.
- See [ReDoS](../concepts/redos.md).

**SAST / Linting**

- Use ESLint and JSHint with security rule sets.
- Add custom rules for project-specific dangerous patterns.

**Strict Mode**

- Always add `"use strict";` at the top of Node.js files.
- Catches undeclared variables and other silent errors; enables engine optimizations.

## Related Pages

- [Node.js Security](../concepts/nodejs-security.md)
- [ReDoS](../concepts/redos.md)
- [Input Validation](../concepts/input-validation.md)
- [Content Security Policy](../concepts/content-security-policy.md)
- [HTTP Security Headers](../concepts/http-security-headers.md)
- [Authentication](../concepts/authentication.md)
- [OWASP](../entities/owasp.md)
