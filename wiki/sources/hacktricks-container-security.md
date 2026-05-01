---
title: "HackTricks — Container Security Overview"
tags:
  [container, security, docker, kubernetes, namespaces, capabilities, escape]
sources: [hacktricks-container-security.md]
updated: 2026-05-01
---

# HackTricks — Container Security Overview

Conceptual foundation for understanding container security from an assessment and attack perspective. Explains what containers are, how isolation is constructed, and how it fails.

## What a Container Actually Is

A container is a **regular Linux process tree** started under an OCI-style configuration that controls:

- What filesystem it sees (mount namespace)
- What kernel resources it can use (cgroups)
- What privilege model applies (capabilities, seccomp, MAC)

The process may believe it's PID 1 in an isolated environment, but it shares the host kernel. This is the fundamental difference from a VM — and the source of the entire container security attack surface.

## Containers vs VMs

| Aspect                | Container                | VM                   |
| --------------------- | ------------------------ | -------------------- |
| Kernel                | Shared with host         | Own kernel           |
| Isolation boundary    | Namespace + cgroup + MAC | Hypervisor           |
| Startup               | Milliseconds             | Seconds              |
| Root in guest         | May map to host root     | Separate from host   |
| Kernel exploit impact | May compromise host      | Usually scoped to VM |

The container model is not inherently less secure than VMs — it requires correct host and runtime configuration.

## Sandboxed Runtimes

**gVisor** (`runsc`) and **Kata Containers** push isolation further:

- gVisor: userspace kernel layer mediates host-kernel access
- Kata: workload runs inside a lightweight VM, orchestrated as containers

These should not be treated as equivalent to standard `runc` containers when modeling risk.

## The Container Stack: Multiple Layers

| Layer             | Examples                                 |
| ----------------- | ---------------------------------------- |
| Orchestrator      | Kubernetes                               |
| Engine / Manager  | Docker Engine, Podman, containerd, CRI-O |
| Low-level runtime | `runc`, `crun`, `runsc`, `kata-runtime`  |
| Kernel            | namespaces, cgroups, seccomp, MAC        |

Security gaps often arise at layer boundaries — a Kubernetes policy may be expressed in a Pod spec but only enforced at the runtime level.

## The Real Security Boundary: Overlapping Controls

Container security comes from **layered, overlapping controls**:

| Control                | What it limits                                |
| ---------------------- | --------------------------------------------- |
| Namespaces             | Visibility (filesystem, network, PIDs, users) |
| cgroups                | Resource usage                                |
| Capabilities           | Privilege scope                               |
| Seccomp                | Syscall access                                |
| AppArmor / SELinux     | MAC policy on files/network                   |
| `no_new_privs`         | Prevents gaining new privileges via execve    |
| Masked procfs paths    | Hides dangerous kernel interfaces             |
| Read-only system paths | Reduces attack surface                        |

Attack chains frequently require **multiple controls to be weak simultaneously**. A writable host bind mount is bad, but catastrophic when combined with root-on-host + CAP_SYS_ADMIN + no seccomp + no MAC.

## Enumeration Mindset for Assessment

First identify the stack and runtime:

```bash
# Which engine?
docker info 2>/dev/null
podman info 2>/dev/null
systemctl list-units | grep -i container

# Which runtime?
cat /proc/1/cgroup          # cgroup hierarchy
ls /.dockerenv              # inside Docker?
cat /run/container-type 2>/dev/null

# Rootful or rootless?
id                          # UID 0 = rootful (or user namespace)

# Host namespaces shared?
ls -la /proc/1/ns/          # compare with own /proc/self/ns/

# Capabilities
cat /proc/self/status | grep Cap
capsh --decode=<hex>

# Seccomp active?
cat /proc/self/status | grep Seccomp

# Dangerous mounts / sockets
ls -la /var/run/docker.sock 2>/dev/null
mount | grep -i "docker\|overlay\|bind"
```

## High-Risk Container Configurations

| Configuration                             | Risk                                        |
| ----------------------------------------- | ------------------------------------------- |
| `--privileged`                            | All capabilities + no seccomp + all devices |
| Docker socket mounted inside container    | API-level host compromise                   |
| `--pid=host`                              | See/control all host processes              |
| `--net=host`                              | Full host network stack                     |
| `--cap-add=SYS_ADMIN`                     | Mount, namespace, kernel op access          |
| Host `/etc` or `/root` bind-mounted       | Credential/config exfiltration              |
| Root UID mapped to host root (no user ns) | Host file system access                     |

## Key Takeaways

- Container isolation is a composition of kernel primitives — any missing layer widens the attack surface
- Identifying the stack early (engine + runtime + rootless vs rootful) predicts likely breakout families
- Docker socket access is often equivalent to host root — no kernel exploit needed
- `--privileged` effectively removes the security boundary
- Assessment should answer: which layer is weak, not just "is this container secure?"

## Related Pages

- [Container Security](../concepts/container-security.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
- [Seccomp](../concepts/seccomp.md)
- [AppArmor Profiles](../concepts/apparmor-profiles.md)
- [Mandatory Access Control](../concepts/mandatory-access-control.md)
- [Linux Privilege Escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks Container Runtimes](hacktricks-container-runtimes.md)
- [HackTricks Privilege Escalation](hacktricks-privilege-escalation.md)
- [HackTricks](../entities/hacktricks.md)
