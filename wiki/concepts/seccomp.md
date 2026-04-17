---
title: "Seccomp (Secure Computing Mode)"
tags: [seccomp, linux, syscalls, containers, docker, security]
sources: [docker-seccomp.md]
updated: 2026-04-16
---

# Seccomp (Secure Computing Mode)

Seccomp (Secure Computing Mode) is a Linux kernel feature that restricts the
set of system calls a process may invoke. It provides syscall-level sandboxing
independent of Linux capabilities or MAC systems.

## How it works

The `seccomp()` syscall applies a BPF (Berkeley Packet Filter) program to the
calling process. The BPF program inspects each syscall attempt and returns an
action:

| Action           | Effect                                |
| ---------------- | ------------------------------------- |
| `SCMP_ACT_ALLOW` | Allow the syscall                     |
| `SCMP_ACT_ERRNO` | Return `EPERM` (Permission Denied)    |
| `SCMP_ACT_KILL`  | Kill the process immediately          |
| `SCMP_ACT_TRACE` | Notify a ptracer (used for sandboxes) |

A **seccomp profile** is typically structured as an allowlist:
`defaultAction = SCMP_ACT_ERRNO` with explicit `SCMP_ACT_ALLOW` overrides.

Kernel requirement: `CONFIG_SECCOMP=y`.

## Docker default profile

Docker's default seccomp profile (JSON allowlist):

- Blocks ~44 of 300+ syscalls
- Denies by default; allows only what containers typically need
- Should not be changed without careful testing

Apply custom profile:

```bash
docker run --security-opt seccomp=/path/to/profile.json myimage
```

Disable seccomp entirely (not recommended):

```bash
docker run --security-opt seccomp=unconfined myimage
```

## Key blocked syscall categories

| Category            | Examples                                                | Why blocked                                        |
| ------------------- | ------------------------------------------------------- | -------------------------------------------------- |
| Kernel module ops   | `init_module`, `delete_module`, `finit_module`          | Container escape / host persistence                |
| Namespace creation  | `clone`, `unshare`, `setns`                             | Namespace escapes; also gated by `CAP_SYS_ADMIN`   |
| Time modification   | `clock_settime`, `settimeofday`, `stime`                | Time not namespaced                                |
| Kernel keyring      | `add_key`, `keyctl`, `request_key`                      | Keyring not namespaced                             |
| BPF                 | `bpf`                                                   | Persistent kernel-level code; `CAP_SYS_ADMIN` gate |
| io_uring            | `io_uring_enter`, `io_uring_setup`, `io_uring_register` | CVE-class container breakout vulnerabilities       |
| Tracing / profiling | `ptrace`, `perf_event_open`, `lookup_dcookie`           | Host info leak; seccomp bypass pre-4.8             |
| Boot / kexec        | `kexec_load`, `kexec_file_load`, `reboot`               | Would affect entire host                           |
| Obsolete syscalls   | `sysfs`, `_sysctl`, `ustat`, `nfsservctl`               | Attack surface reduction                           |

## Defense-in-depth layering

Seccomp works alongside (not instead of) other Linux security primitives:

```
Linux Capabilities → coarse privilege units (drop CAP_SYS_ADMIN, etc.)
Seccomp            → fine-grained syscall allowlisting
AppArmor / SELinux → path/label-based MAC policy
```

Many syscalls blocked by seccomp are _also_ gated by capabilities — seccomp
provides a second enforcement point if capabilities are misconfigured.

## See also

- [Container Security](container-security.md)
- [Linux Capabilities](linux-capabilities.md)
- [AppArmor Profiles](apparmor-profiles.md)
- [Mandatory Access Control](mandatory-access-control.md)
- [Defense-in-Depth](defense-in-depth.md)
- [Docker Seccomp Profiles](../sources/docker-seccomp.md)
