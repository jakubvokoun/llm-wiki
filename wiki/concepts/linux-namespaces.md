---
title: "Linux Namespaces"
tags: [linux-namespaces, container-security, isolation, linux-hardening]
sources:
  [
    hacktricks-namespaces-index.md,
    hacktricks-cgroup-namespace.md,
    hacktricks-ipc-namespace.md,
    hacktricks-pid-namespace.md,
    hacktricks-mount-namespace.md,
    hacktricks-network-namespace.md,
    hacktricks-time-namespace.md,
    hacktricks-user-namespace.md,
    hacktricks-uts-namespace.md,
  ]
updated: 2026-05-01
---

# Linux Namespaces

Namespaces are the kernel feature that makes a container appear to be its own machine. Each namespace isolates a specific class of resources, presenting a process with a view of that resource that appears private even though the underlying system is shared.

**Critical principle**: "has namespaces" ≠ "is safely isolated". Each namespace only isolates what it was designed for. A private PID namespace does not prevent damage from a writable host bind mount.

## Namespace Types

| Namespace   | Isolates                               | Key security relevance                                                     |
| ----------- | -------------------------------------- | -------------------------------------------------------------------------- |
| **mount**   | Mount table / filesystem view          | Most exploited; host bind mounts bypass it entirely                        |
| **PID**     | Process numbering and visibility       | Sharing exposes host process tree, enables nsenter                         |
| **network** | Interfaces, routes, sockets, firewall  | Host networking exposes loopback services and enables traffic manipulation |
| **IPC**     | SysV IPC objects, POSIX message queues | Attack amplifier: leaks shared memory, secrets                             |
| **UTS**     | Hostname and NIS domain name           | Operational integrity; hostname tampering                                  |
| **user**    | UID/GID mappings                       | Foundation of rootless containers; root in container ≠ root on host        |
| **cgroup**  | Visible cgroup hierarchy               | Visibility-hardening layer; shared = more host recon                       |
| **time**    | CLOCK_MONOTONIC, CLOCK_BOOTTIME        | Checkpoint/restore; no direct escape primitive                             |

## Host Namespace Sharing

The most common attack enabler: operators deliberately share host namespaces for convenience or debugging.

| Risk level | Namespace | Why it matters                                         |
| ---------- | --------- | ------------------------------------------------------ |
| Critical   | mount     | Direct host filesystem access                          |
| Critical   | user      | Container root becomes host root                       |
| High       | PID       | Host process enumeration + nsenter bridge              |
| High       | network   | Host listeners, loopback services, CAP_NET_ADMIN scope |
| Medium     | IPC       | Shared memory secrets, cross-process interference      |
| Low        | UTS       | Hostname tampering, logging integrity                  |
| Low        | cgroup    | Reconnaissance aid                                     |
| Minimal    | time      | Checkpoint/timing confusion only                       |

## Inspection

```bash
ls -l /proc/self/ns              # all namespace symlinks
readlink /proc/self/ns/mnt       # compare with /proc/1/ns/mnt
```

Same inode = same namespace. Matching `/proc/1/ns/<type>` usually means host namespace sharing.

## Entering a Namespace

```bash
nsenter -t <PID> -m -u -n -i -p /bin/bash   # all major namespaces at once
nsenter -t <PID> -n /bin/bash                # network only
```

## Runtime Defaults

| Runtime         | User ns       | PID ns  | Net ns  | Default weakening                    |
| --------------- | ------------- | ------- | ------- | ------------------------------------ |
| Docker          | Off (rootful) | Private | Private | `--privileged`, `--pid/net/ipc=host` |
| Podman rootless | On            | Private | Private | `--privileged`                       |
| Kubernetes      | Opt-in        | Private | Per-Pod | `hostPID/hostNetwork/hostIPC: true`  |

## Related

- [container-security](container-security.md)
- [linux-capabilities](linux-capabilities.md)
- [mandatory-access-control](mandatory-access-control.md)
- [seccomp](seccomp.md)
