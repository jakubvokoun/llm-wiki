---
title: "HackTricks: Linux Namespaces Overview"
tags: [container-security, linux-namespaces, isolation, linux-hardening]
sources: [hacktricks-namespaces-index.md]
updated: 2026-05-01
---

# HackTricks: Linux Namespaces Overview

Source: [hacktricks-namespaces-index.md](../../raw/hacktricks-namespaces-index.md)

## Key Takeaways

Namespaces make a container feel like "its own machine" by letting the kernel present different views of selected resources to different process groups. They do **not** create a new kernel and do **not** virtualize everything. Each namespace isolates exactly one class of resource — nothing more.

The critical misconception to avoid: **"has namespaces" ≠ "is safely isolated"**. A process can have a private PID namespace and still be dangerous because it has a writable host bind mount or retains `CAP_SYS_ADMIN` without seccomp. Namespaces are foundational but only one layer.

## Namespace Types

| Namespace   | Isolates                                      |
| ----------- | --------------------------------------------- |
| **mount**   | Mount table — filesystem view                 |
| **PID**     | Process visibility and numbering              |
| **network** | Interfaces, routes, sockets, firewall state   |
| **IPC**     | SysV IPC and POSIX message queues             |
| **UTS**     | Hostname and NIS domain name                  |
| **user**    | UID/GID mappings — root inside ≠ root on host |
| **cgroup**  | Visible cgroup hierarchy                      |
| **time**    | CLOCK_MONOTONIC and CLOCK_BOOTTIME offsets    |

## Host Namespace Sharing

The most common attack enabler is not a kernel exploit — it's deliberate namespace sharing:

| Runtime            | Sharing flags                                                                                  |
| ------------------ | ---------------------------------------------------------------------------------------------- |
| Docker / Podman    | `--pid=host`, `--network=host`, `--ipc=host`, `--uts=host`, `--userns=host`, `--cgroupns=host` |
| Kubernetes         | `hostPID: true`, `hostNetwork: true`, `hostIPC: true`                                          |
| containerd / CRI-O | OCI spec fields; follows Kubernetes pod config                                                 |

The important question is never just "is the process in a namespace?" but **whether the namespace is private, shared with siblings, or joined directly to the host**.

## Inspection

```bash
ls -l /proc/self/ns              # All namespace symlinks for current process
readlink /proc/self/ns/mnt       # Mount namespace identifier
readlink /proc/1/ns/mnt          # Compare with PID 1 (init/container init)
```

Same namespace identifier = same namespace.

### Enumerate distinct namespace instances from the host

```bash
sudo find /proc -maxdepth 3 -type l -name mnt  -exec readlink {} \; 2>/dev/null | sort -u
sudo find /proc -maxdepth 3 -type l -name pid  -exec readlink {} \; 2>/dev/null | sort -u
sudo find /proc -maxdepth 3 -type l -name net  -exec readlink {} \; 2>/dev/null | sort -u
```

### Enter a target namespace

```bash
nsenter -t TARGET_PID -m /bin/bash   # mount
nsenter -t TARGET_PID -p /bin/bash   # pid
nsenter -t TARGET_PID -n /bin/bash   # network
nsenter -t TARGET_PID -i /bin/bash   # ipc
nsenter -t TARGET_PID -u /bin/bash   # uts
nsenter -t TARGET_PID -U /bin/bash   # user
nsenter -t TARGET_PID -C /bin/bash   # cgroup
nsenter -t TARGET_PID -T /bin/bash   # time
```

## Runtime Defaults

| Runtime    | Default posture                                                     | Common weakening                               |
| ---------- | ------------------------------------------------------------------- | ---------------------------------------------- |
| Docker     | New mount, PID, net, IPC, UTS; user ns available but off by default | `--pid=host`, `--network=host`, `--privileged` |
| Podman     | New namespaces; rootless auto-uses user ns                          | same flags                                     |
| Kubernetes | No host PID/net/IPC by default; user ns opt-in                      | `hostPID/hostNetwork/hostIPC: true`            |

## Related

- [linux-namespaces](../concepts/linux-namespaces.md)
- [container-security](../concepts/container-security.md)
- [HackTricks: Mount Namespace](hacktricks-mount-namespace.md)
- [HackTricks: PID Namespace](hacktricks-pid-namespace.md)
- [HackTricks: User Namespace](hacktricks-user-namespace.md)
- [HackTricks: IPC Namespace](hacktricks-ipc-namespace.md)
- [HackTricks: Cgroup Namespace](hacktricks-cgroup-namespace.md)
- [HackTricks: Network Namespace](hacktricks-network-namespace.md)
- [HackTricks: Time Namespace](hacktricks-time-namespace.md)
- [HackTricks: UTS Namespace](hacktricks-uts-namespace.md)
