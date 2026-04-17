---
title: "Node.js Security"
tags: [nodejs, javascript, security, docker, express]
sources: [owasp-nodejs-security.md, owasp-nodejs-docker.md]
updated: 2026-04-16
---

# Node.js Security

Security practices specific to the Node.js runtime and ecosystem, covering application code, containerization, signal handling, and platform-level protections.

## Event Loop Security

Node.js is single-threaded with an event-loop architecture. Security implications:

- **Do not block the event loop** — CPU-intensive synchronous code prevents all requests from being served (effectively a self-inflicted DoS).
- **Race condition risk** — if authentication runs in a callback but authenticated actions run synchronously after, the order is not guaranteed.
- Use flat Promise chains or `async/await` to avoid callback pyramid and ensure correct execution order.

## Input and Output

- **Request size limits** — set per-content-type limits (`express.json({ limit: "1kb" })`); validate `Content-Type` header since attackers can change it.
- **Input validation** — Express URL parsing produces different types (string/array/object) from the same parameter name; validate types. Use `validator`, `express-mongo-sanitize`.
- **Output escaping** — use `escape-html` or `node-esapi` to prevent XSS in rendered output.
- **Return minimization** — only return fields needed for the operation; never expose full user objects.

## Brute Force / Rate Limiting

- Modules: `express-bouncer`, `express-brute` (increasing delays on failure), `rate-limiter` (IP-based rate limiting).
- CAPTCHA: `svg-captcha`.
- Account lockout: `mongoose` with max login attempts.
- Event loop monitoring: `toobusy-js` returns 503 when server is overloaded.

## HTTP Parameter Pollution

HPP attacks send duplicate parameter names to cause unpredictable behavior:

```javascript
const hpp = require("hpp");
app.use(hpp()); // discards all but last value for duplicate params
```

## Cookies

For session cookies, always set:

- `httpOnly: true` — blocks client-side JS (XSS mitigation).
- `secure: true` — HTTPS only.
- `sameSite: true` — CSRF mitigation.

## Security Headers (Helmet)

```javascript
const helmet = require("helmet");
app.use(helmet());
```

Key headers set by helmet:

- HSTS — force HTTPS.
- `X-Frame-Options` — clickjacking prevention.
- CSP — XSS and clickjacking defense.
- `X-Content-Type-Options: nosniff` — MIME sniffing prevention.
- **Disable** `X-XSS-Protection` (set to `0`) — the browser's XSS Auditor is broken and causes issues; rely on CSP instead.
- Remove `X-Powered-By` — prevents technology fingerprinting.

## Error Handling

- Handle `uncaughtException`: clean up, log internally (not to user), then `process.exit()`.
- Always listen to `error` events on EventEmitter objects.
- First argument of async callbacks should be `Error`.
- Never expose stack traces to users.

## Dangerous Functions

Avoid with user input:
| Function | Risk |
|----------|------|
| `eval()` | Remote code execution |
| `child_process.exec` | Arbitrary command execution |
| `fs` module (unsanitized input) | File inclusion, path traversal |
| `vm` module (unsandboxed) | Dangerous code execution |

## ReDoS

See [ReDoS](redos.md). Use `vuln-regex-detector` to audit regexes in Node.js code.

## Node.js Permission Model (v20+)

Stable as of v23.5.0. Restrict application capabilities with `--permission` flag:

```
node --permission --allow-fs-read=/uploads/ index.js
```

Flags: `--allow-fs-read`, `--allow-fs-write`, `--allow-child-process`, `--allow-worker`, `--allow-addons`, `--allow-wasi`.

**Caveat**: Symbolic links are followed even outside allowed paths.

## Strict Mode

Always add `"use strict";` — catches silent errors (undeclared variables, etc.) and enables engine optimizations.

## Docker-Specific Practices

See also [Container Security](container-security.md). Node.js-specific concerns:

- Use `node:lts-alpine` with pinned SHA256 digest (not `node:latest`).
- Use `dumb-init` as PID 1 init process — Node.js as PID 1 doesn't handle SIGTERM properly.
- `npm` client doesn't forward OS signals to the node process — use `CMD ["dumb-init", "node", "server.js"]`.
- Set `ENV NODE_ENV production` — triggers performance/security optimizations in Express and other frameworks.
- `COPY --chown=node:node` + `USER node` for non-root execution.
- Use multi-stage builds to prevent `NPM_TOKEN` leaking into image history.
- Use Docker build secrets (`--mount=type=secret`) for `.npmrc`.

## Platform Security

- `npm audit` for dependency vulnerability scanning.
- ESLint + JSHint with security rules for SAST.
- OWASP Dependency-Check or Retire.js for known vulnerable libraries.

## Related Pages

- [NPM Security](npm-security.md)
- [Container Security](container-security.md)
- [ReDoS](redos.md)
- [Input Validation](input-validation.md)
- [Content Security Policy](content-security-policy.md)
- [HTTP Security Headers](http-security-headers.md)
- [OWASP Node.js Security Cheat Sheet](../sources/owasp-nodejs-security.md)
- [OWASP Node.js Docker Cheat Sheet](../sources/owasp-nodejs-docker.md)
