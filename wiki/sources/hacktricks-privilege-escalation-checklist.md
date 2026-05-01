---
title: "HackTricks: Linux Privilege Escalation Checklist"
tags: [linux-hardening, privilege-escalation, checklist]
sources: [hacktricks-privilege-escalation-checklist.md]
updated: 2026-05-01
---

# HackTricks: Linux Privilege Escalation Checklist

Source: [hacktricks-privilege-escalation-checklist.md](../../raw/hacktricks-privilege-escalation-checklist.md)

## Key Takeaways

Structured checklist for Linux local privilege escalation. Best automated tool: **LinPEAS**. Work through categories systematically rather than jumping to exploits.

## System Information

- OS version, kernel exploits (DirtyCow, etc.)
- `sudo` version vulnerable?
- PATH writable folders
- Env variables with sensitive data
- `dmesg` signature verification failures

## Drives

- Mounted/unmounted drives
- Credentials in `/etc/fstab`

## Processes & Services

- Unknown or overprivileged processes running
- Exploits for specific running process versions
- Writable binaries of running processes
- Writable `.service` files, writable systemd PATH
- **Writable systemd unit drop-ins** in `/etc/systemd/system/<unit>.d/*.conf` (override `ExecStart`/`User`)

## Scheduled Jobs

- PATH modified by cron + writable folder
- Wildcard injection in cron jobs
- Modifiable scripts executed by cron
- Frequently executing scripts (every 1–5 min)

## SUDO and SUID

- `sudo -l` — GTFOBins for anything usable
- **sudoedit CVE-2023-22809** (sudo < 1.9.12p2): `SUDO_EDITOR="vim -- /etc/sudoers" sudoedit /etc/hosts`
- Exploitable SUID binaries (GTFOBins)
- SUID binary without path → PATH hijack
- `LD_PRELOAD` abuse
- Missing `.so` library in SUID binary from writable folder
- SUDO tokens
- Writable `/etc/ld.so.conf.d/`

## Capabilities

- Unexpected capabilities on binaries (`getcap -r / 2>/dev/null`)

## Users & Network

- Large UID vulnerabilities
- Group-based privilege escalation
- Clipboard data
- Open ports not accessible before shell
- Traffic sniffing with `tcpdump`

## SSH

- Debian OpenSSL predictable PRNG (CVE-2008-0166)
- Interesting SSH config values
- SSH agent forwarding sockets

## Interesting Files

- Profile files (`~/.bashrc`, `~/.bash_profile`)
- `/etc/passwd`, `/etc/shadow` readable/writable
- Recently modified files
- Hidden files, SQLite DBs
- Backup files
- Web files with passwords
- LinPEAS + LaZagne for credential search

## Writable Files

- Python library modification for arbitrary execution
- Log files (Logtotten exploit)
- `/etc/sysconfig/network-scripts/` (CentOS/RHEL)
- `init.d`, `systemd`, `rc.d` files

## Other

- NFS `no_root_squash` abuse
- Restricted shell escape
- Screen/tmux open sessions
- D-Bus interfaces communicable

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [linux-capabilities](../concepts/linux-capabilities.md)
- [HackTricks: Linux Privilege Escalation](hacktricks-privilege-escalation.md)
- [HackTricks: D-Bus Enumeration](hacktricks-dbus-enumeration.md)
- [HackTricks](../entities/hacktricks.md)
