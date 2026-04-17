---
title: "Docker Build Best Practices (Official Documentation)"
tags:
  [docker, dockerfile, build, cache, multi-stage, image-security, docker-scout]
sources: [docker-build-best-practices.md]
updated: 2026-04-16
---

# Docker Build Best Practices (Official Documentation)

Official Docker guidance on building efficient, maintainable, and secure Docker images.

## Key Takeaways

### Multi-Stage Builds

- Separate build and production stages; final image contains only runtime artifacts
- Create shared base stages when multiple images share common layers (DRY, cache efficiency)
- Build stages can execute in parallel for faster CI

### Base Image Selection

Use trusted sources in this order of preference:

1. **Docker Official Images** — curated, documented, regularly updated
2. **Verified Publisher** — authenticated by Docker
3. **Docker-Sponsored Open Source** — community projects with Docker sponsorship

Choose minimal images: Alpine (< 6 MB) recommended as general-purpose base.

### Rebuild Images Often

- Images are immutable snapshots — base images accumulate CVEs over time
- Use `--pull` to force re-fetching the base image (gets latest security patches)
- Use `--no-cache` for clean dependency install from package managers
- Combined: `docker build --pull --no-cache -t myapp:sha .`

### Pin Base Image Versions

- Tags are mutable: `alpine:3.21` may point to different digests over time
- Pin to SHA256 digest for supply chain integrity: `FROM alpine:3.21@sha256:...`
- **Docker Scout** can automate base image update PRs when a newer digest is available

### .dockerignore

Exclude files that bloat build context or risk leaking sensitive data: `.git`, `.env`, `*.key`, `node_modules`, `dist`, `docs`.

### Ephemeral Containers

Containers must be stateless and ephemeral (12-Factor App principle). State → external storage.

### One Concern Per Container

Separate concerns: web app, database, cache → separate containers. Enables horizontal scaling and reuse.

### Build Cache Leverage

Cache invalidation propagates forward: when a layer changes, all subsequent layers rebuild. Order instructions from least to most frequently changed.

### RUN Best Practices

- Always combine `apt-get update && apt-get install` in one `RUN` to prevent stale cache
- Clean up in the same layer: `&& rm -rf /var/lib/apt/lists/*`
- Use `set -o pipefail &&` before piped commands so failures in non-terminal pipe stages fail the build
- Use `--no-install-recommends` to avoid unnecessary packages

### ENV Security Concern

Each `ENV` line creates a new image layer. Setting a sensitive variable and unsetting it in a later layer still exposes the value in the intermediate layer:

```dockerfile
# ❌ Bad: ADMIN_USER is visible in image history even after unset
ENV ADMIN_USER="mark"
RUN unset ADMIN_USER

# ✅ Good: Set, use, and unset in single layer
RUN export ADMIN_USER="mark" && echo $ADMIN_USER > /mark && unset ADMIN_USER
```

Never set secrets via `ENV` — use build secrets (`--secret`) or runtime secret injection.

### ADD vs COPY

- **COPY**: default for local files (explicit, safe)
- **ADD**: use when you need remote URL fetch with checksum (`ADD --checksum=sha256:...`) or tar auto-extraction
- **Bind mounts**: `RUN --mount=type=bind,...` for temp files needed only during build (not persisted in image)

### ENTRYPOINT

- Set main command via `ENTRYPOINT`, default args via `CMD`
- Helper entrypoint scripts must use `exec "$@"` to become PID 1 and receive signals correctly
- Avoid `sudo`; use `gosu` for privilege de-escalation

### USER

- Run as non-root: create dedicated user in Dockerfile
- Use explicit UID/GID (non-deterministic by default)
- Use `--no-log-init` with `useradd` to avoid disk exhaustion from Go bug in sparse file handling

## Sources

- [Raw: docker-build-best-practices.md](../../raw/docker-build-best-practices.md)
