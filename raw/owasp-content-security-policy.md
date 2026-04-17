# Content Security Policy Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html

## Introduction

This article brings forth a way to integrate the **defense in depth** concept to the client-side of web applications. By injecting the Content-Security-Policy (CSP) headers from the server, the browser is aware and capable of protecting the user from dynamic calls that will load content into the page currently being visited.

## Context

The increase in XSS (Cross-Site Scripting), clickjacking, and cross-site leak vulnerabilities demands a more **defense in depth** security approach.

### Defense against XSS

CSP defends against XSS attacks in the following ways:

1. **Restricting Inline Scripts** — prevents execution of injected `<script>` tags
2. **Restricting Remote Scripts** — prevents loading scripts from arbitrary servers (e.g., `<script src="https://evil.com/hacked.js">`)
3. **Restricting Unsafe JavaScript** — prevents text-to-JavaScript functions like `eval`
4. **Restricting Form submissions** — restricts where HTML forms can submit their data
5. **Restricting Objects** — restricts the HTML `object` tag, preventing injected Flash/Java/legacy executables

### Defense against Framing Attacks

Attacks like clickjacking and some browser side-channel attacks (xs-leaks) require a malicious website to load the target website in a frame. The `frame-ancestors` CSP directive replaces the deprecated `X-Frame-Options` header.

### Defense in Depth

A strong CSP provides an effective **second layer** of protection against various types of vulnerabilities, especially XSS. CSP **should not** be relied upon as the only defensive mechanism against XSS — it must be combined with good development practices.

## Policy Delivery

### 1. Content-Security-Policy Header (preferred)

```
Content-Security-Policy: ...
```

Using a header is the preferred way and supports the full CSP feature set. Send it in all HTTP responses.

### 2. Content-Security-Policy-Report-Only Header

```
Content-Security-Policy-Report-Only: ...
```

Delivers a CSP that doesn't get enforced but sends violation reports. Useful as a precursor to utilizing CSP in blocking mode. Both headers can be used together.

### 3. Content-Security-Policy Meta Tag

```html
<meta http-equiv="Content-Security-Policy" content="...">
```

Useful when CSP headers are out of your control (e.g., CDN-hosted files). However, framing protections, sandboxing, and CSP violation logging endpoint are not supported.

**WARNING:** Do NOT use `X-Content-Security-Policy` or `X-WebKit-CSP`. Their implementations are obsolete.

## CSP Types

Two approaches exist:
* **Granular/allowlist-based** — creates allow-lists defining permitted content sources. Original mechanism, complex to maintain.
* **Strict CSP** — the modern leading practice. Easier to deploy and more secure.

## Strict CSP

A strict CSP uses a limited number of fetch directives combined with one of:
* **Nonce based** — unique one-time-use random values generated per HTTP response
* **Hash based** — SHA hash of specific inline scripts

The `strict-dynamic` directive can optionally be used to make implementation easier.

### Nonce Based

```javascript
const nonce = uuid.v4();
scriptSrc += ` 'nonce-${nonce}'`;
```

```html
<script nonce="<%= nonce %>">
    ...
</script>
```

**Warning:** Don't create a middleware that replaces all script tags with "script nonce=..." because attacker-injected scripts will then get the nonces as well. You need an actual HTML templating engine to use nonces.

### Hashes

```
Content-Security-Policy: script-src 'sha256-V2kaaafImTjn8RQTWZmF4IfGfQ7Qsqsw9GWaFjzFNPg='
```

Note: Using hashes can be risky — if you change anything inside the script tag (even whitespace), the hash will be different and the script won't render.

### strict-dynamic

The `strict-dynamic` directive tells the browser to trust DOM elements created by already-trusted scripts (with correct hash or nonce) without having to explicitly add nonces or hashes for each one.

## Detailed CSP Directives

### Fetch Directives

Fetch directives tell the browser the locations to trust and load resources from.

* `default-src` — fallback directive for other fetch directives
* `script-src` — specifies locations from which scripts can be executed
  + `script-src-elem` — controls script requests and blocks
  + `script-src-attr` — controls event handlers
* `style-src` — controls styles applied to a document
* `img-src` — specifies URLs that images can be loaded from
* `connect-src` — controls fetch requests, XHR, eventsource, beacon and websockets
* `font-src` — specifies URLs to load fonts from
* `object-src` — specifies URLs from which plugins can be loaded
* `media-src` — specifies URLs for video, audio and text track resources
* `child-src` — controls nested browsing contexts and worker execution contexts
* `manifest-src` — specifies URLs for application manifests

### Document Directives

* `base-uri` — specifies possible URLs the `<base>` element can use
* `sandbox` — restricts a page's actions such as submitting forms

### Navigation Directives

* `form-action` — restricts the URLs which forms can submit to
* `frame-ancestors` — restricts URLs that can embed the requested resource; obsoletes `X-Frame-Options`

### Reporting Directives

* `report-to` — group name defined in header as JSON formatted header value
* `report-uri` — (deprecated by `report-to`) URI that reports are sent to

Use both in conjunction for backward compatibility:
```
Content-Security-Policy: ...; report-uri https://example.com/csp-reports; report-to csp-endpoint
```

### Special Directive Sources

| Value | Description |
| --- | --- |
| `'none'` | No URLs match. |
| `'self'` | Refers to the origin site with the same scheme and port number. |
| `'unsafe-inline'` | Allows the usage of inline scripts or styles. |
| `'unsafe-eval'` | Allows the usage of eval in scripts. |

## CSP Sample Policies

### Nonce-based Strict Policy

```
Content-Security-Policy:
  script-src 'nonce-{RANDOM}' 'strict-dynamic';
  object-src 'none';
  base-uri 'none';
```

### Hash-based Strict Policy

```
Content-Security-Policy:
  script-src 'sha256-{HASHED_INLINE_SCRIPT}' 'strict-dynamic';
  object-src 'none';
  base-uri 'none';
```

### Basic non-Strict CSP Policy

```
Content-Security-Policy: default-src 'self'; frame-ancestors 'self'; form-action 'self';
```

Tighter version:
```
Content-Security-Policy: default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self'; frame-ancestors 'self'; form-action 'self';
```

### Upgrading Insecure Requests

```
Content-Security-Policy: upgrade-insecure-requests;
```

### Preventing Framing Attacks

```
Content-Security-Policy: frame-ancestors 'none';          # prevent all framing
Content-Security-Policy: frame-ancestors 'self';          # allow site itself
Content-Security-Policy: frame-ancestors trusted.com;     # allow trusted domain
```

### Refactoring Inline Code

When `default-src` or `script-src*` directives are active, CSP disables inline JavaScript. Move inline code to a separate JavaScript file. Replace inline event handlers like `onclick="doSomething()"` with `addEventListener` calls.

## References

* Strict CSP: https://web.dev/strict-csp
* CSP Level 3 W3C specification
* MDN CSP documentation
* CSP evaluator: https://csp-evaluator.withgoogle.com/
