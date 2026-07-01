---
title: "Tilt FAQ: Help, Errors & Cluster Setup"
tags: [tilt, faq, kubernetes, docker]
sources: [tilt-faq]
updated: 2026-07-01
---

# Tilt FAQ: Help, Errors & Cluster Setup

Official FAQ from [docs.tilt.dev/faq.html](https://docs.tilt.dev/faq.html). Covers getting help, common error messages, Docker configuration, and Kubernetes cluster selection.

## Getting Help

- **Slack:** `#tilt` channel on the Kubernetes Slack (invite at slack.k8s.io)
- **GitHub:** file issues at github.com/tilt-dev/tilt/issues

## Common Error Messages

### "template engine not found for: version"

Running `tilt version` produces this? You're running the wrong Tilt — the Ruby template engine also named Tilt is shadowing [[tilt]]. Fixes:

- Delete the Ruby Tilt binary
- Always invoke via absolute path
- Rename the Tilt binary to `tlt` (it's a static binary, renaming is safe)

### "WARNING: Image not used in any deploy config"

[[tilt]] needs two things to start your app:

1. A build instruction — e.g. `docker_build()` in the [[tiltfile]]
2. A run instruction — e.g. `k8s_yaml()` in the [[tiltfile]]

This warning means a built image has no matching deploy config. Check for a missing Kubernetes YAML or a misspelled image name.

### "unauthorized: You don't have the needed permissions" (push errors)

Tilt is trying to push to a remote registry because it thinks you're targeting a remote cluster. See [Cluster Selection](#cluster-selection) below to point Tilt at a local cluster.

### "Unable to connect to cluster"

The [[kubernetes]] server is misbehaving. Try in order:

1. Restart the cluster (off → on)
2. Reset cluster state

| Environment    | Restart                                   | Reset state         |
| -------------- | ----------------------------------------- | ------------------- |
| Docker for Mac | Preferences → Kubernetes → disable/enable | Preferences → Reset |
| Minikube       | `minikube stop && minikube start`         | `minikube delete`   |

## Dynamic App Configuration

The [[tiltfile]] API provides built-in config functions:

| Function                    | Purpose                      |
| --------------------------- | ---------------------------- |
| `os.environ.get('VAR', '')` | Read an environment variable |
| `read_file('./path')`       | Read any file                |
| `read_json('./path')`       | Parse a JSON file            |
| `read_yaml('./path')`       | Parse a YAML file            |
| `local()`                   | Run a local shell command    |

Custom flags for `tilt up` can be defined with the [config API](https://docs.tilt.dev/tiltfile_config.html).

## Docker Configuration

### Finding Built Images

If [[docker]] images built by Tilt aren't visible via the Docker CLI, Tilt may be connected to the in-cluster Docker daemon (automatic with Minikube or MicroK8s). Diagnose with:

```sh
tilt doctor          # shows Docker host Tilt is using
DOCKER_HOST=tcp://my-url/ docker images   # query that host directly
```

### In-Cluster Image Building (no remote push)

For local clusters (Docker for Mac, Minikube, MicroK8s), Tilt builds images directly inside the cluster — no push to a remote registry needed. Tilt also sets `ImageNeverPull` on Kubernetes configs automatically in this case.

### Docker BuildKit

Tilt enables BuildKit automatically when the local Docker installation supports it:

- Docker v18.06 (with Experimental mode)
- Docker v18.09+

To disable: `DOCKER_BUILDKIT=0`

### Remote Docker Server

Tilt respects the same environment variables as the `docker` CLI:

| Variable                  | Purpose                                  |
| ------------------------- | ---------------------------------------- |
| `DOCKER_HOST`             | URL of the Docker server                 |
| `DOCKER_API_VERSION`      | API version                              |
| `DOCKER_CERT_PATH`        | Path to TLS certificates                 |
| `DOCKER_TLS_VERIFY`       | Enable TLS verification (off by default) |
| `DOCKER_DEFAULT_PLATFORM` | Target architecture for built images     |

## Cluster Selection

Tilt uses whichever [[kubernetes]] cluster is the current `kubectl` context.

```sh
kubectl config current-context      # see active cluster
kubectl config get-contexts         # list available clusters
kubectl config use-context docker-desktop   # switch cluster
```

Common local context names: `microk8s`, `docker-desktop`, `docker-for-desktop`.

### How Tilt Auto-Detects Cluster Type

Run `tilt doctor` — the `Env` field shows the detected cluster type. Detection relies on context name prefixes:

| Prefix / Name              | Cluster        |
| -------------------------- | -------------- |
| `docker-`                  | Docker Desktop |
| `gke_`                     | GKE            |
| `kind-`                    | KIND           |
| `minikube` or `minikube-*` | Minikube       |

If detection fails, check whether the context name follows the expected prefix convention.

### Choosing a Local Cluster

See the official [Guide to Choosing a Local Cluster](https://docs.tilt.dev/choosing_clusters.html). See also [[tilt-debug-faq]] for deeper troubleshooting.
