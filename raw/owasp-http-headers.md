# HTTP Security Response Headers Cheat Sheet

## Introduction

HTTP Headers are a great booster for web security with easy implementation. Proper HTTP response headers help prevent Cross-Site Scripting, Clickjacking, Information disclosure, and more.

## Security Headers

### X-Frame-Options
Prevents the browser from rendering the page in a frame/iframe/embed/object, mitigating clickjacking.

**Recommendation:** Use CSP `frame-ancestors` if possible. Otherwise:
```
X-Frame-Options: DENY
```

### X-XSS-Protection
Legacy IE/Chrome/Safari feature that stops pages from loading when reflecting XSS. Can create XSS vulnerabilities in otherwise safe websites.

**Recommendation:** Disable it — use CSP instead:
```
X-XSS-Protection: 0
```

### X-Content-Type-Options
Prevents browsers from MIME-sniffing the Content-Type, blocking MIME confusion attacks.

**Recommendation:**
```
X-Content-Type-Options: nosniff
```

### Referrer-Policy
Controls how much referrer information is sent with requests.

**Recommendation:**
```
Referrer-Policy: strict-origin-when-cross-origin
```

### Content-Type
Prevents resources from being interpreted as HTML, enabling XSS.

**Recommendation:**
```
Content-Type: text/html; charset=UTF-8
```
(charset is necessary to prevent XSS in HTML pages)

### Cache-Control
Defines how responses are cached by browsers and intermediate caches.

**Recommendation:**
* Use `no-store` for sensitive data to strictly prevent caching.
* Use `private` to restrict to user-specific caches.
* Note: `no-cache` does NOT prevent caching — it requires revalidation before reuse.

### Set-Cookie
Not a security header per se, but security attributes are crucial. See Session Management Cheat Sheet.

### Strict-Transport-Security (HSTS)
Instructs browsers to only access the site using HTTPS.

**Recommendation:**
```
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```
Caution: misconfiguration or expired certs can block legitimate users.

### Expect-CT ❌
Deprecated. Mozilla recommends removing it from existing code.

### Content-Security-Policy (CSP)
Specifies allowed content origins. Prevents XSS and data injection. Not meaningful for REST APIs returning non-rendered content.

**Recommendation:** See Content Security Policy Cheat Sheet for configuration.

### Access-Control-Allow-Origin
CORS header. Without it, Same Origin Policy (SOP) protects by default.

**Recommendation:** Set specific origins instead of `*`:
```
Access-Control-Allow-Origin: https://yoursite.com
```

### Cross-Origin-Opener-Policy (COOP)
Ensures top-level document does not share browsing context group with cross-origin documents. Protects against Spectre-like attacks.

**Recommendation:**
```
Cross-Origin-Opener-Policy: same-origin
```

### Cross-Origin-Embedder-Policy (COEP)
Prevents document from loading cross-origin resources that don't explicitly grant permission.

**Recommendation:**
```
Cross-Origin-Embedder-Policy: require-corp
```

### Cross-Origin-Resource-Policy (CORP)
Controls which origins can include the resource.

**Recommendation:**
```
Cross-Origin-Resource-Policy: same-site
```

### Permissions-Policy (formerly Feature-Policy)
Controls which browser features can be used by which origins.

**Recommendation:** Disable features not needed:
```
Permissions-Policy: geolocation=(), camera=(), microphone=()
```

### FLoC (Federated Learning of Cohorts)
Google's interest-based advertising cohort mechanism. Privacy concerns raised by EFF, Mozilla.

**Recommendation:** Opt out:
```
Permissions-Policy: interest-cohort=()
```

### Server
Exposes server technology — useful to attackers.

**Recommendation:** Remove or set non-informative value:
```
Server: webserver
```

### X-Powered-By
Exposes tech stack. Remove all X-Powered-By headers.

### X-AspNet-Version / X-AspNetMvc-Version
Exposes .NET version. Disable in web.config / Global.asax.

### X-Robots-Tag
Controls crawler behavior for non-HTML resources.

**Recommendation:** For private/sensitive content: `noindex, nofollow`. For public content: `index, follow`.

### X-DNS-Prefetch-Control
Controls browser DNS prefetching.

**Recommendation:** Set `off` if you don't control links and want to avoid leaking to third-party domains.

### Public-Key-Pins (HPKP)
Deprecated — do not use.

### Secure File Download Headers
When serving user-provided files:
* `Content-Disposition: attachment` — force download, not inline rendering.
* `Content-Type: application/octet-stream` — for unknown/binary files.
* `X-Content-Type-Options: nosniff` — prevent MIME sniffing.

## Adding Headers in Different Technologies

| Platform | Example |
|----------|---------|
| PHP | `header("X-Frame-Options: DENY");` |
| Apache | `Header always set X-Frame-Options "DENY"` (unset first to avoid duplicates) |
| IIS | `<customHeaders>` in `Web.config` |
| HAProxy | `http-response set-header X-Frame-Options DENY` |
| Nginx | `add_header "X-Frame-Options" "DENY" always;` |
| Express | `helmet.frameguard({ action: "sameorigin" })` |

## Testing

* Mozilla Observatory — checks header status online.
* SmartScanner — scans whole site, not just homepage.
