---
title: "Wildcard Injection"
tags: [privilege-escalation, argument-injection, linux-hardening]
updated: 2026-05-01
---

# Wildcard Injection

## Summary

Wildcard (glob) injection is an **argument injection** technique where an attacker creates filenames beginning with `-` in a directory that a privileged process will later scan with an unquoted `*`. The shell expands `*` before the binary runs, so crafted filenames become command-line flags rather than file arguments — allowing arbitrary option injection into tools like `tar`, `rsync`, `zip`, `chown`, `chmod`, `7z`, and `tcpdump`.

## Core Mechanism

```
root runs:  tar -czf /backup/out.tgz *
shell sees: tar -czf /backup/out.tgz --checkpoint=1 --checkpoint-action=exec=sh shell.sh data.txt
```

The attacker creates files named `--checkpoint=1` and `--checkpoint-action=exec=sh shell.sh` in the writable directory before the job runs.

## High-Value Primitives

| Binary          | Injected flag                                   | Effect                             |
| --------------- | ----------------------------------------------- | ---------------------------------- |
| `tar` (GNU)     | `--checkpoint=1` + `--checkpoint-action=exec=X` | Arbitrary command execution        |
| `tar` (bsdtar)  | `--use-compress-program=/bin/sh`                | Arbitrary command execution        |
| `rsync`         | `-e sh shell.sh`                                | Remote-shell override → RCE        |
| `chown`/`chmod` | `--reference=/root/secret`                      | Copy ownership/permissions         |
| `7z`/`7za`      | `@listfile` (symlink to sensitive file)         | File content disclosure via stderr |
| `zip`           | `-T` + `-TT <cmd>` (separate tokens)            | Arbitrary command execution        |
| `tcpdump`       | `-G 1 -W 1 -z /path/script.sh`                  | Post-rotation command execution    |

## Key Distinction: `-- *` is Not Universal

Prefixing with `--` stops GNU option parsing for most tools. However:

- **`7z`/`7za`**: `@listfiles` are a separate mechanism processed after `--`; still exploitable
- **`zip`**: short-option splitting across multiple filenames still works with `-- *`

## Detection / Prevention

```bash
# Hunt for privileged scripts running globs on user-writable paths
rg -n '(tar|rsync|zip|7z|chown|chmod).*(\\*|\\$@)' /etc /opt /usr/local /srv 2>/dev/null

# Monitor real argv during cron/systemd
pspy64 -pf -i 1000 | rg 'tar|rsync|zip|7z|chown|chmod'
```

**Fixes:**

- Quote arguments: `tar -czf out.tgz -- "$@"` or iterate with `for f in *; do …`
- Run jobs in a directory only writable by root
- Use `find … -exec` instead of glob expansion in scripts

Tool: [`wildpwn`](https://github.com/localh0t/wildpwn) for combined PoC.

## Sources

- [HackTricks: Wildcards Spare Tricks](../sources/hacktricks-wildcards-spare-tricks.md)

## Related

- [linux-privilege-escalation](linux-privilege-escalation.md)
