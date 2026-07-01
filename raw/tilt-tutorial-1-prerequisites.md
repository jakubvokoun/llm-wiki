---
source_url: https://docs.tilt.dev/tutorial/1-prerequisites.html
fetched: 2026-07-01
---

# Preparation (Optional)

## Tilt Tutorial

For this tutorial, we'll focus on Tilt fundamentals by walking through a sample project.

Our sample project uses Docker for building container images and Kubernetes for running them.
However, it's possible to use Tilt without Docker or Kubernetes!
Tilt is incredibly flexible and supports a variety of ways to build and run your services during local development.

We won't actually dive into a Dockerfile or Kubernetes YAML, since that's out of scope for this introduction.

To follow along interactively, you'll need to have Docker and Tilt installed on your machine.

Prefer not to download additional tools?
You can still follow along on the web - go ahead and skip to the [next section](./2-tilt-up.html)!

> 💁‍♀️ **Not using Kubernetes or Docker?**
>
> We've got plenty of guides for using Tilt with Helm, podman, local processes, and more to help you get started after learning the Tilt fundamentals from this tutorial.

## Install Tilt

On macOS/Linux, we've got an install script that will use [Homebrew](https://brew.sh) if available (and a direct download otherwise):

```
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
```

On Windows, we've got an install script that will use [Scoop](https://scoop.sh/) if available (and a direct download otherwise):

```
iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.ps1'))
```

If you'd rather install manually or via another method, refer to the guide on [Alternative Installations](/install.html#alternative-installations).

## Install Docker

Docker provides comprehensive [install instructions](https://docs.docker.com/get-docker/) for all supported OSes and Linux distributions:

* [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/)
* [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/) (including WSL)
* Docker for Linux
  + [Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
  + [Direct from binary](https://docs.docker.com/engine/install/binaries/)
  + [All other distributions](https://docs.docker.com/engine/install/#server)
  + Convenience script (auto-detects distribution):

    ```
    curl -fsSL https://get.docker.com | sh
    ```

> 💡 On Linux, following the [Manage Docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) post-install guide is suggested so that you don't have to run Tilt with `sudo`.
> (Please take careful note of the security considerations outlined in the guide.)

A quick way to test out your Docker install is to run the `hello-world` container:

```
docker run --rm hello-world
```

You should see some output from Docker as it downloads the `hello-world` image followed by a greeting message with some information about Docker.
If you are having trouble, Docker provides troubleshooting guides for [macOS](https://docs.docker.com/desktop/mac/troubleshoot/) and [Windows](https://docs.docker.com/desktop/windows/troubleshoot/).
