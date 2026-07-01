---
title: "Tilt Tutorial Part 1: Prerequisites & Installation"
tags: [tilt, docker, kubernetes, installation]
sources: [tilt-tutorial-1-prerequisites]
updated: 2026-07-01
---

# Tilt Tutorial Part 1: Prerequisites & Installation

First step in the official [[tilt]] tutorial series. Covers what you need installed before running the hands-on walkthrough. The sample project uses [[docker]] for image builds and [[kubernetes]] for running services, though Tilt supports many other backends (Helm, podman, local processes).

## Prerequisites

| Tool   | Required to follow interactively | Notes                                   |
| ------ | -------------------------------- | --------------------------------------- |
| Tilt   | Yes                              | Any recent version                      |
| Docker | Yes                              | Desktop (Mac/Windows) or Engine (Linux) |
| K8s    | Not for Part 1                   | Introduced in later tutorial steps      |

You can skip installation and read along on the web — interactive steps begin in Part 2 ([[tilt-tutorial-2-tilt-up]]).

## Install Tilt

### macOS / Linux

Uses Homebrew if present, falls back to a direct binary download:

```bash
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
```

### Windows

Uses Scoop if present, falls back to a direct binary download:

```powershell
iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.ps1'))
```

For other methods (package managers, manual binary) see the [Alternative Installations guide](https://docs.tilt.dev/install.html#alternative-installations) — also summarised in [[tilt-install]].

## Install Docker

Official install paths by platform:

- **macOS** — Docker Desktop for Mac
- **Windows** — Docker Desktop for Windows (supports WSL)
- **Linux** — distro-specific packages (Ubuntu, etc.) or a convenience script:

```bash
curl -fsSL https://get.docker.com | sh
```

### Linux gotcha: non-root access

After installing on Linux, follow the [Manage Docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) post-install guide. Without it, you must run `tilt up` with `sudo`. Note the security trade-offs documented in that guide.

### Smoke test

```bash
docker run --rm hello-world
```

Expect Docker to pull the `hello-world` image and print a greeting. If it fails, consult Docker's troubleshooting guides for macOS or Windows.

## Flexibility note

Tilt is not locked to Docker + Kubernetes. After completing the fundamentals in this tutorial, guides exist for:

- [[helm]] charts
- podman
- Local (non-container) processes

See [[tilt-choosing-clusters]] for cluster/runtime selection options.
