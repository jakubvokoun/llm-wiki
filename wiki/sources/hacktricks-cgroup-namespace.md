---
title: "HackTricks: cgroup Namespace"
tags: [container-security, linux-namespaces, cgroups, linux-hardening]
sources: [hacktricks-cgroup-namespace.md]
updated: 2026-05-01
---

# HackTricks: cgroup Namespace

Source: [hacktricks-cgroup-namespace.md](../../raw/hacktricks-cgroup-namespace.md)

## Key Takeaways

The cgroup namespace **virtualizes the visible cgroup hierarchy** — it is a visibility and information-reduction feature, not a resource enforcement mechanism. It does not replace cgroup resource limits or prevent cgroup-based exploitation.

Best understood as a **visibility-hardening layer**: it reduces host cgroup structure exposure, which narrows reconnaissance and makes host-relative path alignment harder for the attacker.

## What It Does

- Without private cgroup ns: process may see host-relative cgroup paths revealing machine layout
- With private cgroup ns: `/proc/self/cgroup` shows a container-scoped view

## Lab

```bash
sudo unshare --cgroup --fork bash
cat /proc/self/cgroup

docker run --rm debian:stable-slim cat /proc/self/cgroup
docker run --rm --cgroupns=host debian:stable-slim cat /proc/self/cgroup
```

## Checks

```bash
readlink /proc/self/ns/cgroup   # namespace identifier
cat /proc/self/cgroup           # visible cgroup paths
mount | grep cgroup             # mounted cgroup filesystems
```

## Abuse

The cgroup namespace alone rarely gives instant escape. Its value is reconnaissance when shared:

```bash
readlink /proc/self/ns/cgroup
cat /proc/self/cgroup
cat /proc/1/cgroup 2>/dev/null
```

When writable cgroup paths are also exposed, check for dangerous legacy interfaces:

```bash
find /sys/fs/cgroup -maxdepth 3 -name release_agent 2>/dev/null -exec ls -l {} \;
find /sys/fs/cgroup -maxdepth 3 -writable 2>/dev/null | head -n 50
```

### Full example: shared cgroup ns + writable cgroup v1 → release_agent

If `release_agent` is reachable and writable, pivot into the full cgroup v1 exploitation flow — the impact is host code execution from inside the container.

```bash
cat /proc/self/cgroup
find /sys/fs/cgroup -maxdepth 3 -name release_agent 2>/dev/null
find /sys/fs/cgroup -maxdepth 3 -name notify_on_release 2>/dev/null | head
```

Without writable cgroup interfaces the impact is usually limited to reconnaissance.

## Related

- [linux-namespaces](../concepts/linux-namespaces.md)
- [container-security](../concepts/container-security.md)
- [HackTricks: Container Cgroups](hacktricks-container-cgroups.md)
- [HackTricks: Linux Namespaces Overview](hacktricks-namespaces-index.md)
