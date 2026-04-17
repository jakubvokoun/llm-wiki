# PHP Configuration Cheat Sheet

## Introduction

This page covers configuring PHP and the web server it is running on to be very secure, including `php.ini` settings for Apache, Nginx, and Caddy.

## PHP Configuration and Deployment

### php.ini

#### PHP error handling

```
expose_php              = Off
error_reporting         = E_ALL
display_errors          = Off
display_startup_errors  = Off
log_errors              = On
error_log               = /valid_path/PHP-logs/php_error.log
ignore_repeated_errors  = Off
```

Keep `display_errors` to `Off` on a production server. Log errors to a file, never display them.

#### PHP general settings

```
doc_root                = /path/DocumentRoot/PHP-scripts/
open_basedir            = /path/DocumentRoot/PHP-scripts/
include_path            = /path/PHP-pear/
extension_dir           = /path/PHP-extensions/
mime_magic.magicfile    = /path/PHP-magic.mime
allow_url_fopen         = Off
allow_url_include       = Off
variables_order         = "GPCS"
allow_webdav_methods    = Off
session.gc_maxlifetime  = 600
```

`allow_url_fopen = Off` and `allow_url_include = Off` prevent LFIs from being easily escalated to RFIs (Remote File Inclusions).

#### PHP file upload handling

```
file_uploads            = On
upload_tmp_dir          = /path/PHP-uploads/
upload_max_filesize     = 2M
max_file_uploads        = 2
```

If the application does not use file uploads, set `file_uploads = Off`.

#### PHP executable handling

```
enable_dl               = Off
disable_functions       = system, exec, shell_exec, passthru, phpinfo, show_source, highlight_file, popen, proc_open, fopen_with_path, dbmopen, dbase_open, putenv, move_uploaded_file, chdir, mkdir, rmdir, chmod, rename, filepro, filepro_rowcount, filepro_retrieve, posix_mkfifo
disable_classes         =
```

Disable all dangerous PHP functions that you don't use.

#### PHP session handling

Session settings are among the MOST important values to configure. Change `session.name` to something custom.

```
session.save_path                = /path/PHP-session/
session.name                     = myPHPSESSID
session.auto_start               = Off
session.use_trans_sid            = 0
session.cookie_domain            = full.qualified.domain.name
session.use_strict_mode          = 1
session.use_cookies              = 1
session.use_only_cookies         = 1
session.cookie_lifetime          = 14400 # 4 hours
session.cookie_secure            = 1
session.cookie_httponly          = 1
session.cookie_samesite          = Strict
session.cache_expire             = 30
session.sid_length               = 256
session.sid_bits_per_character   = 6
```

#### Some more security paranoid checks

```
session.referer_check   = /application/path
memory_limit            = 50M
post_max_size           = 20M
max_execution_time      = 60
report_memleaks         = On
html_errors             = Off
zend.exception_ignore_args = On
```

### Snuffleupagus

[Snuffleupagus](https://snuffleupagus.readthedocs.io) is the spiritual descendant of Suhosin for PHP 7 and onwards, with modern features. It's considered stable and usable in production.
