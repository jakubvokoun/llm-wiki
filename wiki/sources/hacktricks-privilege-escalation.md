---
title: "HackTricks — Linux Privilege Escalation"
tags: [linux, privilege-escalation, pentest, security, enumeration]
sources: [hacktricks-privilege-escalation.md]
updated: 2026-05-01
---

# HackTricks — Linux Privilege Escalation

Comprehensive Linux privilege escalation reference from HackTricks. Covers enumeration methodology and exploitation of every major Linux privesc vector, aimed at pentesters and CTF practitioners.

## Enumeration Methodology

Always enumerate before exploiting:

```bash
# OS and kernel
(cat /proc/version || uname -a) 2>/dev/null
cat /etc/os-release

# Kernel exploit candidates
uname -r
searchsploit "Linux Kernel"

# PATH hijacking
echo $PATH

# Env variables (secrets)
(env || set) 2>/dev/null
```

Tools: `linux-exploit-suggester.sh`, `linux-exploit-suggester2.pl`, `linuxprivchecker.py`.

## Enumerate Defenses

Check what protections are active before attempting exploits:

```bash
# AppArmor
aa-status 2>/dev/null

# SELinux
sestatus 2>/dev/null

# ASLR (0 = disabled)
cat /proc/sys/kernel/randomize_va_space

# Grsecurity
uname -r | grep "\-grsec"
```

## Key Exploit Vectors

### Kernel CVEs

- **CVE-2016-5195 (DirtyCow)** — race condition in copy-on-write; affects kernel ≤ 3.19.0-73.8
- Multiple other compiled exploits available at `github.com/lucyoa/kernel-exploits`

### Sudo Vulnerabilities

**CVE-2025-32463** (sudo < 1.9.17p1): `--chroot` option allows privilege escalation when `/etc/nsswitch.conf` is user-controlled.

**CVE-2025-32462** (sudo 1.8.8–1.9.17): host-based sudoers rules evaluate attacker-supplied hostname via `sudo -h <host>`, allowing privilege spoofing.

**sudo < 1.8.28**: `sudo -u#-1 /bin/bash` escalates to root.

### Sudo Misconfigurations

`sudo -l` is the primary enumeration command:

- `NOPASSWD` entries
- Shell-escapable commands (vim, python, awk, find, etc.)
- Wildcard paths in allowed commands

### SUID/SGID Binaries

```bash
find / -perm -4000 -type f 2>/dev/null   # SUID
find / -perm -2000 -type f 2>/dev/null   # SGID
```

Cross-reference with GTFOBins for known shell escapes.

### Linux Capabilities

```bash
getcap -r / 2>/dev/null
```

Dangerous capabilities without SUID: `CAP_SETUID`, `CAP_SYS_ADMIN`, `CAP_DAC_OVERRIDE`. See [HackTricks Linux Capabilities](hacktricks-linux-capabilities.md).

### PATH Hijacking

If a root-owned process calls relative binaries and an attacker can write to an earlier `$PATH` directory, arbitrary code runs as root.

### Writable Cron Scripts

Root crontabs calling world-writable scripts. Check `/etc/cron*`, `/var/spool/cron/`, crontab entries.

### Drives and Credentials

```bash
cat /etc/fstab | grep -v "^#"
grep -E "(user|pass|password|pw)[=:]" /etc/fstab /etc/mtab
```

Unmounted drives may contain credentials or sensitive data.

### Process and Software Enumeration

```bash
ps aux                    # running processes, check for root-run services
dpkg -l / rpm -qa         # installed package versions (check for CVEs)
which docker lxc kubectl  # container tooling present?
```

### Container Breakout

If inside a container, pivot to container-specific vectors. See [Container Security](hacktricks-container-security.md).

## Key Takeaways

- Enumeration order: kernel → sudo → SUID → capabilities → cron → writable files → credentials
- `sudo -l` is almost always the fastest path when misconfigured
- Kernel CVE tools (`linux-exploit-suggester`) automate version-to-exploit matching
- Container presence changes the attack surface significantly — check for Docker socket, host mounts, capabilities

## Related Pages

- [Linux Privilege Escalation](../concepts/linux-privilege-escalation.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
- [HackTricks Linux Basics](hacktricks-linux-basics.md)
- [HackTricks Linux Capabilities](hacktricks-linux-capabilities.md)
- [HackTricks Container Security](hacktricks-container-security.md)
- [HackTricks](../entities/hacktricks.md)
