---
title: "OpenBao — Helm with OpenTofu / Terraform"
tags: [openbao, kubernetes, helm, opentofu, terraform, iac]
sources: [openbao-k8s-helm-terraform.md]
updated: 2026-07-03
---

# OpenBao — Helm with OpenTofu / Terraform

Deploying the [OpenBao Helm chart](openbao-k8s-helm.md) declaratively with **OpenTofu/Terraform** via the `helm` provider.

## Key Takeaways

- Use the [Helm provider](https://github.com/hashicorp/terraform-provider-helm) `helm_release` resource pointing at `repository = "https://openbao.github.io/openbao-helm"`, `chart = "openbao"`. Chart values map to `set {}` blocks (equivalent to `helm --set`), or use the `values` directive to feed a YAML file directly.
- The multi-line OpenBao server config (`server.ha.raft.config`) can be passed as a heredoc `value = <<EOT ... EOT` — this is where the HCL `listener`/`storage "raft"`/`service_registration`/`seal` stanzas go.
- **List values** use indexed keys: `server.volumes[0].name`, `server.volumeMounts[0].mountPath`, etc.
- **Annotations** with dots need escaped keys (`service\\.beta\\.kubernetes\\.io/...`) or can be passed as a `yamlencode({...})` block with `type = "auto"`.

```hcl
provider "helm" {
  kubernetes { config_path = "~/.kube/config" }
}

resource "helm_release" "openbao" {
  name       = "openbao"
  repository = "https://openbao.github.io/openbao-helm"
  chart      = "openbao"

  set { name = "server.ha.enabled"      value = "true" }
  set { name = "server.ha.raft.enabled" value = "true" }
  set { name = "server.ha.raft.setNodeId" value = "true" }

  set {
    name  = "server.ha.raft.config"
    value = <<EOT
ui = false
listener "tcp" {
  tls_disable     = 1
  address         = "[::]:8200"
  cluster_address = "[::]:8201"
}
storage "raft" { path = "/openbao/data" }
service_registration "kubernetes" {}
seal "awskms" {
  region     = "us-west-2"
  kms_key_id = "alias/my-kms-key"
}
EOT
  }
}
```

## Related

- [Helm chart](openbao-k8s-helm.md)
- [Run on Kubernetes](openbao-k8s-helm-run.md)
- [Raft storage](openbao-config-storage-raft.md)
- [Seal config](openbao-config-seal.md)
- [Kubernetes](../entities/kubernetes.md)
