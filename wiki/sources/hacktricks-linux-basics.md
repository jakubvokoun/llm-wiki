---
title: "HackTricks — Linux Basics"
tags:
  [linux, fundamentals, security, filesystem, permissions, privilege-escalation]
sources: [hacktricks-linux-basics.md]
updated: 2026-05-01
---

# HackTricks — Linux Basics

Reference guide to fundamental Linux concepts from a security practitioner's perspective.

## File System Structure

Linux uses a hierarchical tree rooted at `/`:

| Directory        | Purpose                                       |
| ---------------- | --------------------------------------------- |
| `/bin`, `/sbin`  | Essential binaries (user / root)              |
| `/etc`           | Configuration files                           |
| `/home`, `/root` | User and root home directories                |
| `/tmp`           | World-writable temporary storage (sticky bit) |
| `/var`           | Variable data (logs, spool, run state)        |
| `/proc`, `/sys`  | Virtual filesystems exposing kernel state     |
| `/dev`           | Device files                                  |
| `/lib`           | Shared libraries                              |

## Users and Permissions

**User types**

- Root (UID 0) — unrestricted access
- Regular users — scoped to their files and groups
- System users — service accounts (typically no login shell)

**Permission model** — three octets (User / Group / Others), each with r(4) w(2) x(1):

```
755 = rwxr-xr-x   644 = rw-r--r--   777 = rwxrwxrwx
```

Key commands: `chown user:group file`, `chmod MODE file`, `ls -l`.

## Special Permissions (Security-Critical)

| Bit    | Octal | Effect                                   |
| ------ | ----- | ---------------------------------------- |
| SUID   | 4000  | Execute as file _owner_ (not caller)     |
| SGID   | 2000  | Execute as file _group_                  |
| Sticky | 1000  | Only owner can delete files in directory |

SUID/SGID on executables is a primary [privilege escalation](../concepts/linux-privilege-escalation.md) vector — misconfigured binaries run as root regardless of caller identity.

Set via: `chmod 4755 file` (SUID + rwxr-xr-x).

## Sudo and Privilege Management

```bash
sudo command        # run as root
sudo -l             # list allowed commands (enumeration entry point)
sudo -i             # interactive root shell
su user / su -      # switch user / switch to root
visudo              # safely edit /etc/sudoers
```

`sudo -l` output is a critical enumeration step in any privilege escalation assessment.

## Cron Jobs

Cron runs commands on a schedule and is a common privilege escalation vector when world-writable scripts are called by root crontabs.

```
# minute hour day month weekday command
0 2 * * * /path/to/backup.sh
```

Crontab locations to check: `/etc/cron*`, `/var/spool/cron/`, `crontab -l`.

## Process Management

```bash
ps aux              # all processes with user context
top / htop          # real-time view
kill PID            # SIGTERM
killall name        # kill by name
nohup command &     # detach from terminal
```

systemd services: `systemctl start|stop|restart|enable|status SERVICE`.

## Environment Variables

```bash
export VAR=value    # set variable
env / printenv      # list all
echo $PATH          # inspect PATH (hijacking risk)
```

`$PATH` manipulation is a classic privilege escalation technique — if a root-owned script calls relative binaries and PATH is attacker-controlled, arbitrary code executes as root.

## SSH and Remote Access

```bash
ssh user@host
ssh-keygen          # generate keypair
ssh-copy-id         # install public key to authorized_keys
scp / sftp          # file transfer
```

Check `~/.ssh/authorized_keys`, `/etc/ssh/sshd_config`, and agent forwarding settings for misconfigurations.

## Text Processing

`grep`, `sed`, `awk`, `cut`, `sort`, `uniq`, `wc` — used extensively in enumeration scripts and log analysis.

## Key Takeaways

- SUID/SGID bits and world-writable cron scripts are the most common local privilege escalation vectors
- `sudo -l` and `id` are the first enumeration commands in any assessment
- `/proc` and `/sys` expose kernel internals useful for container escape research
- `$PATH` hijacking and cron abuse are simple but frequently effective techniques

## Related Pages

- [Linux Privilege Escalation](../concepts/linux-privilege-escalation.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
- [HackTricks Privilege Escalation](hacktricks-privilege-escalation.md)
- [HackTricks](../entities/hacktricks.md)
