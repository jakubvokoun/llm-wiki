# Deploying a Retro Arcade

## Introduction

This tutorial builds on previous lessons about creating packages, initializing clusters, and deploying packages. It demonstrates how to deploy a fun retro arcade application to your Kubernetes cluster.

## System Requirements

- Internet connection to download the games example package

## Prerequisites

Before starting, you need:

- The Zarf repository cloned locally
- Zarf binary installed and accessible via your system PATH
- An initialized Kubernetes cluster

## Deploying the Arcade

Deploy the dos-games package using this command:

```
zarf package deploy oci://ghcr.io/zarf-dev/packages/dos-games:1.3.0 --key=https://zarf.dev/cosign.pub
```

If you didn't include the `--confirm` flag, respond with `y` when prompted to proceed with deployment.

### Connecting to the Games

Upon successful deployment, you'll receive output containing commands to access the games. These custom commands leverage `zarf connect` to automatically open your browser and connect to the deployed application within the cluster.

**Note:** The connection persists until you press `ctrl + c` to terminate it.

## Removal

To remove the package:

1. Run `zarf package list` to identify the installed games package
2. Execute `zarf package remove` with the `--confirm` flag to uninstall it

## Troubleshooting

**Unable to connect to Kubernetes cluster:** Verify your kubectl configuration and ensure your cluster is running and accessible. If needed, follow the cluster creation tutorial.

**Secrets "zarf-state" not found:** This indicates your cluster wasn't initialized. Complete the cluster initialization tutorial before retrying deployment.
