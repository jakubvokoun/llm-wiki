---
title: "Tilt Installation Guide"
tags: [tilt, kubernetes, docker, devtools]
sources: [tilt-install]
updated: 2026-07-01
---

# Tilt Installation Guide

Reference for installing [[tilt]] on macOS, Linux, and Windows. Covers prerequisites, per-OS quick-start steps, package manager options, manual binary download, and verification.

## Prerequisites

All platforms require:

- [[docker]] — to build containers
- `kubectl` — to query the cluster
- A local [[kubernetes]] cluster

## Quick Install (per OS)

| OS      | Command                                                                                                                         |
| ------- | ------------------------------------------------------------------------------------------------------------------------------- |
| macOS   | `curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh \| bash`                                  |
| Linux   | `curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh \| bash`                                  |
| Windows | `iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.ps1'))` |

The one-step scripts detect an available package manager (Homebrew or Scoop) and fall back to downloading a static binary.

## macOS Setup

1. Install [Docker for Mac](https://docs.docker.com/docker-for-mac/install/) — bundles Docker, kubectl, and a Kubernetes cluster.
2. Enable Kubernetes in Docker Desktop preferences.
3. Set the active context:
   ```
   kubectl config use-context docker-desktop
   ```
4. Run the install script above.

## Linux Setup

1. Install [Docker](https://docs.docker.com/install/) and configure it for [non-root access](https://docs.docker.com/install/linux/linux-postinstall/).
2. Install `kubectl`.
3. Install [ctlptl](https://github.com/tilt-dev/ctlptl) and use it to create a Kind cluster with a local registry.
4. Run the install script above.

> Ubuntu users may prefer Microk8s over Kind — see the Choosing a Local Dev Cluster guide for options.

## Windows Setup

1. Install [Docker for Windows](https://docs.docker.com/docker-for-windows/install/) — bundles Docker, kubectl, and a Kubernetes cluster.
2. Enable Kubernetes in Docker Desktop preferences.
3. Set the active context:
   ```
   kubectl config use-context docker-desktop
   ```
4. Run the PowerShell install script above.
5. If [Scoop](https://scoop.sh) is present the installer uses it automatically, making [[tilt-upgrade]] easy. Otherwise add the install directory to `$PATH` or create an alias.

## Package Managers

### Homebrew (macOS or Linux)

```
brew install tilt
```

### Scoop (Windows)

```
scoop bucket add tilt-dev https://github.com/tilt-dev/scoop-bucket
scoop install tilt
```

### Conda Forge

```
conda config --add channels conda-forge
conda install tilt
```

### asdf

```
asdf plugin add tilt
asdf install tilt 0.37.4
asdf global tilt 0.37.4
```

## Manual Binary Install

If no package manager is available the one-step script downloads a static binary and places it in `~/.local/bin`, `/usr/local/bin`, or `~/bin` depending on the OS and existing `$PATH`.

To download manually (replace version as needed — check [GitHub Releases](https://github.com/tilt-dev/tilt/releases)):

**macOS:**

```
curl -fsSL https://github.com/tilt-dev/tilt/releases/download/v0.37.4/tilt.0.37.4.mac.x86_64.tar.gz | tar -xzv tilt && \
  sudo mv tilt /usr/local/bin/tilt
```

**Linux:**

```
curl -fsSL https://github.com/tilt-dev/tilt/releases/download/v0.37.4/tilt.0.37.4.linux.x86_64.tar.gz | tar -xzv tilt && \
  sudo mv tilt /usr/local/bin/tilt
```

**Windows (PowerShell):**

```
Invoke-WebRequest "https://github.com/tilt-dev/tilt/releases/download/v0.37.4/tilt.0.37.4.windows.x86_64.zip" -OutFile "tilt.zip"
Expand-Archive "tilt.zip" -DestinationPath "tilt"
Move-Item -Force -Path "tilt\tilt.exe" -Destination "$home\bin\tilt.exe"
```

## Building from Source

Requires Go and TypeScript/JavaScript toolchains; TypeScript is compiled dynamically on every run. Only recommended when contributing to Tilt itself — see [CONTRIBUTING.md](https://github.com/tilt-dev/tilt/blob/master/CONTRIBUTING.md).

## Verify

```
tilt version
```

## Gotchas

- On **Windows without Scoop**, the installer does not add Tilt to `$PATH` automatically — you must add the install directory manually or create an alias.
- On **Linux**, Docker must be configured for non-root use before running the install script; otherwise Tilt cannot communicate with the Docker daemon.
- **Conda Forge** and **asdf** installs are available but less commonly used; the Homebrew/Scoop paths are the recommended package-manager routes.
