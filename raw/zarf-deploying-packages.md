# Deploying Local Zarf Packages

## Introduction

This tutorial demonstrates how to deploy the WordPress package onto your cluster using `zarf package deploy`. It builds on two previous tutorials: creating a package and initializing a Kubernetes cluster.

## System Requirements

You'll need a machine with access to a built package and an initialized cluster.

## Prerequisites

Before starting, ensure you have:

- Zarf binary installed on your $PATH
- An initialized cluster from the previous tutorial
- The WordPress package created in the earlier tutorial

## Deploying the WordPress Package

1. **Run the deploy command**: Execute `zarf package deploy` to deploy your built package. If you don't specify a path, Zarf prompts you to choose from available packages in your working directory. Use the `tab` key to navigate and select the WordPress package.

2. **Review and confirm**: Zarf displays the package's SBOMs and definition, then prompts you for variable values set up previously. Press `y` to confirm deployment, then provide values for each variable (or press `enter` to accept defaults).

3. **Test the deployment**: Use `zarf connect wordpress` to quickly test your package in a browser. You can also explore deployed resources with `zarf tools monitor` to launch k9s.

4. **Additional options**: Beyond deployment, you can inspect packages using `zarf package inspect` to view SBOMs or use `zarf package publish` to push resources like images to airgap services without deploying.

## Removal

1. List installed packages with `zarf package list` to identify the WordPress package name.

2. Remove the package using `zarf package remove wordpress --confirm`.

3. Alternatively, remove it by referencing the package file with the `--confirm` flag.

## Troubleshooting

**Unable to connect to the Kubernetes cluster**: Verify your kubectl configuration. If needed, deploy a cluster using the Kubernetes cluster creation tutorial, then initialize it before retrying.

**Secrets "zarf-state" not found**: This indicates your cluster hasn't been initialized. Complete the cluster initialization tutorial first, then retry deployment.
