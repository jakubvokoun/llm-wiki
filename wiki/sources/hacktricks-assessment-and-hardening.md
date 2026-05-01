---
title: "HackTricks — Container Assessment and Hardening"
tags: [container-security, assessment, hardening, kubernetes, hacktricks]
sources: [hacktricks-assessment-and-hardening.md]
updated: 2026-05-01
---

# HackTricks — Container Assessment and Hardening

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

A container assessment answers two parallel questions: (1) what can an attacker do from this workload? (2) which operator choices made that possible? Many older writeups silently assume rootful runtimes, no user namespace isolation, and cgroup v1. **Verify modern context first before applying older techniques.**

## Modern Triage Questions (Answer Before Attempting Escapes)

1. **Rootful, rootless, or userns-remapped?** — If `/proc/self/uid_map` maps container root to a high host UID range, many host-root writeups no longer apply.
2. **cgroup v1 or v2?** — `cgroup2fs` means `release_agent` cgroup v1 abuse chains are not your first guess.
3. **seccomp and AppArmor/SELinux explicit or only inherited?** — Implicit inheritance may be weaker than defenders assume.
4. **Kubernetes namespace enforcing `baseline`/`restricted`, or just warning/auditing?** — `warn` and `audit` labels do not stop risky pods.

```bash
id
cat /proc/self/uid_map 2>/dev/null
cat /proc/self/gid_map 2>/dev/null
stat -fc %T /sys/fs/cgroup 2>/dev/null
grep -E 'Seccomp|NoNewPrivs' /proc/self/status
cat /proc/1/attr/current 2>/dev/null
# K8s namespace PSS label
NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace 2>/dev/null)
kubectl get ns "$NS" -o jsonpath='{.metadata.labels}' 2>/dev/null
```

## Enumeration Tools

| Tool               | Purpose                                                                             |
| ------------------ | ----------------------------------------------------------------------------------- |
| `linpeas`          | General Linux + container indicators, sockets, capabilities, breakout hints         |
| `CDK`              | Container-focused: enumeration + automated escape checks                            |
| `amicontained`     | Lightweight: capabilities, namespace exposure, restriction profile                  |
| `deepce`           | Container-focused enumerator with breakout-oriented checks                          |
| `grype`            | Image-package vulnerability review                                                  |
| `Tracee`           | Runtime evidence: suspicious process execution, file access, container-aware events |
| `Inspektor Gadget` | eBPF-backed K8s/Linux visibility tied to pods, containers, namespaces               |

## Quick Assessment Checks

```bash
id
capsh --print 2>/dev/null
grep -E 'Seccomp|NoNewPrivs' /proc/self/status
cat /proc/self/uid_map 2>/dev/null
stat -fc %T /sys/fs/cgroup 2>/dev/null
mount
find / -maxdepth 3 \( -name docker.sock -o -name containerd.sock \
  -o -name crio.sock -o -name podman.sock \) 2>/dev/null
```

Key signals:

- Root + broad capabilities + `Seccomp: 0` → immediate attention
- `uid_map` showing 1:1 mapping → far more interesting than namespaced root
- `cgroup2fs` → many cgroup v1 chains are less relevant; check `pids.max`, `memory.max` for DoS
- Runtime sockets often provide a faster path than kernel exploits

## Hardening Priorities

- No privileged containers; no mounted runtime sockets
- Drop all capabilities; add back only what's needed
- User namespaces / rootless execution where feasible
- Keep seccomp, AppArmor, SELinux enabled (don't disable to fix app compat issues)
- Minimal images; frequent rebuilds; scan and sign
- Resource limits (CPU, memory, PIDs) to bound blast radius

**Kubernetes Pod Security Standards — `restricted` profile:**

- `allowPrivilegeEscalation: false`
- Non-root user
- `seccompProfile.type: RuntimeDefault` (explicit, not inherited)
- Aggressive capability drops (`ALL` drop)

## Resource Exhaustion (Blast Radius)

Without cgroup limits, even basic shell access can degrade the host:

```bash
# Check limits from inside the pod
kubectl get pod "$HOSTNAME" -n "$NS" \
  -o jsonpath='{range .spec.containers[*]}{.name}{" cpu="}{.resources.limits.cpu}{" mem="}{.resources.limits.memory}{"\n"}{end}' 2>/dev/null
cat /sys/fs/cgroup/pids.max 2>/dev/null
cat /sys/fs/cgroup/memory.max 2>/dev/null
```

## Hardening Tooling

```bash
# Docker host baseline
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security && sudo sh docker-bench-security.sh
```

Pair with Tracee (runtime detection) and Inspektor Gadget (eBPF kernel telemetry) in Kubernetes environments.

## Related Pages

- [Container Security](../concepts/container-security.md)
- [Linux Privilege Escalation](../concepts/linux-privilege-escalation.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
- [Seccomp](../concepts/seccomp.md)
- [AppArmor Profiles](../concepts/apparmor-profiles.md)
- [HackTricks](../entities/hacktricks.md)
