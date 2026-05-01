---
title: "HackTricks: Container Seccomp"
tags: [container-security, seccomp, syscall-filtering, linux-hardening]
sources: [hacktricks-container-seccomp.md]
updated: 2026-05-01
---

# HackTricks: Container Seccomp

Source: [hacktricks-container-seccomp.md](../../raw/hacktricks-container-seccomp.md)

## Key Takeaways

seccomp operates at the syscall entry point — below namespaces and capabilities. The three-layer mental model:

- **Namespaces** — what the process can see
- **Capabilities** — which privileged actions the process is nominally allowed to attempt
- **seccomp** — whether the kernel will even accept the syscall

This layering means seccomp can block attacks that look possible from a capabilities perspective alone.

## Modes

- **Strict mode** — legacy; only a minimal syscall set (`read`, `write`, `exit`, `sigreturn`); any other syscall kills the process
- **Filter mode (seccomp-bpf)** — modern; BPF program evaluated per syscall; actions: `ALLOW`, `ERRNO`, `TRAP`, `LOG`, `KILL`; used by all container runtimes

## Dangerous Syscalls Blocked by Default Profiles

`mount`, `unshare`, `clone`/`clone3` (with namespace flags), `bpf`, `ptrace`, `keyctl`, `perf_event_open`

Blocking these eliminates namespace-creation, kernel subsystem manipulation, and kernel attack surface expansion — before any capability check matters.

## Runtime Defaults

| Runtime            | Default              | Notes                                                                                           |
| ------------------ | -------------------- | ----------------------------------------------------------------------------------------------- |
| Docker Engine      | Enabled              | Built-in default profile unless overridden                                                      |
| Podman             | Enabled              | Applies runtime default unless overridden                                                       |
| **Kubernetes**     | **Not guaranteed**   | `Unconfined` if `securityContext.seccompProfile` is unset and kubelet lacks `--seccomp-default` |
| containerd / CRI-O | Follows K8s settings | `RuntimeDefault` when K8s requests it                                                           |

Kubernetes is the runtime most likely to surprise operators — seccomp is absent in many clusters unless explicitly configured.

## Custom Profile Pattern

JSON profile loaded with `--security-opt seccomp=/path/profile.json`:

```json
{
  "defaultAction": "SCMP_ACT_ALLOW",
  "syscalls": [
    {
      "name": "chmod",
      "action": "SCMP_ACT_ERRNO"
    }
  ]
}
```

Allowlist-based profiles (default KILL, explicit ALLOW) are stronger than this denylist pattern but harder to build.

## Checks

```bash
grep Seccomp /proc/self/status          # 0 = no filter active
cat /proc/self/status | grep NoNewPrivs # companion control
docker inspect <ctr> | jq '.[0].HostConfig.SecurityOpt'
```

- `Seccomp: 0` → no protection
- `seccomp=unconfined` in SecurityOpt → explicitly disabled

## Abuse Scenarios

### Confirming seccomp is absent

```bash
grep Seccomp /proc/self/status
unshare -Ur true 2>/dev/null && echo "unshare works"
unshare -m true 2>/dev/null && echo "mount namespace creation works"
```

### seccomp absent + CAP_SYS_ADMIN → mount abuse

```bash
capsh --print | grep cap_sys_admin
mkdir -p /tmp/nsroot
unshare -m sh -c '
  mount -t tmpfs tmpfs /tmp/nsroot &&
  mkdir -p /tmp/nsroot/proc &&
  mount -t proc proc /tmp/nsroot/proc
'
```

### seccomp absent + cgroup v1 → release_agent

```bash
unshare -UrCm sh -c '
  mkdir /tmp/c
  mount -t cgroup -o memory none /tmp/c
  echo 1 > /tmp/c/notify_on_release
  echo /proc/self/exe > /tmp/c/release_agent
  (sleep 1; echo 0 > /tmp/c/cgroup.procs) &
  while true; do sleep 1; done
'
```

Once seccomp is unconfined, syscall-heavy breakout chains that were previously blocked may work exactly as written.

## Misconfigurations

- **`seccomp=unconfined`** set permanently to fix an app failing under default profile
- **Permissive custom profile** copied from a blog without review — retains dangerous syscalls
- **Assuming non-root containers don't need seccomp** — kernel attack surface is relevant even without UID 0

## Related

- [seccomp](../concepts/seccomp.md)
- [container-security](../concepts/container-security.md)
- [linux-capabilities](../concepts/linux-capabilities.md)
- [HackTricks: Container Cgroups](hacktricks-container-cgroups.md)
