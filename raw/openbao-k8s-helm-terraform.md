---
source_url: https://openbao.org/docs/platform/k8s/helm/terraform/
fetched: 2026-07-03
---

# Configuring OpenBao HELM with OpenTofu

OpenTofu may also be used to configure and deploy the OpenBao Helm chart, by using the [Helm provider](https://github.com/hashicorp/terraform-provider-helm).

For example, to configure the chart to deploy [HA OpenBao with Integrated Storage (raft)](/docs/platform/k8s/helm/examples/ha-with-raft/), the values overrides can be set on the command-line, in a values yaml file, or with a OpenTofu configuration:

CLI:

```
$ helm install openbao openbao/openbao \
  --set='server.ha.enabled=true' \
  --set='server.ha.raft.enabled=true'
```

Yaml:

```
server:
  ha:
    enabled: true
    raft:
      enabled: true
```

OpenTofu:

```
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "openbao" {
  name       = "openbao"
  repository = "https://openbao.github.io/openbao-helm"
  chart      = "openbao"

  set {
    name  = "server.ha.enabled"
    value = "true"
  }

  set {
    name  = "server.ha.raft.enabled"
    value = "true"
  }
}
```

The values file can also be used directly in the OpenTofu configuration with the [`values` directive](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release#values#values).

## Further examples

### OpenBao config as a multi-line string

Yaml:

```
server:
  ha:
    enabled: true
    raft:
      enabled: true
      setNodeId: true
      config: |
        ui = false

        listener "tcp" {
          tls_disable = 1
          address = "[::]:8200"
          cluster_address = "[::]:8201"
        }

        storage "raft" {
          path    = "/openbao/data"
        }

        service_registration "kubernetes" {}

        seal "awskms" {
          region     = "us-west-2"
          kms_key_id = "alias/my-kms-key"
        }
```

OpenTofu:

```
resource "helm_release" "openbao" {
  name       = "openbao"
  repository = "https://openbao.github.io/openbao-helm"
  chart      = "openbao"

  set {
    name  = "server.ha.enabled"
    value = "true"
  }

  set {
    name  = "server.ha.raft.enabled"
    value = "true"
  }

  set {
    name  = "server.ha.raft.setNodeId"
    value = "true"
  }

  set {
    name  = "server.ha.raft.config"
    value = <<EOT
ui = false

listener "tcp" {
  tls_disable = 1
  address = "[::]:8200"
  cluster_address = "[::]:8201"
}

storage "raft" {
  path    = "/openbao/data"
}

service_registration "kubernetes" {}

seal "awskms" {
  region     = "us-west-2"
  kms_key_id = "alias/my-kms-key"
}

EOT
  }
}
```

### Lists of volumes and volumeMounts

Yaml:

```
server:
  volumes:
    - name: userconfig-my-gcp-iam
      secret:
        defaultMode: 420
        secretName: my-gcp-iam
  volumeMounts:
    - mountPath: /openbao/userconfig/my-gcp-iam
      name: userconfig-my-gcp-iam
      readOnly: true
```

OpenTofu:

```
resource "helm_release" "openbao" {
  name       = "openbao"
  repository = "https://openbao.github.io/openbao-helm"
  chart      = "openbao"

  set {
    name  = "server.volumes[0].name"
    value = "userconfig-my-gcp-iam"
  }

  set {
    name  = "server.volumes[0].secret.defaultMode"
    value = "420"
  }

  set {
    name  = "server.volumes[0].secret.secretName"
    value = "my-gcp-iam"
  }

  set {
    name  = "server.volumeMounts[0].mountPath"
    value = "/openbao/userconfig/my-gcp-iam"
  }

  set {
    name  = "server.volumeMounts[0].name"
    value = "userconfig-my-gcp-iam"
  }

  set {
    name  = "server.volumeMounts[0].readOnly"
    value = "true"
  }
}
```

### Annotations

Annotations can be set as a YAML map:

Yaml:

```
server:
  ingress:
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: true
      service.beta.kubernetes.io/azure-load-balancer-internal-subnet: apps-subnet
```

OpenTofu:

```
set {
  name = "server.ingress.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
  value = "true"
}

set {
  name = "server.ingress.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal-subnet"
  value = "apps-subnet"
}
```

Or as a multi-line string:

Yaml:

```
server:
  ingress:
    annotations: |
      service.beta.kubernetes.io/azure-load-balancer-internal: true
      service.beta.kubernetes.io/azure-load-balancer-internal-subnet: apps-subnet
```

OpenTofu:

```
set {
  name = "server.ingress.annotations"
  value = yamlencode({
    "service.beta.kubernetes.io/azure-load-balancer-internal": "true"
    "service.beta.kubernetes.io/azure-load-balancer-internal-subnet": "apps-subnet"
  })
  type = "auto"
}
```
