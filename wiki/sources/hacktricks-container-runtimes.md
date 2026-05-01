---
title: "HackTricks — Container Runtimes and Engines"
tags: [container, runtime, docker, podman, kubernetes, oci, security, escape]
sources: [hacktricks-container-runtimes.md]
updated: 2026-05-01
---

# HackTricks — Container Runtimes and Engines

Precise breakdown of the container ecosystem by layer role, aimed at security practitioners who need to reason accurately about where a protection or weakness lives.

## Why Precision Matters

"Docker" can mean: image format, CLI, daemon, build system, runtime stack. For security work this ambiguity is a problem because different layers enforce different protections. A bad bind-mount is not the same as a low-level runtime bug, and neither is the same as a Kubernetes policy mistake.

## OCI: The Common Language

| Spec                  | What it defines                                                   |
| --------------------- | ----------------------------------------------------------------- |
| OCI Image Spec        | Image layers and metadata format                                  |
| OCI Runtime Spec      | How to launch the process (namespaces, mounts, cgroups, security) |
| OCI Distribution Spec | Registry API for pushing/pulling images                           |

OCI allows images built by one tool to run on another, and allows multiple engines to share the same low-level runtime.

## Low-Level OCI Runtimes (Closest to Kernel)

This is the layer that creates namespaces, sets cgroup limits, applies capabilities/seccomp, and `execve()`s the container process.

### `runc`

Reference OCI runtime. Used under Docker, containerd, many Kubernetes deployments. Most public exploit research targets `runc`-style environments because they define the baseline.

### `crun`

Written in C. Primary runtime for modern Podman. Strong cgroup v2 and rootless support. Security role is identical to `runc`: translates OCI config into a kernel-enforced process tree.

### `runsc` (gVisor)

Inserts a **userspace kernel layer** between the workload and the host kernel. Not a standard `runc` container — different sandbox design with compatibility/performance tradeoffs and significantly reduced host-kernel attack surface.

### `kata-runtime` (Kata Containers)

Launches the workload in a **lightweight VM**. Administratively looks like a container, but the isolation boundary is closer to virtualization. Classic `runc` breakout PoCs typically do not apply.

## Engines and Container Managers

The engine is what users and operators interact with. It handles image pulls, networking, logging, lifecycle, and API exposure. **Access to a runtime socket or API is often equivalent to host compromise.**

### Docker Engine

Most recognizable. Path: `docker` CLI → `dockerd` → `containerd` → `runc`. Historically rootful. Docker socket (`docker.sock`) is a critical privilege escalation primitive — if a process can reach `dockerd`, it can launch privileged containers, mount host paths, or join host namespaces without any kernel exploit.

### Podman

Daemonless design. Stronger **rootless** default story. Often combined with user namespaces, SELinux, and `crun`. Doesn't eliminate risk, but changes the default risk profile significantly.

### containerd

Core runtime component used under Docker and as a Kubernetes CRI backend. Manages images, snapshots, and delegates to `runc`/`crun`. Access to the containerd socket or `ctr`/`nerdctl` is as dangerous as Docker API access.

### CRI-O

Focused on implementing the Kubernetes CRI cleanly. Common in Kubernetes distributions and SELinux-heavy environments (OpenShift). Narrower scope than Docker Engine.

### Incus / LXD / LXC

**System containers** — expected to look like lightweight machines with fuller userspace. Isolation mechanisms are still kernel primitives but operational expectations differ. Misconfigurations look like virtualization mistakes rather than app-container defaults.

### systemd-nspawn

Useful for testing and distro-oriented OS environments. Not the dominant production runtime. Reminder that "container" spans many ecosystems.

### Apptainer / Singularity

Common in HPC/research. Trust assumptions and execution model differ substantially from Docker/Kubernetes stacks. Users run packaged workloads without broad container-management powers.

## Build-Time Tooling

Build time determines image contents, secrets exposure, and embedded trust.

| Tool                       | Role                                                          |
| -------------------------- | ------------------------------------------------------------- |
| BuildKit / `docker buildx` | Modern Docker build: caching, secret mounting, SSH forwarding |
| Buildah                    | OCI-native build in Podman ecosystem                          |
| Kaniko                     | CI-safe builds without privileged Docker daemon               |

Security risk: secrets can leak into image layers; broad build context exposes files that should not be included. **A weak build pipeline creates a weak runtime posture.**

## Kubernetes ≠ Runtime

Kubernetes is the orchestrator. It schedules Pods and expresses security policy through workload config. The kubelet speaks CRI to containerd or CRI-O, which invokes `runc`/`crun`/`runsc`/`kata-runtime`.

Many people wrongly attribute a protection to "Kubernetes" when it's actually enforced by the node runtime — or blame "containerd defaults" for behavior that came from a Pod spec.

## Runtime CVEs (Not Just Misconfig)

A correctly-configured container can still be exposed through runtime bugs:

**CVE-2019-5736** (`runc`): malicious container overwrites the host `runc` binary; triggered on `docker exec`. Ordinary in-container code execution compromises the host.

**CVE-2024-21626** (`runc`): working directory escape via `WORKDIR` path manipulation.

BuildKit mount races and containerd parsing bugs follow the same pattern — **runtime version and patch level are part of the security boundary.**

## Assessment Quick Reference

| Observation                           | Implication                                       |
| ------------------------------------- | ------------------------------------------------- |
| Rootless Podman                       | User namespaces likely; different privesc surface |
| Docker socket mounted                 | API-level host compromise without kernel exploit  |
| CRI-O / OpenShift node                | Think SELinux labels + restricted workload policy |
| gVisor / Kata environment             | Classic `runc` PoCs may not apply                 |
| Rootful container with `--privileged` | Treat as host root access                         |

## Key Takeaways

- Identify engine + runtime early: predicts likely breakout families before reading any app code
- Docker socket = host root if reachable from inside a container
- gVisor/Kata have fundamentally different isolation properties from `runc`-based containers
- Kubernetes orchestration and runtime enforcement are separate layers — don't conflate them
- Runtime CVEs can compromise the host from a "correctly configured" container

## Related Pages

- [Container Security](../concepts/container-security.md)
- [Linux Capabilities](../concepts/linux-capabilities.md)
- [Seccomp](../concepts/seccomp.md)
- [Pod Security](../concepts/pod-security.md)
- [Docker](../entities/docker.md)
- [Podman](../entities/podman.md)
- [Kubernetes](../entities/kubernetes.md)
- [HackTricks Container Security](hacktricks-container-security.md)
- [HackTricks](../entities/hacktricks.md)
