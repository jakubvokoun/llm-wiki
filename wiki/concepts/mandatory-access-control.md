---
title: "Mandatory Access Control (MAC)"
tags: [mac, security, lsm, apparmor, selinux, linux]
sources: [apparmor-archwiki.md]
updated: 2026-04-16
---

# Mandatory Access Control (MAC)

Mandatory Access Control (MAC) is a security model in which the operating system
enforces access policies that individual users or processes cannot override.
This contrasts with Discretionary Access Control (DAC), where resource owners
control access permissions themselves.

## DAC vs MAC

| Property              | DAC                                          | MAC                                          |
| --------------------- | -------------------------------------------- | -------------------------------------------- |
| Policy set by         | Resource owner (user/group)                  | System/admin (centrally enforced)            |
| User can bypass       | Yes (owner can chmod 777)                    | No (kernel enforces regardless of owner)     |
| Default               | Linux default (`chmod`/`chown` model)        | Supplemental layer (LSM)                     |
| Compromise escalation | Privileged process can read anything it owns | Confined even if process has root/DAC access |

MAC supplements DAC — it cannot grant _more_ privilege than DAC permits, but it
can restrict _less_ than DAC would allow.

## Linux Security Modules (LSM)

The Linux kernel provides LSM hooks throughout the kernel code path. Security
modules attach to these hooks to implement MAC policies. Multiple LSMs can be
stacked; the `lsm=` kernel parameter controls loading order.

Common LSMs:

| LSM      | Approach            | Default on            |
| -------- | ------------------- | --------------------- |
| AppArmor | Path-based profiles | Ubuntu, Arch (opt-in) |
| SELinux  | Label-based policy  | RHEL, CentOS, Fedora  |
| Smack    | Simplified labels   | Embedded/Tizen        |
| TOMOYO   | Path-based (Japan)  | Some embedded         |

## AppArmor vs SELinux

| Feature         | AppArmor                   | SELinux                         |
| --------------- | -------------------------- | ------------------------------- |
| Policy basis    | Filesystem paths           | File/process labels (xattr)     |
| Filesystem req. | None (path-based)          | Must support xattr              |
| Configuration   | Human-readable profiles    | Complex type enforcement rules  |
| Profile tooling | `aa-genprof`, `aa-logprof` | `audit2allow`, `semanage`       |
| Flexibility     | Lower (path-based leaks)   | Higher (labels survive renames) |
| Learning curve  | Moderate                   | High                            |

## MAC in container security

Containers rely heavily on MAC:

- [AppArmor](../entities/apparmor.md) profiles confine container syscall access
  to paths/capabilities
- SELinux labels ensure containers cannot read host files even as root
- Both are independent of Linux capabilities and seccomp — all three layers
  should be active ([defense-in-depth](defense-in-depth.md))

## See also

- [AppArmor](../entities/apparmor.md)
- [AppArmor Profiles](apparmor-profiles.md)
- [Linux Capabilities](linux-capabilities.md)
- [Seccomp](seccomp.md)
- [Container Security](container-security.md)
- [Defense-in-Depth](defense-in-depth.md)
