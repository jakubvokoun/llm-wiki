---
title: "AppArmor Security Profiles for Docker"
tags: [apparmor, docker, containers, linux, security]
sources: [docker-apparmor.md]
updated: 2026-04-16
---

# AppArmor Security Profiles for Docker

Docker integrates with [AppArmor](../entities/apparmor.md) to confine container
processes using kernel-enforced
[MAC profiles](../concepts/mandatory-access-control.md).

## docker-default profile

Docker automatically generates and loads a profile named `docker-default` for
every container (unless overridden). It is:

- Generated from a Go template at container start, written to `tmpfs`, loaded
  into the kernel
- Applied to the **container process**, not the Docker daemon
- "Moderately protective while providing wide application compatibility"

Run a container explicitly with the default profile:

```bash
docker run --rm -it --security-opt apparmor=docker-default hello-world
```

## Custom profiles

Load a custom profile:

```bash
apparmor_parser -r -W /path/to/your_profile
docker run --rm -it --security-opt apparmor=your_profile hello-world
```

Unload a profile:

```bash
apparmor_parser -R /path/to/profile
```

## Nginx example profile

```
#include <tunables/global>

profile docker-nginx flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>

  network inet tcp,
  network inet udp,
  network inet icmp,
  deny network raw,
  deny network packet,

  file,
  umount,

  # Deny writes across the filesystem
  deny /bin/** wl,
  deny /boot/** wl,
  deny /etc/** wl,
  deny /home/** wl,
  ...

  audit /** w,
  /var/run/nginx.pid w,
  /usr/sbin/nginx ix,

  # Deny shells and top
  deny /bin/dash mrwklx,
  deny /bin/sh mrwklx,
  deny /usr/bin/top mrwklx,

  # Only required capabilities
  capability chown,
  capability dac_override,
  capability setuid,
  capability setgid,
  capability net_bind_service,

  # Restrict /proc writes
  deny @{PROC}/* w,
  deny mount,
  deny /sys/firmware/** rwklx,
  deny /sys/kernel/security/** rwklx,
}
```

The profile enforces least privilege at the MAC layer:

- Raw network sockets blocked (no ICMP ping)
- Shell execution blocked
- `/proc` and `/sys` write access tightly restricted

## Debugging

**dmesg** — AppArmor logs to the kernel audit ring buffer:

```
apparmor="DENIED" operation="ptrace" profile="docker-default" pid=17651
  comm="docker" requested_mask="receive" denied_mask="receive"
```

**aa-status** — lists loaded profiles and whether each container process is
confined. The `docker-default` profile typically shows in enforce mode.

## Writing profiles

AppArmor globbing syntax differs from bash — see
[AppArmor Core Policy Reference](apparmor-core-policy-reference.md).

Key resources:

- Quick Profile Language reference (AppArmor GitLab wiki)
- Globbing Syntax in Core Policy Reference

## See also

- [AppArmor](../entities/apparmor.md)
- [AppArmor Profiles](../concepts/apparmor-profiles.md)
- [Container Security](../concepts/container-security.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
- [Docker Seccomp](docker-seccomp.md)
- [AppArmor — Arch Wiki](apparmor-archwiki.md)
