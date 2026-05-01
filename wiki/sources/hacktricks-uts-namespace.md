---
title: "HackTricks: UTS Namespace"
tags: [container-security, linux-namespaces, linux-hardening]
sources: [hacktricks-uts-namespace.md]
updated: 2026-05-01
---

# HackTricks: UTS Namespace

Source: [hacktricks-uts-namespace.md](../../raw/hacktricks-uts-namespace.md)

## Key Takeaways

The UTS namespace isolates **hostname** and **NIS domain name**. It is rarely the centerpiece of a breakout but contributes to the overall container boundary. When shared with the host, a privileged process may alter host identity settings — impacting monitoring, logging, and scripts that make trust decisions based on hostname.

Usually a lower-priority finding than PID, mount, or user namespace issues.

## Lab

```bash
sudo unshare --uts --fork bash
hostname
hostname lab-container    # changes only inside this namespace
hostname                  # verify
```

## Checks

```bash
readlink /proc/self/ns/uts      # UTS namespace identifier
hostname                        # hostname as seen by the process
cat /proc/sys/kernel/hostname   # kernel hostname value in this namespace
```

## Abuse

```bash
readlink /proc/self/ns/uts
hostname
cat /proc/sys/kernel/hostname

# Test if hostname can be modified (requires privilege)
hostname hacked-host 2>/dev/null && echo "hostname change worked"
```

Host-side detection:

```bash
docker ps -aq | xargs -r docker inspect --format '{{.Id}} UTSMode={{.HostConfig.UTSMode}}'
```

Containers showing `UTSMode=host` should be reviewed if they also carry capabilities for `sethostname()`/`setdomainname()`.

## Impact

- Host identity tampering
- Confusing logs, monitoring, or automation that trusts hostname
- Not a full escape on its own

## Related

- [linux-namespaces](../concepts/linux-namespaces.md)
- [HackTricks: Linux Namespaces Overview](hacktricks-namespaces-index.md)
