# Adopt Pre-Existing Resources

## Introduction

In this tutorial, you will create a test workload prior to initializing Zarf. After that you will then use Zarf to adopt those workloads, so you can manage their future lifecycle with Zarf.

## System Requirements

- You'll need an internet connection to grab the Zarf Init Package if it's not already on your machine.

## Prerequisites

- Prior to this tutorial you'll want to have a working cluster. But unlike our other tutorials you **don't want Zarf initialized**.
- Zarf binary installed on your $PATH: ([Installing Zarf](/getting-started/install/))

## Creating a Test Component

We're going to use the manifests from the [Deploying a Retro Arcade](/tutorials/3-deploy-a-retro-arcade/) tutorial for this example. So if you haven't yet, clone the Zarf repository, and navigate to the cloned repository's root directory.

1. Create the dos-games namespace

2. Use the dos-games example manifests, to deploy the dos-games deployment and service to your Kubernetes cluster.

## Test to see that this is working

1. Use the `kubectl port-forward` command to confirm you've deployed the manifests properly.

2. Navigate to `http://localhost:8000` in your browser to view the dos-games application. It will look something like this:

![Connected to the Games](/_astro/games_connected.BrprzlZ__KB3uD.webp)

> Remember to press `ctrl+c` in your terminal when you're done with the port-forward.

## Initialize Zarf

1. Use the [Initializing a K8s Cluster](/tutorials/1-initializing-a-k8s-cluster/) tutorial, to initialize Zarf in the cluster.

> You'll notice the dos-games namespace has been excluded from Zarf management as it has the `zarf.dev/agent=ignore` label. This means that Zarf will not manage any resources in this namespace.

## Deploy the Package, Adopting the Workloads

1. Use the `zarf package deploy` command with the `--adopt-existing-resources` flag to adopt the existing dos-games resources in the `dos-games` namespace.

> **Caution:** Notice that in this example the dos-games resources were contained in their own namespace. When running a deploy with `--adopt-existing-resources` it is recommended that this be the case as you could break other non-Zarf deployments if resources are shared.

## Test to see that this is working (after adoption)

1. You'll notice the dos-games namespace is no longer excluded from Zarf management as it has the `app.kubernetes.io/managed-by=zarf` label. This means that Zarf will now manage any resources in this namespace.

2. You can also now use the `zarf connect` command to connect to the dos-games application. Again it will look something like this.

![Connected to the Games](/_astro/games_connected.BrprzlZ__KB3uD.webp)

> Again, remember to press `ctrl+c` in your terminal, when you're done with the connection.

## Conclusion

At this point the dos-game package is managed by Zarf and will behave just like a package initially deployed with Zarf.
