---
title: "Linux AppArmor — Arch Wiki"
tags: [apparmor, linux, mac, lsm, security, containers]
sources: [apparmor-archwiki.md]
updated: 2026-04-16
---

# Linux AppArmor — Arch Wiki

Comprehensive guide to AppArmor on Arch Linux: installation, profile management,
profile authoring, and troubleshooting.

## What is AppArmor

[AppArmor](../entities/apparmor.md) is a
[Mandatory Access Control](../concepts/mandatory-access-control.md) (MAC) system
built on the Linux Security Modules (LSM) framework. It supplements — never
replaces — standard DAC (discretionary access control). An application can never
gain _more_ privilege than DAC already grants.

Key characteristics:

- Path-based (vs SELinux's label-based) — easier to configure, works with any
  filesystem
- Default-deny: anything not explicitly allowed is blocked
- Per-application rule sets enforced at the kernel level
- Every policy violation emits an audit message

Ubuntu uses AppArmor by default; RHEL/SUSE use SELinux.

## Installation (Arch Linux)

1. Install the `apparmor` package (userspace tools + libraries)
2. Enable `apparmor.service` to load profiles on boot
3. Add to kernel parameters:
   ```
   lsm=landlock,lockdown,yama,integrity,apparmor,bpf
   ```
   `apparmor` must be the first "major" module. `capability` is always auto-included.

Custom kernel requires `CONFIG_SECURITY_APPARMOR=y` and `CONFIG_AUDIT=y`.

## Modes

| Mode         | Effect                                                                                     |
| ------------ | ------------------------------------------------------------------------------------------ |
| **enforce**  | Policy violations are blocked and logged                                                   |
| **complain** | Violations logged but allowed — used for testing new profiles. `deny` rules still enforced |

## Key commands

| Command                        | Purpose                                      |
| ------------------------------ | -------------------------------------------- |
| `aa-enabled`                   | Check if AppArmor is active                  |
| `aa-status`                    | Show loaded profiles and process confinement |
| `apparmor_parser -a <profile>` | Load profile in enforce mode                 |
| `apparmor_parser -C <profile>` | Load profile in complain mode                |
| `apparmor_parser -r <profile>` | Reload (overwrite) existing profile          |
| `apparmor_parser -R <profile>` | Remove/unload profile                        |
| `aa-genprof <binary>`          | Generate profile interactively               |
| `aa-logprof`                   | Update profile from audit logs               |
| `aa-enforce <profile>`         | Switch to enforce mode                       |
| `aa-complain <profile>`        | Switch to complain mode                      |
| `aa-teardown`                  | Unload all profiles (session only)           |

Profile generation workflow: `aa-genprof` → run app → `aa-logprof` (add rules) →
`aa-enforce`.

## Profile anatomy

Profiles live in `/etc/apparmor.d/`. Minimal example:

```
#include <tunables/global>

profile test /usr/lib/test/test_binary {
    #include <abstractions/base>

    /usr/share/TEST/** r,
    /usr/lib/TEST/** rm,
    @{HOME}/.config/ r,
    @{HOME}/.config/TEST/** rw,
}
```

Key syntax:

- `@{VAR}` — variables from abstractions/tunables
- `#include` — include shared rule files from `/etc/apparmor.d/abstractions/`
- Access modes: `r` (read), `w` (write), `m` (mmap exec), `x` (execute, needs qualifier)
- `deny` rules take precedence over `allow` and are enforced even in complain mode

See [AppArmor Profiles](../concepts/apparmor-profiles.md) for full profile language
reference.

## deny rules semantics

1. `deny` overrides any `allow` — used in abstractions to lock sensitive paths
2. `deny` silences logging in subsequent `aa-logprof` runs

## Profile caching

Parsing profiles on boot is slow for large sets. Enable caching:

```
/etc/apparmor/parser.conf
write-cache
```

Cache lives at `/var/cache/apparmor/`. Reduces AppArmor startup time significantly.

## Desktop notifications

`aa-notify` displays desktop popups on DENIED events. Requires:

- `audit` framework + `auditd` daemon
- User in `audit` group with read access to `/var/log/audit`
- `python-notify2`, `python-psutil`, `tk` packages
- Autostart entry executing `aa-notify -p -s 1 -w 60 -f /var/log/audit/audit.log`

## Troubleshooting

- **Login broken after AppArmor v4 upgrade**: may be `unix-chkpwd` profile denying
  `CAP_DAC_READ_SEARCH` on `/etc/shadow` — fix file permissions, then re-enable
- **Ubuntu info ≠ Arch**: Ubuntu ships many AppArmor kernel patches; Arch uses
  close-to-mainline. ABI supported by running kernel: `aa-features-abi --extract`

## See also

- [AppArmor](../entities/apparmor.md)
- [AppArmor Profiles](../concepts/apparmor-profiles.md)
- [Mandatory Access Control](../concepts/mandatory-access-control.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
- [Container Security](../concepts/container-security.md)
- [Docker AppArmor Profiles](docker-apparmor.md)
- [AppArmor Core Policy Reference](apparmor-core-policy-reference.md)
