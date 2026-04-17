---
title: "Linux capabilities(7) Man Page"
tags: [linux, capabilities, security, kernel, posix]
sources: [linux-capabilities-man7.md]
updated: 2026-04-16
---

# Linux capabilities(7) — Man Page

The definitive kernel reference for Linux capabilities (POSIX 1003.1e subset).

## Core concept

Traditional UNIX: two categories — root (UID 0, bypasses all checks) and
unprivileged (full permission checking). Since Linux 2.2, root's power is
split into ~40 **capabilities** that can be independently granted/revoked.
Capabilities are a **per-thread** attribute.

## The five thread capability sets

| Set             | Purpose                                                                            |
| --------------- | ---------------------------------------------------------------------------------- |
| **Permitted**   | Limiting superset; dropped capabilities can never be reacquired without exec       |
| **Inheritable** | Preserved across execve; only raised in permitted if file inheritable set matches  |
| **Effective**   | What the kernel actually checks at syscall time                                    |
| **Bounding**    | Hard limit; masks file permitted caps during execve; per-thread since Linux 2.6.25 |
| **Ambient**     | (Since Linux 4.3) Preserved across exec for non-privileged programs                |

## File capability sets

Stored in `security.capability` xattr (requires `CAP_SETFCAP` to write).
Three file sets — **Permitted** (auto-added), **Inheritable** (ANDed with
thread inheritable), **Effective** (single bit: if set, all new permitted →
effective).

### execve transformation formula

```
P'(ambient)   = (file is privileged) ? 0 : P(ambient)
P'(permitted) = (P(inheritable) & F(inheritable)) |
                (F(permitted) & P(bounding)) | P'(ambient)
P'(effective) = F(effective) ? P'(permitted) : P'(ambient)
P'(inheritable) = P(inheritable)
P'(bounding)  = P(bounding)
```

## Key capabilities

| Capability             | What it allows                                           | Risk     |
| ---------------------- | -------------------------------------------------------- | -------- |
| `CAP_SYS_ADMIN`        | Mount, namespace, quotactl, sethostname — "the new root" | Critical |
| `CAP_DAC_OVERRIDE`     | Bypass all file permission checks (read/write/execute)   | Critical |
| `CAP_DAC_READ_SEARCH`  | Bypass read permission + directory execute checks        | High     |
| `CAP_SETUID`           | Arbitrary UID manipulation → escalate to root            | Critical |
| `CAP_SETGID`           | Arbitrary GID manipulation                               | High     |
| `CAP_CHOWN`            | Change file ownership (UID/GID) arbitrarily              | High     |
| `CAP_FOWNER`           | Change file permissions arbitrarily, set SUID bit        | High     |
| `CAP_NET_BIND_SERVICE` | Bind to ports < 1024                                     | Low      |
| `CAP_NET_RAW`          | Raw/packet sockets; transparent proxying                 | Medium   |
| `CAP_NET_ADMIN`        | Interface config, firewall rules, routing                | High     |
| `CAP_SYS_PTRACE`       | Trace arbitrary processes, read /proc/pid/mem            | High     |
| `CAP_SYS_MODULE`       | Load/unload kernel modules                               | Critical |
| `CAP_BPF`              | Privileged BPF operations (since Linux 5.8)              | Medium   |
| `CAP_SETFCAP`          | Set capabilities on files                                | Critical |
| `CAP_SETPCAP`          | Modify bounding set; add caps to inheritable set         | High     |

> Kernel guidance: avoid `CAP_SYS_ADMIN` — it is already massively overloaded.
> New features should use or create a narrower silo.

## Securebits flags

Per-thread flags that disable special root (UID 0) semantics:

- `SECBIT_NOROOT` — no capability grants when UID 0 execs
- `SECBIT_NO_SETUID_FIXUP` — suppress UID-change-triggered capability adjustments
- `SECBIT_KEEP_CAPS` — retain permitted set across UID→nonzero transitions
- `SECBIT_NO_CAP_AMBIENT_RAISE` — prevent ambient capability raises

Each has a `_LOCKED` companion that makes the flag irreversible.

## Namespaced file capabilities

Since Linux 4.14, version 3 (`VFS_CAP_REVISION_3`) xattrs embed the namespace
root UID. Capabilities only granted when executed from a process whose UID 0
maps to that saved root — enables container-scoped capabilities without
granting host-level privilege.

## See also

- [Linux Capabilities](../concepts/linux-capabilities.md)
- [Container Security](../concepts/container-security.md)
- [Pod Security](../concepts/pod-security.md)
