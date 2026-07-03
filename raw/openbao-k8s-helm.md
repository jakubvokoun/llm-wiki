---
source_url: https://openbao.org/docs/platform/k8s/helm/
fetched: 2026-07-03
---

# Helm chart

**Important Note:** This chart is not compatible with Helm 2. Please use Helm 3.6+ with this chart.

The [OpenBao Helm chart](https://github.com/openbao/openbao-helm)
is the recommended way to install and configure OpenBao on Kubernetes.
In addition to running OpenBao itself, the Helm chart is the primary
method for installing and configuring OpenBao to integrate with other
services such as the [Vault Agent Injector](https://github.com/hashicorp/vault-k8s/tree/v1.4.2).

This page assumes general knowledge of [Helm](https://helm.sh/) and
how to use it. Using Helm to install OpenBao requires that Helm is
properly installed and configured with your Kubernetes cluster.

## Supported kubernetes versions

The following [Kubernetes minor releases](https://kubernetes.io/releases/) are currently supported.
The latest version is tested against each Kubernetes version. It may work with
other versions of Kubernetes, but those are not supported.

* 1.30
* 1.31
* 1.32
* 1.33

## Using the helm chart

Helm must be installed and configured on your machine. Please refer to the [Helm
documentation](https://helm.sh/) for more information.

To use the Helm chart, add the OpenBao helm repository and check that you have
access to the chart:

```
$ helm repo add openbao https://openbao.github.io/openbao-helm

"openbao" has been added to your repositories

$ helm search repo openbao/openbao

NAME            CHART VERSION   APP VERSION             DESCRIPTION

openbao/openbao 0.4.0           v2.0.0-alpha20240329    Official OpenBao Chart
```

**Important:** The Helm chart is new and under significant development.
Please always run Helm with `--dry-run` before any install or upgrade to verify
changes.

Example chart usage:

Installing the latest release of the OpenBao Helm chart with pods prefixed with
the name `openbao`.

```
$ helm install openbao openbao/openbao
```

Installing a specific version of the chart.

```
# List the available releases

$ helm search repo openbao/openbao -l

NAME            CHART VERSION   APP VERSION             DESCRIPTION

openbao/openbao 0.4.0           v2.0.0-alpha20240329    Official OpenBao Chart

openbao/openbao 0.3.0           v2.0.0-alpha20240329    Official OpenBao Chart

openbao/openbao 0.2.0           v2.0.0-alpha20240329    Official OpenBao Chart

...

# Install version 0.4.0

$ helm install openbao openbao/openbao --version 0.4.0
```

**Security Warning:** By default, the chart runs in standalone mode. This
mode uses a single OpenBao server with a file storage backend. This is a less
secure and less resilient installation that is **NOT** appropriate for a
production setup. It is highly recommended to use a [properly secured Kubernetes
cluster](https://kubernetes.io/docs/tasks/administer-cluster/securing-a-cluster/),
[learn the available configuration
options](/docs/platform/k8s/helm/configuration/), and read the [production deployment
checklist](/docs/platform/k8s/helm/run/#architecture).
