---
title: "Container Security"
tags: [containers, security, hardening, docker, kubernetes, capabilities]
sources:
  [
    owasp-docker-security.md,
    linux-capabilities-man7.md,
    hacktricks-runtime-api-daemon-exposure.md,
    hacktricks-authorization-plugins.md,
    hacktricks-sensitive-host-mounts.md,
    hacktricks-assessment-and-hardening.md,
  ]
updated: 2026-05-01
---

# Container Security

Security practices for building, deploying, and running containerized workloads.

## Core Principles

### Least Privilege

- Run as non-root user
- Drop all Linux capabilities, add only required ones (`--cap-drop all --cap-add X`)
- Never use `--privileged`
- Use `--security-opt=no-new-privileges`
- Read-only root filesystem (`--read-only`)

### Isolation

- Don't expose Docker socket to containers
- Use custom networks instead of default bridge with open ICC
- Apply seccomp, AppArmor, or SELinux profiles
- Run Docker in rootless mode or use [Podman](../entities/podman.md)

### Resource Limits

- Set memory and CPU limits to prevent DoS
- Limit file descriptors and process counts via `--ulimit`
- Limit restart count

### Network Security

- Bind published ports to `127.0.0.1` — Docker bypasses UFW/iptables rules
- Use `ufw-docker` or equivalent if firewall integration needed
- Use Kubernetes NetworkPolicies for pod-level control

## Base Image Selection

| Image         | Size     | Shell   | Recommended For                      |
| ------------- | -------- | ------- | ------------------------------------ |
| `scratch`     | ~0 MB    | No      | Statically compiled Go/Rust binaries |
| `distroless`  | ~2–20 MB | No      | Java, Python, Node.js production     |
| `alpine`      | ~5 MB    | Limited | General purpose (musl, not glibc)    |
| `debian-slim` | ~25 MB   | Yes     | When glibc compatibility required    |
| `ubuntu`      | ~75 MB   | Yes     | Dev/debugging only                   |

Distroless eliminates shell escape vectors. Scratch is the smallest possible attack surface. See [Distroless Images](distroless-images.md) for the design pattern and the Google [distroless](../entities/distroless.md) vs [Chainguard](../entities/chainguard.md)/[Wolfi](../entities/wolfi.md) comparison.

## Image Security

- Tag with Git SHA, never `latest` in production
- Multi-stage builds: discard build toolchain in final image
- Run container scanning in CI/CD: Trivy, Clair, Snyk, Grype — fail on CRITICAL/HIGH
- Scan for secrets: ggshield, SecretScanner
- Sign images with Cosign; enforce signature verification at admission with Kyverno/OPA
- Generate SBOMs for [supply chain security](supply-chain-security.md)
- Layer ordering: least-frequently-changed instructions first (system deps → app deps → source code)
- `.dockerignore`: exclude `.env`, `*.key`, `.git`, `node_modules`

## ENV Security Caution

`ENV` lines create image layers. Sensitive values set with `ENV` persist in layer history even if unset in later layers — any `docker history` or layer export reveals them. **Never set secrets via `ENV`**. Use build secrets (`--secret`) or runtime injection.

## PID 1 and Signal Handling

When the app process is PID 1, it fails to reap zombie processes and may not forward SIGTERM to child processes. Use `tini` or `dumb-init` as PID 1:

```dockerfile
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["python", "app.py"]
```

Apps must handle SIGTERM gracefully (close connections, finish in-flight requests) — see K8s graceful shutdown: `terminationGracePeriodSeconds` + `preStop` sleep.

## Runtime Monitoring

- Behavioral monitoring: Falco, Tetragon, Cilium eBPF
- Detect unexpected syscalls, privilege escalation, unusual network activity

## Kubernetes Security Context

Key fields:

```yaml
securityContext:
  runAsUser: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop: [ALL]
    add: ["NET_BIND_SERVICE"] # only if needed
```

## Node.js Docker Security

Additional practices when running Node.js in Docker — see [Node.js Security](nodejs-security.md):

- Pin base image with SHA256 digest: `FROM node:lts-alpine@sha256:<hash>`.
- Set `ENV NODE_ENV production` to enable Express/framework security optimizations.
- Use `dumb-init` as PID 1: `CMD ["dumb-init", "node", "server.js"]` — Node.js as PID 1 ignores SIGTERM.
- `npm` client does not forward OS signals — invoke node directly.
- Multi-stage builds to avoid leaking `NPM_TOKEN` into image history.
- Docker build secrets (`--mount=type=secret`) for `.npmrc` with private registry tokens.

## Kernel Security Layers

Three independent kernel enforcement layers — all should be active ([defense-in-depth](defense-in-depth.md)):

| Layer | Mechanism | Granularity |
| --- | --- | --- |
| [Linux Capabilities](linux-capabilities.md) | Drop CAP\_\* units | Coarse privilege units |
| [Seccomp](seccomp.md) | Syscall allowlisting via BPF | Per-syscall |
| [AppArmor](../entities/apparmor.md) / SELinux | MAC path/label policy | File/network/capability access |

Docker applies `docker-default` seccomp and AppArmor profiles automatically. Override with `--security-opt seccomp=...` and `--security-opt apparmor=...`.

## Runtime API and Daemon Exposure

A container with correct seccomp, capabilities, and AppArmor can still be one API call from host compromise if a runtime socket is mounted inside it. The kernel isolation works correctly — the management plane is exposed.

**Common high-value sockets:**

```
/var/run/docker.sock   /run/containerd/containerd.sock
/var/run/crio/crio.sock  /run/podman/podman.sock
/var/run/kubelet.sock  /run/buildkit/buildkitd.sock
```

Absence of a CLI client doesn't protect the socket — Docker speaks plain HTTP over the Unix socket and `curl` is sufficient:

```bash
curl --unix-socket /var/run/docker.sock http://localhost/_ping
```

Remote daemon exposure on `tcp://...:2375` (no TLS) is effectively a remote root interface.

See [HackTricks — Runtime API and Daemon Exposure](../sources/hacktricks-runtime-api-daemon-exposure.md).

## Authorization Plugins (Docker)

Docker authz plugins narrow the default "all-or-nothing" daemon access model, but safety depends on complete API surface coverage. Common bypass classes:

- `docker exec` grants privilege after unprivileged container creation
- Raw API field shape mismatch (top-level `Binds` vs `HostConfig.Binds`)
- Unfiltered capability attributes (`CapAdd: ["SYS_ADMIN"]`)
- Plugin management operations not blocked → disable the plugin

See [HackTricks — Runtime Authorization Plugins](../sources/hacktricks-authorization-plugins.md).

## Sensitive Host Mounts

Dangerous mounts beyond `/`:

| Mount | Risk |
| --- | --- |
| `/proc/sys/kernel/core_pattern` | Host code execution on crash |
| `/proc/sys/kernel/modprobe` | Redirect kernel module-loader helper |
| `/proc/sysrq-trigger` | Host DoS (immediate reboot) |
| `/sys/kernel/uevent_helper` | Host code execution on uevent |
| `/sys/kernel/debug` | Wide kernel debug surface |
| `/var` | Service-account tokens, container snapshots, runtime sockets |

Mounted `/var` on a Kubernetes node often gives access to other pods' projected service-account tokens, which can escalate to cluster-wide compromise.

See [HackTricks — Sensitive Host Mounts](../sources/hacktricks-sensitive-host-mounts.md).

## Assessment Triage (Modern Context)

Before applying older escape techniques, verify:

1. **Rootful vs rootless / userns-remapped** — `cat /proc/self/uid_map`
2. **cgroup v1 vs v2** — `stat -fc %T /sys/fs/cgroup` (`cgroup2fs` = v2, `release_agent` chains mostly irrelevant)
3. **seccomp/AppArmor explicit or inherited** — `grep -E 'Seccomp|NoNewPrivs' /proc/self/status`
4. **K8s PSS label enforcing or just warning** — `kubectl get ns $NS -o jsonpath='{.metadata.labels}'`

Assessment tools: `linpeas`, `CDK`, `amicontained`, `deepce`, `Tracee`, `Inspektor Gadget`.

See [HackTricks — Container Assessment and Hardening](../sources/hacktricks-assessment-and-hardening.md).

## Sources

- [OWASP Docker Security Cheat Sheet](../sources/owasp-docker-security.md)
- [OWASP Node.js Docker Cheat Sheet](../sources/owasp-nodejs-docker.md)
- [Kubernetes Best Practices — Container Guide](../sources/k8s-best-practices-container.md)
- [Docker Build Best Practices (Official)](../sources/docker-build-best-practices.md)
- [Linux Capabilities](linux-capabilities.md) — capability sets, file caps, privilege escalation
- [Docker AppArmor Profiles](../sources/docker-apparmor.md) — docker-default profile, custom profiles
- [Docker Seccomp Profiles](../sources/docker-seccomp.md) — default syscall blocklist
- [HackTricks — Runtime API and Daemon Exposure](../sources/hacktricks-runtime-api-daemon-exposure.md)
- [HackTricks — Runtime Authorization Plugins](../sources/hacktricks-authorization-plugins.md)
- [HackTricks — Sensitive Host Mounts](../sources/hacktricks-sensitive-host-mounts.md)
- [HackTricks — Container Assessment and Hardening](../sources/hacktricks-assessment-and-hardening.md)
