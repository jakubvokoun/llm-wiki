---
source_url: https://openbao.org/docs/platform/k8s/helm/configuration/
fetched: 2026-07-03
---

# Configuration

**Important Note:** This chart is not compatible with Helm 2. Please use Helm 3.6+ with this chart.

The chart is highly customizable using
[Helm configuration values](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).
Each value has a default tuned for an optimal getting started experience
with OpenBao. Before going into production, please review the parameters from the default [`values.yaml`](https://github.com/openbao/openbao-helm/blob/main/charts/openbao/values.yaml) file
and consider if they're appropriate for your deployment.
