---
title: "Kubernetes Best Practices 101 — Container Guide (diegolnasc)"
tags:
  [
    containers,
    docker,
    dockerfile,
    security,
    image-scanning,
    cosign,
    tini,
    graceful-shutdown,
  ]
sources: [k8s-best-practices-container.md]
updated: 2026-04-16
---

# Kubernetes Best Practices — Container Guide

Companion deep-dive on container construction best practices: image selection, Dockerfile patterns, security hardening, runtime concerns, and observability.

## Key Takeaways

### Stateless Design

Containers must be stateless: no local state. Persistent data goes to external storage (K8s PersistentVolumes, external databases).

### Base Image Selection

| Image         | Size     | Shell         | Use Case                                   |
| ------------- | -------- | ------------- | ------------------------------------------ |
| `scratch`     | ~0 MB    | No            | Statically compiled Go/Rust binaries       |
| `distroless`  | ~2–20 MB | No            | Java, Python, Node.js production           |
| `alpine`      | ~5 MB    | Yes (limited) | General purpose; note: musl libc not glibc |
| `debian-slim` | ~25 MB   | Yes           | When glibc compatibility required          |
| `ubuntu`      | ~75 MB   | Yes           | Dev/debugging only                         |

Recommendations: Go/Rust → `scratch` or `distroless/static`; Java → `distroless/java`; Python → `distroless/python3`; Node.js → `distroless/nodejs`.

### Image Tagging

- Never use `latest` in production — mutable, unpredictable rollbacks
- Prefer Git SHA tags (`myapp:a1b2c3d`) for traceability
- Combined: `myapp:1.2.3-a1b2c3d`

### Dockerfile Best Practices

1. **Multi-stage builds**: Keep final image lean; discard build toolchain
2. **Layer ordering**: Least-frequently-changed instructions first (system deps → app deps → source code)
3. **BuildKit cache mounts**: `--mount=type=cache` for pip/npm/go modules
4. **ENTRYPOINT + CMD**: ENTRYPOINT = executable, CMD = default overridable args
5. **COPY over ADD**: ADD has implicit behavior (URL fetch, tar extraction) — use COPY unless you need those
6. **`.dockerignore`**: Exclude `.git`, `node_modules`, `.env`, `*.key`, `dist`, `docs`

### Security

- Non-root: create dedicated user in Dockerfile; set `runAsNonRoot: true` in K8s securityContext
- Read-only filesystem: `readOnlyRootFilesystem: true`; mount writable emptyDir for `/tmp`, caches
- Drop all capabilities + add only required: `capabilities.drop: [ALL]`
- Distroless/scratch images eliminate shell escape vectors
- **Image scanning**: Trivy (open source, CI-friendly), Snyk, Grype, Clair — fail on CRITICAL/HIGH
- **Signed images**: Cosign (`cosign sign`) + Kyverno ClusterPolicy to enforce signature verification at admission time
- OCI labels: include `org.opencontainers.image.revision` (Git SHA) for traceability

### PID 1 and Signal Handling

Default app process as PID 1 causes two problems:

1. Zombie process reaping failure
2. SIGTERM not forwarded to children

Solution: use `tini` or `dumb-init` as PID 1:

```dockerfile
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["python", "app.py"]
```

### Graceful Shutdown

Handle SIGTERM in all languages:

- Python: `signal.signal(signal.SIGTERM, handler)`
- Node.js: `process.on('SIGTERM', () => server.close(...))`
- Go: `signal.Notify(quit, syscall.SIGTERM, syscall.SIGINT)` + context timeout

K8s: set `terminationGracePeriodSeconds`; use `preStop: exec: sleep 5` to drain load balancer before stopping.

### Container Health Checks

- Docker `HEALTHCHECK` instruction for standalone use
- In K8s, prefer `livenessProbe` + `readinessProbe` — provides more orchestrator integration

### Observability

- Log to stdout/stderr in JSON (structured logging) — never to files
- Include `correlation_id` in every log entry
- Apply OCI labels with `BUILD_DATE` and `GIT_SHA` for image provenance

## Sources

- [Raw: k8s-best-practices-container.md](../../raw/k8s-best-practices-container.md)
