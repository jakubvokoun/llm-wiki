# NodeJS Security Cheat Sheet

## Introduction

This cheat sheet lists actions developers can take to develop secure Node.js applications. Each item has a brief explanation and solution that is specific to the Node.js environment.

## Recommendations

Recommendations are categorized as:
- **Application Security**
- **Error & Exception Handling**
- **Server Security**
- **Platform Security**

### Application Security

#### Use flat Promise chains

Increasing layers of nesting within callback functions ("Pyramid of Doom" / "Callback Hell") can cause errors and results to get lost. Use flat Promise chains or async/await instead:

```javascript
func1("input1")
   .then(function (result){ return func2("input2"); })
   .then(function (result){ return func3("input3"); })
   .catch(function (error) { /* error operations */ });
```

Or with async/await:
```javascript
(async() => {
  try {
    let res1 = await func1("input1");
    let res2 = await func2("input2");
  } catch(err) { /* error operations */ }
})();
```

#### Set request size limits

Attackers can send requests with large request bodies that can exhaust server memory or fill disk space. Limit request body sizes:

```javascript
app.use(express.urlencoded({ extended: true, limit: "1kb" }));
app.use(express.json({ limit: "1kb" }));
```

Note: Attackers can change the `Content-Type` header to bypass limits — validate content type before processing.

#### Do not block the event loop

Node.js has a single-thread event-driven architecture. CPU intensive JavaScript operations block the event loop. All blocking operations should be done asynchronously. Also avoid race conditions where authenticated actions run synchronously while authentication is in a callback.

#### Perform input validation

Input validation failures can result in SQL Injection, XSS, Command Injection, Local/Remote File Inclusion, DoS, Directory Traversal, LDAP Injection, and many other injection attacks. Use modules like `validator` and `express-mongo-sanitize`.

Be aware that JavaScript URL parsing can produce different data types from the same parameter name (string, array, object, nested objects) — validate type as well as content.

#### Perform output escaping

Escape all HTML and JavaScript content shown to users to prevent XSS attacks. Use `escape-html` or `node-esapi` libraries.

#### Perform application activity logging

Use logging modules like Winston, Bunyan, or Pino. These modules enable streaming and querying logs and provide a way to handle uncaught exceptions. Logs are useful for security incident response and can feed IDS/IPS.

#### Monitor the event loop

Use `toobusy-js` to monitor the event loop. When response time goes beyond a threshold, send `503 Server Too Busy` to stay responsive under DoS conditions.

#### Take precautions against brute-forcing

Use modules like `express-bouncer`, `express-brute`, or `rate-limiter` to increase delays on failed requests and limit requests per IP. Use `svg-captcha` for CAPTCHA. Implement account lockout with `mongoose`.

#### Use Anti-CSRF tokens

CSRF attacks perform authorized actions on behalf of an authenticated user. The `csurf` package has been deprecated due to a security hole — use an alternative CSRF protection package.

#### Remove unnecessary routes

All unused API routes should be disabled. Frameworks like Sails and Feathers automatically generate REST API endpoints — remove or disable any unused ones to reduce attack surface.

#### Prevent HTTP Parameter Pollution

HTTP Parameter Pollution (HPP) attacks send multiple HTTP parameters with the same name. Use the `hpp` module:

```javascript
const hpp = require('hpp');
app.use(hpp());
```

#### Only return what is necessary

When querying and using user objects, return only needed fields to avoid personal information disclosure:

```javascript
exports.sanitizeUser = function(user) {
  return { id: user.id, username: user.username, fullName: user.fullName };
};
```

#### Use access control lists

Use the `acl` module to provide ACL (access control list) implementation. Create roles and assign users to these roles following the principle of least privilege.

### Permissions

Starting with Node.js v20, a Permission Model is available to restrict application privileges (stable as of v23.5.0):

```
node --permission [--allow-<type>=...] app.js
```

Examples:
```
node --permission --allow-fs-read=/uploads/ index.js
node --permission --allow-fs-write=/uploads/ index.js
```

Other flags: `--allow-child-process`, `--allow-worker`, `--allow-addons`, `--allow-wasi`

**Important:** Symbolic links are followed even if they point outside allowed paths — relative symlinks can bypass restrictions.

### Error & Exception Handling

#### Handle uncaughtException

Bind to the `uncaughtException` event to clean up resources before shutting down:

```javascript
process.on("uncaughtException", function(err) {
    // clean up allocated resources
    // log error details to log files (not to user)
    process.exit(); // exit to avoid unknown state
});
```

Do not reveal stack traces to users — show custom error messages only.

#### Listen to errors when using EventEmitter

If there are no attached listeners to an error event, the Error object is thrown and becomes an uncaught exception. Always listen to error events when using EventEmitter objects.

#### Handle errors in asynchronous calls

As a general principle, the first argument to asynchronous calls should be an Error object. Errors occurred in asynchronous calls made within express routes are not handled unless an Error object is sent as the first argument.

### Server Security

#### Set cookie flags appropriately

For session cookies, set these flags:
- `httpOnly` — prevents cookie access by client-side JavaScript (effective counter-measure for XSS).
- `Secure` — lets the cookie be sent only if the communication is over HTTPS.
- `SameSite` — prevents cookies from being sent in cross-site requests (protects against CSRF).

```javascript
app.use(session({
    secret: 'your-secret-key',
    cookie: { secure: true, httpOnly: true, path: '/user', sameSite: true}
}));
```

#### Use appropriate security headers

Use the `helmet` package to set HTTP security headers:

```javascript
const helmet = require("helmet");
app.use(helmet()); // Add various HTTP headers
```

`helmet` covers 14 middlewares including:
- `Strict-Transport-Security` (HSTS)
- `X-Frame-Options` (clickjacking prevention)
- `X-XSS-Protection` — set to `0` to disable the broken XSS Auditor; use CSP instead
- `Content-Security-Policy` — reduces XSS and Clickjacking risk
- `X-Content-Type-Options` — prevents MIME sniffing
- `Cache-Control` / `Pragma` — use `nocache` package for sensitive pages
- `X-Powered-By` — remove to prevent technology fingerprinting

### Platform Security

#### Keep your packages up-to-date

Using Components with Known Vulnerabilities is still in the OWASP Top 10. Use `npm audit` to warn about vulnerable packages and `npm audit fix` to upgrade affected packages. Also use OWASP Dependency-Check or Retire.js.

#### Do not use dangerous functions

Dangerous functions to avoid with user input:
- `eval()` — leads to remote code execution vulnerability
- `child_process.exec` — acts as a bash interpreter, allows arbitrary command execution
- `fs` module — improper sanitization can lead to file inclusion and directory traversal
- `vm` module — can perform dangerous actions, use only in a sandbox

#### Stay away from evil regexes

ReDoS (Regular expression Denial of Service) exploits regex implementations that reach extreme situations causing exponential slowdown. Generally caused by grouping with repetition and alternation with overlapping. Use `vuln-regex-detector` to check regexes.

#### Run security linters

Use SAST tools like ESLint and JSHint for JavaScript linting. Add custom rules for patterns you consider dangerous. Linting rules should be reviewed periodically.

#### Use strict mode

Enable strict mode in your application to remove unsafe legacy features and help JavaScript engines perform optimizations:

```javascript
"use strict";
```

#### Adhere to general application security principles

Refer to OWASP security by design principles and the OWASP Cheat Sheet Series for web application vulnerabilities and mitigation techniques.
