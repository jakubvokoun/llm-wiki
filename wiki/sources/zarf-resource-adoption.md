---
title: "Zarf Tutorial 8 — Adopt Pre-Existing Resources"
tags: [zarf, kubernetes, airgap, adoption, lifecycle]
sources: [zarf-resource-adoption.md]
updated: 2026-04-23
---

# Zarf Tutorial 8 — Adopt Pre-Existing Resources

Source: [docs.zarf.dev](https://docs.zarf.dev/tutorials/8-resource-adoption/)

## Summary

Zarf can take over management of Kubernetes workloads that were deployed _before_ Zarf was
initialized in the cluster, enabling lifecycle management of pre-existing resources.

## Workflow

1. Deploy workloads into the cluster (Zarf **not** yet initialized)
2. Run `zarf init` — Zarf labels existing namespaces with `zarf.dev/agent=ignore`, exempting them
3. Run deploy with adoption flag:

```bash
zarf package deploy <pkg>.tar.zst --adopt-existing-resources
```

4. Adopted namespace gets `app.kubernetes.io/managed-by=zarf` — now fully Zarf-managed

## Labels

| Label                               | Set by      | Meaning                                 |
| ----------------------------------- | ----------- | --------------------------------------- |
| `zarf.dev/agent=ignore`             | `zarf init` | Namespace excluded from Zarf management |
| `app.kubernetes.io/managed-by=zarf` | adoption    | Namespace now managed by Zarf           |

## Caution

Adoption works best when resources are in a **dedicated namespace**. Using
`--adopt-existing-resources` on a shared namespace risks breaking non-Zarf workloads that
happen to share the same manifests/service names.

## Related

- [Zarf](../entities/zarf.md)
- [Zarf Packages](../concepts/zarf-packages.md)
- [Tutorial 2 — Deploying Packages](zarf-deploying-packages.md)
