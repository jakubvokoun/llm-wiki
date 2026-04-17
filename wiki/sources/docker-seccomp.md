---
title: "Seccomp Security Profiles for Docker"
tags: [seccomp, docker, containers, linux, syscalls, security]
sources: [docker-seccomp.md]
updated: 2026-04-16
---

# Seccomp Security Profiles for Docker

[Seccomp](../concepts/seccomp.md) (Secure Computing Mode) is a Linux kernel
feature that restricts the set of system calls a process can make. Docker uses
it to confine containers at the syscall level.

## Requirements

- Docker must be built with seccomp support
- Kernel must have `CONFIG_SECCOMP=y`

```bash
grep CONFIG_SECCOMP= /boot/config-$(uname -r)
# CONFIG_SECCOMP=y
```

## Default seccomp profile

Docker's default profile is a JSON allowlist (deny-by-default):

- `defaultAction: SCMP_ACT_ERRNO` — deny all syscalls not listed
- Explicit `SCMP_ACT_ALLOW` overrides for syscalls the application needs
- Blocks ~44 syscalls out of 300+
- Moderately protective; not recommended to change

Apply a custom profile:

```bash
docker run --rm -it \
  --security-opt seccomp=/path/to/profile.json \
  hello-world
```

Run without any seccomp profile (unconfined):

```bash
docker run --rm -it --security-opt seccomp=unconfined debian:latest \
  unshare --map-root-user --user sh -c whoami
```

## Significant blocked syscalls

Selected syscalls blocked by the default profile and why:

| Syscall                                                            | Reason                                                                  |
| ------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| `add_key` / `keyctl` / `request_key`                               | Kernel keyring is not namespaced                                        |
| `bpf`                                                              | Persistent BPF programs in kernel; also gated by `CAP_SYS_ADMIN`        |
| `clock_adjtime` / `clock_settime` / `settimeofday`                 | Time is not namespaced                                                  |
| `clone`                                                            | Deny new namespace creation; also gated by `CAP_SYS_ADMIN`              |
| `create_module` / `init_module` / `delete_module` / `finit_module` | Kernel module manipulation                                              |
| `io_uring_*`                                                       | CVE-class container breakout vulnerabilities                            |
| `kexec_load` / `kexec_file_load`                                   | Load new kernel; also gated by `CAP_SYS_BOOT`                           |
| `mount` / `umount` / `umount2`                                     | Privileged; also gated by `CAP_SYS_ADMIN`                               |
| `open_by_handle_at`                                                | Historic container breakout vector; also gated by `CAP_DAC_READ_SEARCH` |
| `perf_event_open`                                                  | Host information leak via tracing                                       |
| `ptrace`                                                           | Process inspection; seccomp bypass risk pre-kernel 4.8                  |
| `reboot`                                                           | Would reboot host; also gated by `CAP_SYS_BOOT`                         |
| `setns`                                                            | Associate thread with namespace; also gated by `CAP_SYS_ADMIN`          |
| `unshare`                                                          | Clone namespaces for process; also gated by `CAP_SYS_ADMIN`             |

Many blocked syscalls are _also_ gated by Linux capabilities — seccomp provides
defense-in-depth when capabilities are misconfigured.

## Relationship to AppArmor and capabilities

Three complementary kernel enforcement layers for containers:

1. **Linux capabilities** — coarse-grained privilege units (drop `CAP_SYS_ADMIN`, etc.)
2. **Seccomp** — syscall-level allowlisting (independent of capabilities)
3. **AppArmor/SELinux** — MAC path/label-based policy

All three are independent; defense-in-depth means all should be active.

## See also

- [Seccomp](../concepts/seccomp.md)
- [Container Security](../concepts/container-security.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
- [AppArmor Docker Profiles](docker-apparmor.md)
- [Docker](../entities/docker.md)
