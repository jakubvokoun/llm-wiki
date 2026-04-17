---
title: "Linux Capabilities"
tags:
  [
    linux,
    capabilities,
    security,
    kernel,
    privilege-escalation,
    container-security,
  ]
sources:
  [
    linux-capabilities-man7.md,
    linux-capabilities-archwiki.md,
    linux-capabilities-juggernaut.md,
    linux-setcap-man7.md,
    linux-getcap-man7.md,
  ]
updated: 2026-04-16
---

# Linux Capabilities

Linux capabilities (POSIX 1003.1e subset, since Linux 2.2) split the
all-or-nothing superuser model into ~40 discrete privilege units that can be
independently granted, dropped, and audited. They replace `setuid`-root
binaries as the mechanism for granting limited elevated privileges.

## Why capabilities matter for security

- `setuid` root grants _all_ root privileges; capabilities grant _only what's
  needed_ (principle of least privilege)
- If a capable binary is compromised, blast radius is bounded by its capability
  set
- Misconfigured capabilities on binaries are a real privilege escalation vector
- Container runtimes (Docker, containerd) drop capabilities by default;
  understanding caps is essential for hardening containers

## Capability sets (per-thread)

| Set             | Description                                                                   |
| --------------- | ----------------------------------------------------------------------------- |
| **Permitted**   | Upper bound; dropped caps can never return without exec                       |
| **Inheritable** | Preserved across `execve`; intersected with file inheritable set              |
| **Effective**   | What the kernel checks at syscall time                                        |
| **Bounding**    | Hard ceiling; masks file permitted caps during exec (per-thread since 2.6.25) |
| **Ambient**     | (Linux 4.3+) Preserved across exec for non-privileged programs                |

View with: `cat /proc/<PID>/status | grep Cap` and decode with `capsh --decode=<hex>`.

## File capabilities

Stored in `security.capability` xattr (requires `CAP_SETFCAP` to write).
Capability string format: `cap_name[+|-][eip]` where:

- `e` = effective
- `i` = inheritable
- `p` = permitted

```bash
# Grant fping raw socket access
setcap cap_net_raw+ep /usr/bin/fping

# View capabilities
getcap /usr/bin/fping
# → /usr/bin/fping cap_net_raw=ep

# Find all capable binaries (audit / pentest)
getcap -r / 2>/dev/null

# Remove all capabilities
setcap -r /usr/bin/mybinary
```

## Key capabilities reference

| Capability             | Privilege granted                                   | Danger   |
| ---------------------- | --------------------------------------------------- | -------- |
| `CAP_SYS_ADMIN`        | Mount, namespaces, many admin syscalls ("new root") | Critical |
| `CAP_DAC_OVERRIDE`     | Bypass all file r/w/x checks                        | Critical |
| `CAP_SETUID`           | Arbitrary UID manipulation → root                   | Critical |
| `CAP_SETFCAP`          | Set capabilities on files                           | Critical |
| `CAP_SYS_MODULE`       | Load/unload kernel modules                          | Critical |
| `CAP_DAC_READ_SEARCH`  | Bypass read + directory execute checks              | High     |
| `CAP_CHOWN`            | Change file ownership arbitrarily                   | High     |
| `CAP_FOWNER`           | Change file permissions + set SUID bit              | High     |
| `CAP_SETGID`           | Arbitrary GID manipulation                          | High     |
| `CAP_NET_ADMIN`        | Interface config, firewall, routing                 | High     |
| `CAP_SYS_PTRACE`       | Trace arbitrary processes, read /proc/pid/mem       | High     |
| `CAP_SETPCAP`          | Modify bounding set; add to inheritable set         | High     |
| `CAP_NET_RAW`          | Raw/packet sockets                                  | Medium   |
| `CAP_NET_BIND_SERVICE` | Bind ports < 1024                                   | Low      |
| `CAP_BPF`              | Privileged BPF operations (Linux 5.8+)              | Medium   |

> Kernel developer guidance: avoid `CAP_SYS_ADMIN` — it is already massively
> overloaded. The only features that should add to it are those closely matching
> existing uses.

## Privilege escalation via misconfigured capabilities

Binaries — especially scripting languages and text editors — with dangerous
capabilities are a privilege escalation path. Attack pattern:

1. Enumerate: `getcap -r / 2>/dev/null` or LinPEAS
2. Identify the capability and what it allows
3. Use GTFOBins — match capability to its _action_ (not just "Capabilities"):
   - `cap_dac_read_search` → File Read function
   - `cap_dac_override` → File Write function
   - `cap_setuid` → Capabilities function

Common exploits:

| Capability            | Attack                                                 |
| --------------------- | ------------------------------------------------------ |
| `cap_dac_read_search` | Read `/etc/shadow`, `/root/.ssh/id_rsa`                |
| `cap_dac_override`    | Append root user to `/etc/passwd`, edit `/etc/sudoers` |
| `cap_chown`           | Take ownership of `/etc/shadow`, then modify           |
| `cap_fowner`          | `chmod 4755 /bin/bash` → `bash -p`                     |
| `cap_setuid`          | `os.setuid(0); exec /bin/bash`                         |

See [Juggernaut guide](../sources/linux-capabilities-juggernaut.md) for worked examples.

## Temporary capabilities (capsh)

Run a program with capabilities without modifying file xattrs:

```bash
sudo -E capsh --caps="cap_setpcap,cap_setuid,cap_setgid+ep cap_net_bind_service+eip" \
  --keep=1 --user="$USER" --addamb="cap_net_bind_service" \
  --shell=/usr/bin/nc -- -lvtn 123
```

## systemd integration

Prefer scoping capabilities to the systemd unit rather than the binary:

```ini
[Service]
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
```

## Securebits

Per-thread flags that disable special UID-0 semantics:

- `SECBIT_NOROOT` — no caps granted when root execs a binary
- `SECBIT_NO_SETUID_FIXUP` — suppress UID-change capability adjustments
- Each has a `_LOCKED` companion that makes the flag irreversible

## Namespaced file capabilities (Linux 4.14+)

Version 3 xattrs embed the namespace root UID. Capabilities are only granted
when executed from within the matching namespace — enables container-scoped
file capabilities without host-level privilege.

## Container security relevance

- Docker/Podman/containerd drop most capabilities by default
- `--cap-add`/`--cap-drop` override defaults
- Kubernetes `securityContext.capabilities.drop: [ALL]` + add only what's needed
- Never run containers with `CAP_SYS_ADMIN` unless absolutely required

## See also

- [Container Security](container-security.md)
- [Pod Security](pod-security.md)
- [Kubernetes Security](kubernetes-security.md)
- [sources/linux-capabilities-man7](../sources/linux-capabilities-man7.md) — kernel reference
- [sources/linux-capabilities-archwiki](../sources/linux-capabilities-archwiki.md) — practical admin guide
- [sources/linux-capabilities-juggernaut](../sources/linux-capabilities-juggernaut.md) — privilege escalation
