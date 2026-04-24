# Creating a K8s Cluster with Zarf

## Overview

This tutorial demonstrates deploying a k3s cluster on a fresh Linux machine using Zarf's k3s component.

## System Requirements

- Root access on a Linux machine (not just sudo privileges)

**Important:** The 'k3s' component requires root access (not just `sudo`!) when deploying as it will modify your host machine to install the cluster.

## Prerequisites

Before starting, you'll need:

- The Zarf repository cloned locally
- Zarf binary installed on your $PATH
- A built or downloaded init-package

## Creating the Cluster

1. Run the initialization command with root privileges:

```bash
# zarf init
```

2. When prompted, confirm package deployment by selecting `y` and pressing enter.

3. When prompted again, confirm k3s component deployment the same way.

**Tip:** You can automate both confirmations using flags:

```bash
zarf init --components="k3s" --confirm
```

## Validating the Deployment

After completion, you should see a running k3s cluster with several zarf pods in the zarf namespace.

## Accessing the Cluster as a Normal User

By default, only the root user gets cluster access. To configure access for other users, copy and adjust permissions:

```bash
# cp /root/.kube/config /home/otheruser/.kube
# chown otheruser /home/otheruser/.kube/config
# chgrp otheruser /home/otheruser/.kube/config
```

## Cleaning Up

Remove all created resources and the cluster using:

```bash
zarf destroy --confirm
```
