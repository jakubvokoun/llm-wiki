---
title: "PHP Security"
tags: [php, security, configuration, session]
sources: [owasp-php-configuration.md]
updated: 2026-04-16
---

# PHP Security

Security hardening for PHP applications, focusing on `php.ini` configuration.

## Critical php.ini Settings

### Error Handling

- `expose_php = Off` — hides PHP version from `X-Powered-By` header.
- `display_errors = Off` — never show errors to users in production.
- `log_errors = On` — log to file outside web root instead.
- `zend.exception_ignore_args = On` — hides function arguments from exception traces.

### File Inclusion / RFI Prevention

- `allow_url_fopen = Off` — prevents PHP from opening remote URLs as files.
- `allow_url_include = Off` — prevents `include`/`require` from loading remote URLs.
- Together these prevent LFI (Local File Inclusion) attacks from escalating to RFI (Remote File Inclusion).
- `open_basedir` — confines PHP file access to the application directory.

### Dangerous Functions

Disable all unused functions:

```
disable_functions = system, exec, shell_exec, passthru, phpinfo, show_source,
  highlight_file, popen, proc_open, putenv, chmod, rename, posix_mkfifo, ...
```

### File Uploads

- `upload_tmp_dir` — store uploads outside the web root.
- `upload_max_filesize` and `max_file_uploads` — limit size and count.
- `file_uploads = Off` if the application doesn't use file uploads.

### Resource Limits (DoS Prevention)

- `memory_limit = 50M`
- `post_max_size = 20M`
- `max_execution_time = 60`

## Session Security

PHP session settings are among the most impactful security configurations:

| Setting                          | Value    | Reason                                    |
| -------------------------------- | -------- | ----------------------------------------- |
| `session.use_strict_mode`        | `1`      | Prevents session fixation attacks         |
| `session.use_only_cookies`       | `1`      | Prevents session IDs in URLs              |
| `session.cookie_secure`          | `1`      | HTTPS only                                |
| `session.cookie_httponly`        | `1`      | Blocks JavaScript access (XSS mitigation) |
| `session.cookie_samesite`        | `Strict` | CSRF protection                           |
| `session.sid_length`             | `256`    | High-entropy session IDs                  |
| `session.sid_bits_per_character` | `6`      | Maximum entropy per character             |
| `session.name`                   | custom   | Change from default `PHPSESSID`           |
| `session.cookie_lifetime`        | `14400`  | 4-hour max lifetime                       |

## Security Extensions

### Snuffleupagus

Modern security extension for PHP 7+, successor to Suhosin. Provides:

- Runtime function call restrictions.
- Cookie encryption.
- Custom virtual patching rules.
- Considered stable and production-ready.

## Related Pages

- [Input Validation](input-validation.md)
- [Authentication](authentication.md)
- [File Upload Security](file-upload-security.md)
- [OWASP PHP Configuration Cheat Sheet](../sources/owasp-php-configuration.md)
