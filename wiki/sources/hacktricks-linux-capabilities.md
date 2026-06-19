---
title: "HackTricks — Linux Capabilities"
tags: [linux, capabilities, privilege-escalation, container, security]
sources: [hacktricks-linux-capabilities.md]
updated: 2026-05-01
---

# HackTricks — Linux Capabilities

Security-focused guide to Linux capabilities: how they work, how to enumerate them, and how misconfigured capabilities lead to privilege escalation and container escapes.

## Capability Sets (per-thread)

| Set        | Description                                      |
| ---------- | ------------------------------------------------ |
| **CapInh** | Inherited from parent; passed to child processes |
| **CapPrm** | Maximum caps the process may have                |
| **CapEff** | Active caps used for permission checks           |
| **CapBnd** | Ceiling — caps the process can ever acquire      |
| **CapAmb** | Survives `execve` for non-SUID binaries          |

A process cannot gain caps its parent didn't have, and CapBnd limits lifetime potential even if other sets are expanded.

## Inspecting Capabilities

```bash
# Current process
cat /proc/self/status | grep Cap
capsh --print

# Specific PID
cat /proc/<PID>/status | grep Cap
getpcaps <PID>

# Decode hex bitmask
capsh --decode=0000003fffffffff

# Binary file capabilities
getcap /usr/bin/ping
getcap -r / 2>/dev/null   # system-wide enumeration
```

Example: Docker default container has `CapBnd: 0000003fffffffff` (all), but `CapEff` is reduced to a safe subset.

## Setting Capabilities

```bash
setcap cap_net_raw+ep /usr/sbin/tcpdump    # set effective+permitted
setcap -r /path/to/binary                   # remove all caps
```

`+eip` means effective + inheritable + permitted. File capabilities require xattr support (ext4, btrfs, etc.).

## User-Level Capabilities

Capabilities can be assigned per-user in `/etc/security/capability.conf`:

```
cap_sys_ptrace    developer
cap_net_raw       user1
```

Every process spawned by that user inherits the configured capabilities.

## Docker Container Capabilities

Default Docker container capabilities (subset of ~14): `chown, dac_override, fowner, fsetid, kill, setgid, setuid, setpcap, net_bind_service, net_raw, sys_chroot, mknod, audit_write, setfcap`

```bash
docker run --rm -it r.j3ss.co/amicontained bash   # inspect container caps
docker run --cap-add=SYS_ADMIN ...                  # add dangerous cap
docker run --cap-drop=ALL --cap-add=SYS_PTRACE ...  # minimal cap set
```

## Privilege Escalation via Capabilities

When `getcap -r / 2>/dev/null` finds a binary with dangerous capabilities, it can be exploited.

**Example: Python with CAP_SETUID**

```python
# python2.6 with cap_setuid+ep
import os
os.setuid(0)
os.system("/bin/bash")
```

**Capability-dumb binaries** — binaries that don't explicitly request capabilities but still use whatever ambient caps are available. More dangerous in high-cap environments because they don't reject unexpected privileges.

**Service capabilities** — root-run services have all caps by default. Systemd allows scoping:

```ini
[Service]
User=bob
AmbientCapabilities=CAP_NET_BIND_SERVICE
```

## Dangerous Capabilities (Privesc / Container Escape)

| Capability            | Risk                                         |
| --------------------- | -------------------------------------------- |
| `CAP_SETUID`          | Set arbitrary UID → trivial root             |
| `CAP_SETGID`          | Set arbitrary GID                            |
| `CAP_SYS_ADMIN`       | Mount, clone namespaces, many other root ops |
| `CAP_DAC_OVERRIDE`    | Bypass file permission checks                |
| `CAP_DAC_READ_SEARCH` | Read any file, traverse directories          |
| `CAP_SYS_PTRACE`      | Attach to any process; code injection        |
| `CAP_NET_RAW`         | Raw socket access; traffic sniffing          |
| `CAP_SYS_MODULE`      | Load kernel modules                          |
| `CAP_CHOWN`           | Change ownership of any file                 |

## Key Takeaways

- `getcap -r / 2>/dev/null` is a required enumeration step alongside SUID search
- CAP_SETUID on any interpreter (python, perl, ruby) is equivalent to SUID root
- CAP_SYS_ADMIN is effectively root in most container contexts
- Docker's default cap set is designed to be functional without granting dangerous caps; adding `--privileged` or `--cap-add=SYS_ADMIN` dramatically changes the threat model
- Capability-dumb binaries in high-privilege environments can be exploited without SUID

## Related Pages

- [Linux Capabilities](../concepts/linux-capabilities.md)
- [Linux Privilege Escalation](../concepts/linux-privilege-escalation.md)
- [Container Security](../concepts/container-security.md)
- [Seccomp](../concepts/seccomp.md)
- [HackTricks Privilege Escalation](hacktricks-privilege-escalation.md)
- [HackTricks Container Security](hacktricks-container-security.md)
- [HackTricks](../entities/hacktricks.md)
