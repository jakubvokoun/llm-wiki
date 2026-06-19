---
title: "HackTricks — Masked Paths in Container Environments"
tags: [container-security, procfs, sysfs, hardening, hacktricks]
sources: [hacktricks-masked-paths.md]
updated: 2026-05-01
---

# HackTricks — Masked Paths in Container Environments

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

Masked paths hide sensitive kernel-facing filesystem locations from the container by bind-mounting over them. The purpose is to prevent interaction with kernel control interfaces that ordinary applications never need, especially under `/proc` and `/sys`. Masking is **not** the main isolation boundary — it removes high-value post-exploitation reconnaissance and modification targets.

## Default Masked Paths (Docker)

```
/proc/kcore         /proc/keys          /proc/latency_stats
/proc/timer_list    /proc/sched_debug   /sys/firmware
```

Check what the runtime declared vs. what is actually accessible:

```bash
docker inspect <container> | jq '.[0].HostConfig.MaskedPaths'
mount | grep -E '/proc|/sys'
ls -ld /proc/kcore /proc/keys /proc/timer_list /sys/firmware 2>/dev/null
```

## Abuse (When Masking Is Absent or Bypassed)

```bash
head -n 20 /proc/timer_list 2>/dev/null   # Scheduler/timer internals, host fingerprinting
cat /proc/keys 2>/dev/null | head         # Kernel keyring; may expose key descriptions/service relationships
ls -la /sys/firmware 2>/dev/null          # Firmware/boot metadata, platform recon
zcat /proc/config.gz 2>/dev/null | head   # Kernel build config: subsystems, exploit preconditions
head -n 50 /proc/sched_debug 2>/dev/null  # Scheduler state; may reveal host tasks despite PID ns
```

Key values:

- `/proc/keys` — may expose host service keyring relationships
- `/proc/config.gz` — kernel build config for exploit triage (mitigations, BPF, user-ns support)
- `/proc/sched_debug` — can bypass PID namespace process-hiding expectations
- `/sys/firmware` — confirms host-level firmware state visibility

## Misconfigurations

| Config                               | Effect                                  |
| ------------------------------------ | --------------------------------------- |
| `--privileged`                       | Removes masked paths entirely           |
| `--security-opt unmask=ALL` (Podman) | Explicitly unmaskes everything          |
| `procMount: Unmasked` (K8s)          | Exposes full host procfs view           |
| Host `/proc` or `/sys` bind mounts   | Bypasses container-scoped view entirely |

## Runtime Defaults Table

| Runtime          | Default state             | Common weakening                            |
| ---------------- | ------------------------- | ------------------------------------------- |
| Docker Engine    | Masked by default         | `--privileged`, host proc/sys mounts        |
| Podman           | Masked by default         | `--security-opt unmask=ALL`, `--privileged` |
| Kubernetes       | Inherits runtime defaults | `procMount: Unmasked`, privileged workloads |
| containerd/CRI-O | OCI/runtime defaults      | Direct runtime config changes               |

## Related Pages

- [Container Security](../concepts/container-security.md)
- [HackTricks — Sensitive Host Mounts](hacktricks-sensitive-host-mounts.md)
- [HackTricks — Read-Only System Paths](hacktricks-read-only-paths.md)
- [HackTricks — Privileged Containers](hacktricks-privileged-containers.md)
- [HackTricks](../entities/hacktricks.md)
