---
title: "Container Security"
tags: [containers, security, hardening, docker, kubernetes, capabilities]
sources: [owasp-docker-security.md, linux-capabilities-man7.md]
updated: 2026-04-16
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

Distroless eliminates shell escape vectors. Scratch is the smallest possible attack surface.

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

Three independent kernel enforcement layers — all should be active
([defense-in-depth](defense-in-depth.md)):

| Layer                                         | Mechanism                    | Granularity                    |
| --------------------------------------------- | ---------------------------- | ------------------------------ |
| [Linux Capabilities](linux-capabilities.md)   | Drop CAP\_\* units           | Coarse privilege units         |
| [Seccomp](seccomp.md)                         | Syscall allowlisting via BPF | Per-syscall                    |
| [AppArmor](../entities/apparmor.md) / SELinux | MAC path/label policy        | File/network/capability access |

Docker applies `docker-default` seccomp and AppArmor profiles automatically.
Override with `--security-opt seccomp=...` and `--security-opt apparmor=...`.

## Sources

- [OWASP Docker Security Cheat Sheet](../sources/owasp-docker-security.md)
- [OWASP Node.js Docker Cheat Sheet](../sources/owasp-nodejs-docker.md)
- [Kubernetes Best Practices — Container Guide](../sources/k8s-best-practices-container.md)
- [Docker Build Best Practices (Official)](../sources/docker-build-best-practices.md)
- [Linux Capabilities](linux-capabilities.md) — capability sets, file caps, privilege escalation
- [Docker AppArmor Profiles](../sources/docker-apparmor.md) — docker-default profile, custom profiles
- [Docker Seccomp Profiles](../sources/docker-seccomp.md) — default syscall blocklist
