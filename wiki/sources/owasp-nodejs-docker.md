---
title: "OWASP Node.js Docker Cheat Sheet"
tags: [owasp, nodejs, docker, containers, security]
sources: [owasp-nodejs-docker.md]
updated: 2026-04-16
---

# OWASP Node.js Docker Cheat Sheet

## Summary

10 production-grade practices for building secure and optimized Node.js Docker images: deterministic base images, production-only dependencies, non-root user, signal handling with dumb-init, graceful shutdown, multi-stage builds, secret mounting, and `.dockerignore`.

## Key Takeaways

### 1. Explicit and Deterministic Base Images

- Never use `node:latest` — non-deterministic builds.
- Use `node:lts-alpine` (minimal footprint, fewer vulnerabilities).
- Pin with SHA256 digest: `FROM node:lts-alpine@sha256:<hash>`.

### 2. Production Dependencies Only

- `RUN npm ci --omit=dev` — deterministic, production-only install.

### 3. Set NODE_ENV=production

- `ENV NODE_ENV production` — triggers performance/security optimizations in Express and other frameworks.

### 4. Non-Root User

- Use `COPY --chown=node:node . .` plus `USER node`.
- Just setting `USER node` is insufficient — copied files default to root ownership.

### 5. Signal Handling with dumb-init

- Node.js running as PID 1 doesn't respond to SIGTERM/SIGINT properly.
- npm client doesn't forward signals to node process.
- Use `dumb-init` as init process: `CMD ["dumb-init", "node", "server.js"]`.
- Install with `RUN apk add dumb-init`.

### 6. Graceful Shutdown

- Handle `SIGINT` and `SIGTERM` in application code.
- Close server connections, database connections before `process.exit()`.
- Fastify: call `fastify.close()` which returns 503 to new connections during shutdown.

### 7. Vulnerability Scanning

- Use static analysis tools (see Docker Security Cheat Sheet Rule #9).

### 8. Multi-Stage Builds

- Separate build stage (can use full `node:latest` with build tools) from production stage (slim alpine).
- `NPM_TOKEN` and other build secrets visible in `docker history` — use multi-stage to keep secrets out of final image.
- Use `COPY --from=build` to copy `node_modules/` into production image.

### 9. .dockerignore

- Always include `node_modules`, `npm-debug.log`, `.git`, `.gitignore`, `.npmrc`.
- Prevents local `node_modules/` from being copied (overriding the clean npm ci install).
- Prevents secrets (`.env`, `aws.json`) from leaking into image.
- Speeds up builds by avoiding unnecessary cache invalidations.

### 10. Docker Build Secrets for .npmrc

- Use `--mount=type=secret` in `RUN` directive so `.npmrc` is never stored in any image layer.
- Build with: `docker build . --secret id=npmrc,src=.npmrc`.

## Recommended Final Dockerfile Pattern

```dockerfile
FROM node:latest AS build
WORKDIR /usr/src/app
COPY package*.json /usr/src/app/
RUN --mount=type=secret,mode=0644,id=npmrc,target=/usr/src/app/.npmrc npm ci --omit=dev

FROM node:lts-alpine@sha256:<hash>
RUN apk add dumb-init
ENV NODE_ENV production
USER node
WORKDIR /usr/src/app
COPY --chown=node:node --from=build /usr/src/app/node_modules /usr/src/app/node_modules
COPY --chown=node:node . /usr/src/app
CMD ["dumb-init", "node", "server.js"]
```

## Related Pages

- [Container Security](../concepts/container-security.md)
- [Node.js Security](../concepts/nodejs-security.md)
- [Secrets Management](../concepts/secrets-management.md)
- [Docker](../entities/docker.md)
- [OWASP](../entities/owasp.md)
