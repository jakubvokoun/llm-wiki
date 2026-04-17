---
title: "AppArmor"
tags: [apparmor, linux, mac, lsm, security]
sources:
  [apparmor-archwiki.md, docker-apparmor.md, apparmor-core-policy-reference.md]
updated: 2026-04-16
---

# AppArmor

**AppArmor** (Application Armor) is a Linux kernel security module implementing
[Mandatory Access Control](../concepts/mandatory-access-control.md) (MAC) via
the Linux Security Modules (LSM) framework. It confines programs to a limited
set of resources using per-application security profiles.

## Overview

- **Path-based** policy: rules reference filesystem paths, not labels — simpler
  to configure than SELinux but less flexible
- **Default-deny**: anything not explicitly allowed is blocked
- **Supplements DAC**: cannot grant a process more privilege than DAC already
  permits
- **Audit integration**: every policy violation generates a kernel audit message

## Distribution support

| Distro        | Default LSM         |
| ------------- | ------------------- |
| Ubuntu        | AppArmor (default)  |
| Arch Linux    | AppArmor (opt-in)   |
| RHEL/CentOS   | SELinux             |
| SUSE/openSUSE | AppArmor or SELinux |

## Core concepts

- **Profile** — per-application rule set (whitelist); lives in
  `/etc/apparmor.d/`
- **Enforce mode** — violations blocked and logged
- **Complain mode** — violations logged only (for profile development); `deny`
  rules still enforced
- **Abstractions** — shared include files in `/etc/apparmor.d/abstractions/`
- **Tunables** — global variables (e.g., `@{HOME}`, `@{PROC}`) in
  `/etc/apparmor.d/tunables/`

## Docker integration

Docker generates and loads a `docker-default` AppArmor profile for every
container. Custom profiles can be specified with `--security-opt apparmor=<name>`.
See [Docker AppArmor Profiles](../sources/docker-apparmor.md).

## Key tools

| Tool              | Purpose                                     |
| ----------------- | ------------------------------------------- |
| `aa-status`       | Show loaded profiles and confined processes |
| `aa-enabled`      | Check if AppArmor is active                 |
| `apparmor_parser` | Load/unload/reload profiles                 |
| `aa-genprof`      | Interactively generate new profiles         |
| `aa-logprof`      | Update profiles from audit log events       |
| `aa-enforce`      | Switch profile to enforce mode              |
| `aa-complain`     | Switch profile to complain mode             |
| `aa-teardown`     | Unload all profiles for current session     |
| `aa-notify`       | Desktop notifications on DENIED events      |
| `aa-features-abi` | Show kernel-supported AppArmor ABI          |

## See also

- [AppArmor Profiles](../concepts/apparmor-profiles.md)
- [Mandatory Access Control](../concepts/mandatory-access-control.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
- [Container Security](../concepts/container-security.md)
- [AppArmor — Arch Wiki](../sources/apparmor-archwiki.md)
- [Docker AppArmor Profiles](../sources/docker-apparmor.md)
- [AppArmor Core Policy Reference](../sources/apparmor-core-policy-reference.md)
