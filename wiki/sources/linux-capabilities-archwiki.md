---
title: "Linux Capabilities — Arch Wiki"
tags: [linux, capabilities, archlinux, administration, setcap, getcap]
sources: [linux-capabilities-archwiki.md]
updated: 2026-04-16
---

# Linux Capabilities — Arch Wiki

Practical administration guide for Linux capabilities on Arch Linux.

## What capabilities solve

`setuid` root programs give a process _all_ root privileges. Capabilities let
you grant only the specific privilege a program needs (e.g., `CAP_NET_RAW` for
`fping`), limiting blast radius of a vulnerability.

## Implementation

Capabilities are stored in the `security` namespace of extended attributes
(`xattr`), supported by all major Linux filesystems (ext4, btrfs, xfs, jfs).

```bash
# View capabilities
getcap /usr/bin/fping
# → /usr/bin/fping cap_net_raw=ep

# View raw xattr encoding
getfattr --dump --match="^security\." /usr/bin/fping
# → security.capability=0sAQAAAgAgAAAAAAAAAAAAAAAAAAA=
```

On Arch, package install scripts (`.install` files) set capabilities via
`setcap` — e.g., `fping.install`.

## Common programs and their required capabilities

| Program    | Command                                                          |
| ---------- | ---------------------------------------------------------------- |
| `beep`     | `setcap cap_dac_override,cap_sys_tty_config+ep /usr/bin/beep`    |
| `chvt`     | `setcap cap_dac_read_search,cap_sys_tty_config+ep /usr/bin/chvt` |
| `iftop`    | `setcap cap_net_raw+ep /usr/bin/iftop`                           |
| `mii-tool` | `setcap cap_net_admin+ep /usr/bin/mii-tool`                      |
| `nethogs`  | `setcap cap_net_admin,cap_net_raw+ep /usr/bin/nethogs`           |
| `wavemon`  | `setcap cap_net_admin+ep /usr/bin/wavemon`                       |

The `+ep` suffix means **effective** and **permitted** sets.

## Useful commands

```bash
# Find all setuid-root binaries
find /usr/bin /usr/lib -perm /4000 -user root

# Find all setgid-root binaries
find /usr/bin /usr/lib -perm /2000 -group root

# Find all binaries with capabilities set
getcap -r / 2>/dev/null
```

## Temporary capabilities with capsh

Run a program with capabilities without modifying file xattrs:

```bash
# Attach GDB with CAP_SYS_PTRACE
sudo -E capsh \
  --caps="cap_setpcap,cap_setuid,cap_setgid+ep cap_sys_ptrace+eip" \
  --keep=1 --user="$USER" --addamb="cap_sys_ptrace" \
  --shell=/usr/bin/gdb -- -p <pid>

# Bind to port 123 as non-root
sudo -E capsh \
  --caps="cap_setpcap,cap_setuid,cap_setgid+ep cap_net_bind_service+eip" \
  --keep=1 --user="$USER" --addamb="cap_net_bind_service" \
  --shell=/usr/bin/nc -- -lvtn 123
```

## systemd integration

Safer than file capabilities — capabilities are scoped to the unit, not the
binary:

```ini
[Service]
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
```

See `systemd.exec(5)`.

## Administration note

Overly permissive capabilities = bug → report it. `CAP_SYS_ADMIN` and
`CAP_DAC_OVERRIDE` are essentially equivalent to root and do not count as bugs
only on systems without MAC/RBAC (e.g., standard Arch).

## See also

- [Linux Capabilities](../concepts/linux-capabilities.md)
- [setcap(8)](linux-setcap-man7.md)
- [getcap(8)](linux-getcap-man7.md)
