---
title: "HackTricks — no_new_privs in Container Environments"
tags: [container-security, privilege-escalation, linux, hardening, hacktricks]
sources: [hacktricks-no-new-privileges.md]
updated: 2026-05-01
---

# HackTricks — no_new_privs in Container Environments

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

`no_new_privs` (`PR_SET_NO_NEW_PRIVS`) prevents exec-time privilege gain: executing a setuid binary,
setgid binary, or file with Linux capabilities does not grant extra privilege beyond what the process
already holds. It blocks a specific class of **follow-up escalation** after code execution — not a
substitute for namespaces, seccomp, or capability dropping.

Key properties:

- **Inherited and irreversible** — propagates across `fork()`, `clone()`, `execve()`; cannot be unset
- Blocks setuid/setgid transitions and file-cap additions on exec
- Does **not** block: direct `setuid(2)` calls, already-held privilege, file-descriptor passing, privilege changes without exec

## Kernel mapping

| Layer         | Setting                                           |
| ------------- | ------------------------------------------------- |
| Kernel flag   | `PR_SET_NO_NEW_PRIVS`                             |
| Docker/Podman | `--security-opt no-new-privileges=true`           |
| Kubernetes    | `securityContext.allowPrivilegeEscalation: false` |
| OCI spec      | `process.noNewPrivileges`                         |

## Critical K8s Nuance

`allowPrivilegeEscalation: false` is **effectively ignored** when:

- `privileged: true` is set, OR
- `CAP_SYS_ADMIN` is in the capability set

Always verify actual kernel state, not just the manifest:

```bash
grep NoNewPrivs /proc/self/status
```

## Seccomp Interaction

Unprivileged tasks generally need `no_new_privs` set before they can install a seccomp filter.
Seeing both `NoNewPrivs: 1` and `Seccomp: 2` together usually indicates deliberate hardening.

## Abuse (When Missing)

```bash
grep NoNewPrivs /proc/self/status          # 0 = exec-time escalation still possible
find / -perm -4000 -type f 2>/dev/null | head -n 50   # setuid files
getcap -r / 2>/dev/null | head -n 50       # files with Linux file capabilities
```

Verify K8s config vs. kernel reality:

```bash
NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace 2>/dev/null)
kubectl get pod "$HOSTNAME" -n "$NS" \
  -o jsonpath='{.spec.containers[*].securityContext.allowPrivilegeEscalation}{"\n"}{.spec.containers[*].securityContext.privileged}{"\n"}' 2>/dev/null
grep -E 'NoNewPrivs|Seccomp' /proc/self/status
```

Interesting combinations to flag:

- `allowPrivilegeEscalation: false` in spec but `NoNewPrivs: 0` in kernel
- `CAP_SYS_ADMIN` present (makes the K8s field untrustworthy)
- `Seccomp: 0` + `NoNewPrivs: 0` together = broadly weakened posture

## In-Container Escalation via setuid

`no_new_privs` primarily blocks **in-container** privilege escalation, not direct host escape.
Converting low-privilege foothold to container-root is often the prerequisite for later host escape:

```bash
grep NoNewPrivs /proc/self/status
find / -perm -4000 -type f 2>/dev/null | head -n 20
/bin/su -c id 2>/dev/null
```

## Runtime Defaults

| Runtime          | Default                                  | Common weakening                                                                |
| ---------------- | ---------------------------------------- | ------------------------------------------------------------------------------- |
| Docker Engine    | **Not enabled by default**               | Omitting `--security-opt no-new-privileges=true`; `--privileged`                |
| Podman           | **Not enabled by default**               | Omitting `--security-opt no-new-privileges`; `--privileged`                     |
| Kubernetes       | Controlled by `allowPrivilegeEscalation` | `allowPrivilegeEscalation: true` (default), `privileged: true`, `CAP_SYS_ADMIN` |
| containerd/CRI-O | Follows K8s workload settings            | Same as Kubernetes row                                                          |

This protection is often absent simply because nobody turned it on.

## Related Pages

- [Container Security](../concepts/container-security.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
- [Seccomp](../concepts/seccomp.md)
- [HackTricks — Container Capabilities](hacktricks-container-capabilities.md)
- [HackTricks](../entities/hacktricks.md)
