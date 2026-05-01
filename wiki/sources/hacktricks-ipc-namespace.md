---
title: "HackTricks: IPC Namespace"
tags: [container-security, linux-namespaces, ipc, linux-hardening]
sources: [hacktricks-ipc-namespace.md]
updated: 2026-05-01
---

# HackTricks: IPC Namespace

Source: [hacktricks-ipc-namespace.md](../../raw/hacktricks-ipc-namespace.md)

## Key Takeaways

The IPC namespace isolates **System V IPC objects** (shared memory segments, semaphores, message queues) and **POSIX message queues**. When absent or shared, a container may attach to host or sibling-workload IPC objects.

IPC sharing is best understood as an **attack amplifier** — it rarely provides a standalone host escape, but it leaks data and coordination channels that shorten and stabilize later attack chains.

## Misconfigurations

- `--ipc=host` (Docker/Podman) or `hostIPC: true` (Kubernetes)
- Often done for legacy software compatibility; overlooked because it feels less dramatic than host PID or network sharing

## Checks

```bash
readlink /proc/self/ns/ipc   # namespace identifier
ipcs -a                      # visible SysV IPC objects
mount | grep shm             # shared-memory mounts
```

## Abuse

### Enumerate IPC objects

```bash
readlink /proc/self/ns/ipc
ipcs -a
ls -la /dev/shm 2>/dev/null | head -n 50
```

### Identify interesting owners and sizes

```bash
ipcs -m -p    # shared memory + owning PIDs
ipcs -q -p    # message queues + owning PIDs
```

### Secret recovery from /dev/shm

```bash
find /dev/shm -maxdepth 2 -type f 2>/dev/null -print
strings /dev/shm/* 2>/dev/null | grep -Ei 'token|secret|password|jwt|key'
```

Sensitive artifacts can include session tokens, credentials, or application state left in transient shared memory.

## Impact

- Extraction of secrets or session material from shared memory
- Insight into applications currently active on the host
- Better targeting for PID-namespace or ptrace-based follow-on attacks

Environments with heavy shared-memory use (browsers, databases, scientific workloads) have a larger IPC attack surface when this namespace is shared.

## Related

- [linux-namespaces](../concepts/linux-namespaces.md)
- [container-security](../concepts/container-security.md)
- [HackTricks: PID Namespace](hacktricks-pid-namespace.md)
- [HackTricks: Linux Namespaces Overview](hacktricks-namespaces-index.md)
