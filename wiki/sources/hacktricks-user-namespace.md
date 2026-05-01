---
title: "HackTricks: User Namespace"
tags:
  [container-security, linux-namespaces, rootless-containers, linux-hardening]
sources: [hacktricks-user-namespace.md]
updated: 2026-05-01
---

# HackTricks: User Namespace

Source: [hacktricks-user-namespace.md](../../raw/hacktricks-user-namespace.md)

## Key Takeaways

The user namespace remaps UID/GID — **root inside the container is translated, not eliminated**. With proper mapping, UID 0 inside maps to an unprivileged host UID. Without it, container root is uncomfortably close to host root.

This is the foundation of rootless containers (rootless Podman, rootless Docker). It also means that when user namespaces are absent or poorly configured, writable host bind mounts and dangerous capabilities become significantly more exploitable.

## UID/GID Mapping

```bash
unshare --user --map-root-user --fork bash
id
cat /proc/self/uid_map
cat /proc/self/gid_map
```

From host side:

```bash
cat /proc/<pid>/uid_map
cat /proc/<pid>/gid_map
```

Mapping `0 <host-uid> 1` means container UID 0 = host UID `<host-uid>`. A large unprivileged host UID = safer; `0 0 1` = container root is host root.

## Advanced Details

- **ID-mapped mounts**: Apply a user-namespace mapping to a mount without `chown`-ing on-disk ownership; allows rootless shared host paths
- **`unshare -U` re-grants capabilities**: Creating a new user namespace grants a full capability set _inside that namespace_ — useful for namespace-local privileged operations without breaking the host root boundary
- **`setgroups` restriction**: Unprivileged `gid_map` writes require `echo deny > /proc/self/setgroups` first

## Misconfigurations

- Not using user namespaces where feasible (rootful containers with direct host-root mapping)
- Forcing host user namespace sharing or disabling `userns-remap` for compatibility without understanding the trust boundary change

## Checks

```bash
readlink /proc/self/ns/user   # user namespace identifier
id                            # UID/GID inside container
cat /proc/self/uid_map        # UID translation to parent namespace
cat /proc/self/gid_map        # GID translation
```

Key question: does UID 0 inside map closely to host UID 0?

## Abuse

### Test whether host writes happen as real root

```bash
id
cat /proc/self/uid_map
touch /host/tmp/userns_test 2>/dev/null && echo "host write works"
ls -ln /host/tmp/userns_test 2>/dev/null  # owner shows host UID
```

If created as host UID 0, classic host-file abuses are realistic:

```bash
echo test > /host/root/userns_marker 2>/dev/null
ls -l /host/root/userns_marker 2>/dev/null
```

### Regain namespace-local capabilities via unshare

If seccomp allows `unshare`:

```bash
unshare -UrmCpf bash
grep CapEff /proc/self/status
mount -t tmpfs tmpfs /mnt 2>/dev/null && echo "namespace-local mount works"
```

Not a host escape by itself — but re-enables privileged namespace-local actions that may combine with weak mounts or vulnerable kernel surfaces.

## Related

- [linux-namespaces](../concepts/linux-namespaces.md)
- [container-security](../concepts/container-security.md)
- [HackTricks: Linux Namespaces Overview](hacktricks-namespaces-index.md)
- [podman](../entities/podman.md)
