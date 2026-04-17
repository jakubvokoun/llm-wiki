---
title: "OWASP PHP Configuration Cheat Sheet"
tags: [owasp, php, security, configuration]
sources: [owasp-php-configuration.md]
updated: 2026-04-16
---

# OWASP PHP Configuration Cheat Sheet

## Summary

Secure `php.ini` configuration covering error handling, general settings (disable URL includes), file uploads, dangerous function disabling, and session hardening. Also mentions Snuffleupagus as a modern security extension.

## Key Takeaways

### Error Handling

- `expose_php = Off` — prevents PHP version leakage in response headers.
- `display_errors = Off` — never show errors to users in production; log instead.
- `display_startup_errors = Off`
- `log_errors = On` to a file outside web root.

### General Settings

- `allow_url_fopen = Off` and `allow_url_include = Off` — prevents LFI from escalating to RFI.
- `open_basedir` — restricts PHP file access to application directory.
- `session.gc_maxlifetime = 600` — short session lifetime.

### File Upload Handling

- Set `upload_tmp_dir` to a directory outside web root.
- `upload_max_filesize = 2M` and `max_file_uploads = 2` (tune to app needs).
- If app doesn't use file uploads: `file_uploads = Off`.

### Dangerous Functions to Disable

`system`, `exec`, `shell_exec`, `passthru`, `phpinfo`, `show_source`, `highlight_file`, `popen`, `proc_open`, `putenv`, `chmod`, `rename`, `posix_mkfifo`, and others. Disable any not used.

### Session Security

Critical settings:

- `session.use_strict_mode = 1` — prevents session fixation.
- `session.use_only_cookies = 1` — prevents session IDs in URLs.
- `session.cookie_secure = 1` — HTTPS only.
- `session.cookie_httponly = 1` — no JS access.
- `session.cookie_samesite = Strict` — CSRF protection.
- `session.sid_length = 256` with `session.sid_bits_per_character = 6` — high-entropy session IDs.
- `session.cookie_lifetime = 14400` (4 hours).
- Change default `session.name` from `PHPSESSID`.

### Additional Hardening

- `zend.exception_ignore_args = On` — hides function arguments in exception traces (prevents info leakage).
- `html_errors = Off` — disables HTML in error messages.
- `memory_limit = 50M`, `post_max_size = 20M`, `max_execution_time = 60` — resource limits to prevent DoS.

### Snuffleupagus

A PHP security extension (spiritual successor to Suhosin) for PHP 7+. Provides modern features including runtime protection rules, function call restriction, and cookie encryption. Considered stable and production-ready.

## Related Pages

- [PHP Security](../concepts/php-security.md)
- [Input Validation](../concepts/input-validation.md)
- [Authentication](../concepts/authentication.md)
- [OWASP](../entities/owasp.md)
