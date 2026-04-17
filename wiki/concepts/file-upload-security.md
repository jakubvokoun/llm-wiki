---
title: "File Upload Security"
tags: [file-upload, input-validation, security, web]
sources: [owasp-input-validation.md]
updated: 2026-04-16
---

# File Upload Security

Securing file upload features requires validation, safe storage, and controlled serving. Mistakes here lead to RCE, path traversal, CSRF, and malware hosting.

## Upload Verification

- Validate filename extension against an **allowlist** (not denylist)
- Enforce maximum file size
- For ZIP uploads: validate target path, compression ratio, and estimated unzipped size before extraction (zip bomb defense)

## Storage

- **Never use user-supplied filenames** for storage — generate a random name
- Store outside web root if possible
- Scan for malware (anti-malware, static analysis)
- Server defines file path; client never does

## Public Serving

- Set correct `Content-Type` header (e.g. `image/jpeg`) — don't reflect user-supplied type
- Serve from isolated domain/subdomain to prevent cross-site attacks

## Dangerous File Types to Block

| File                                        | Risk                                              |
| ------------------------------------------- | ------------------------------------------------- |
| `crossdomain.xml`, `clientaccesspolicy.xml` | Cross-domain data theft, CSRF (Flash/Silverlight) |
| `.htaccess`, `.htpasswd`                    | Server config override                            |
| `aspx, asp, jsp, php, cgi, js, pl`          | Server-side execution                             |

## Image Uploads

- Process images through an image rewriting library (strips steganographic payloads, metadata)
- Detect actual content type from processed image — don't trust the upload header
- Set stored extension based on detected type

## Related Pages

- [Input Validation](input-validation.md)
- [Supply Chain Security](supply-chain-security.md)
- [OWASP Input Validation Cheat Sheet](../sources/owasp-input-validation.md)
