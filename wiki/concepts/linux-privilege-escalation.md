---
title: "Linux Privilege Escalation"
tags: [linux, security, privilege-escalation, pentest, hardening]
sources:
  [
    hacktricks-electron-cef-chromium-debugger-abuse.md,
    hacktricks-escaping-limited-bash.md,
    hacktricks-euid-ruid-suid.md,
    hacktricks-interesting-groups-linux-pe.md,
    hacktricks-linux-basics.md,
    hacktricks-nfs-no-root-squash.md,
    hacktricks-privilege-escalation.md,
    hacktricks-socket-command-injection.md,
    hacktricks-ssh-forward-agent.md,
  ]
updated: 2026-05-01
---

# Linux Privilege Escalation

Techniques by which an attacker (or auditor) gains higher privileges than initially granted on a Linux system — typically escalating from a regular user to root. Understanding these vectors is essential for both offensive security assessments and system hardening.

## Enumeration First

Before attempting any exploit, enumerate the target:

```bash
id                      # current user/groups
sudo -l                 # allowed sudo commands
uname -a                # kernel version
cat /etc/os-release     # distribution
env                     # environment variables
ps aux                  # running processes
ss -tlnp                # listening services
find / -perm -4000 2>/dev/null   # SUID binaries
```

## Common Vectors

### SUID/SGID Binaries

Files with the SUID bit (4000) execute as their _owner_ (often root) rather than the calling user. Misconfigured SUID binaries are among the most common privesc paths.

```bash
find / -perm -4000 -type f 2>/dev/null   # find SUID binaries
find / -perm -2000 -type f 2>/dev/null   # find SGID binaries
```

Check found binaries against [GTFOBins](https://gtfobins.github.io/) for known escape techniques.

### Sudo Misconfiguration

`sudo -l` reveals commands a user may run as root. Dangerous patterns:

- `NOPASSWD` entries — no credential required
- Commands with shell escape (vim, less, awk, python, etc.)
- Wildcard entries in allowed paths

### Writable Cron Scripts

Root-owned crontabs that call world-writable scripts allow arbitrary code execution as root.

```bash
cat /etc/crontab
ls -la /etc/cron.*
crontab -l
find / -writable -path "*/cron*" 2>/dev/null
```

### PATH Hijacking

If a root-owned script calls a binary by relative name (e.g., `backup` not `/usr/bin/backup`) and the caller can write to a directory earlier in `$PATH`, a malicious binary is executed instead.

### Weak File Permissions

```bash
ls -la /etc/passwd /etc/shadow /etc/sudoers
find / -writable -not -path "*/proc/*" 2>/dev/null
```

World-writable `/etc/passwd` allows adding a root-equivalent entry. Readable `/etc/shadow` enables offline password cracking.

### Kernel Exploits

`uname -r` reveals the kernel version. Outdated kernels may be vulnerable to public exploits (Dirty Cow, OverlayFS, etc.).

### Linux Capabilities

[Linux capabilities](linux-capabilities.md) split root privileges into ~40 discrete units. Binaries with dangerous capabilities (e.g., `CAP_SETUID`, `CAP_NET_ADMIN`) can escalate privileges without SUID.

```bash
getcap -r / 2>/dev/null
```

### NFS `no_root_squash`

If `/etc/exports` has `no_root_squash`, a root user on a remote client can mount the share and create SUID binaries executable on the target.

### D-Bus / Polkit

Local privilege escalation via D-Bus services exposed to unprivileged users, or via Polkit policy misconfiguration.

### Environment Variable Injection

LD_PRELOAD, LD_LIBRARY_PATH, and similar variables can inject malicious shared libraries into root-owned processes if the environment is not sanitized.

## Container-Specific Escalation

When inside a container, additional vectors apply:

- Privileged containers (see [Container Security](container-security.md))
- Sensitive host mounts (`/etc`, `/root`, Docker socket)
- `CAP_SYS_ADMIN` enabling namespace escapes
- Weak seccomp/AppArmor profiles

## Hardening Countermeasures

| Vector          | Countermeasure                                          |
| --------------- | ------------------------------------------------------- |
| SUID binaries   | Audit with `find`; remove unnecessary SUID              |
| Sudo misconfig  | Least-privilege sudoers; avoid shell-escapable commands |
| Cron scripts    | Ensure root cron scripts are not world-writable         |
| PATH hijacking  | Use absolute paths in privileged scripts                |
| Capabilities    | Audit with `getcap -r /`; drop unnecessary caps         |
| Kernel exploits | Keep kernel patched; use gVisor/kata for isolation      |

## Related Pages

- [Linux Capabilities](linux-capabilities.md)
- [Container Security](container-security.md)
- [Seccomp](seccomp.md)
- [AppArmor Profiles](apparmor-profiles.md)
- [Shared Library Hijacking](shared-library-hijacking.md) — LD_PRELOAD / ld.so.conf / RPATH injection
- [Wildcard Injection](wildcard-injection.md) — glob argument injection (tar, rsync, 7z, tcpdump)
- [HackTricks Linux Basics](../sources/hacktricks-linux-basics.md)
- [HackTricks Privilege Escalation](../sources/hacktricks-privilege-escalation.md)

### Worked technique references (HackTricks)

- [euid, ruid, suid](../sources/hacktricks-euid-ruid-suid.md) — SUID exploitation mechanics
- [Interesting Groups (Linux PE)](../sources/hacktricks-interesting-groups-linux-pe.md) — docker/disk/shadow/staff group privesc
- [NFS no_root_squash](../sources/hacktricks-nfs-no-root-squash.md) — remote SUID write
- [SSH Agent Forwarding Exploitation](../sources/hacktricks-ssh-forward-agent.md) — stealing `SSH_AUTH_SOCK`
- [Socket Command Injection](../sources/hacktricks-socket-command-injection.md) — UNIX socket → command execution
- [Escaping from Jails](../sources/hacktricks-escaping-limited-bash.md) — chroot/restricted-shell escapes
- [Node Inspector / CEF Debugger Abuse](../sources/hacktricks-electron-cef-chromium-debugger-abuse.md) — `--inspect`/`--remote-debugging-port` RCE
