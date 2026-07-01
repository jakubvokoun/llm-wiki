---
title: "Using Tilt with Zarf / Helm Kubernetes Deployments"
tags: [tilt, zarf, helm, kubernetes, inner-loop, airgap, deployment]
sources:
  [
    tilt-helm.md,
    tilt-templating-yaml.md,
    tilt-custom-build.md,
    tilt-local-resource.md,
    zarf-creating-package.md,
    zarf-deploying-packages.md,
    zarf-packages.md,
  ]
updated: 2026-07-01
---

# Using Tilt with Zarf / Helm Kubernetes Deployments

**Question:** How do you combine [[tilt|Tilt]] with [[zarf|Zarf]] and Helm for Kubernetes deployments?

**Scope:** this assumes an **existing Zarf-based setup** — you already have a `zarf.yaml` with one or more `ZarfChart` components and ship packages to your clusters — and you want to add Tilt's fast inner loop for day-to-day development **without disturbing the Zarf delivery path**.

**Short answer:** They belong to different loops. Tilt owns the **inner loop** (edit → build → deploy → live-update, seconds). Zarf owns the **outer loop** (package → sign → ship → deploy offline). Helm is the shared artifact that both consume. The productive move is to **point Tilt at the Helm chart your `zarf.yaml` already references** and iterate on it locally, leaving Zarf as the untouched release path. There is no first-party Tilt↔Zarf integration; the seams below are community/DIY patterns built from documented Tilt and Zarf primitives. Two frictions are specific to an already-`zarf init`'d cluster — the **Zarf Agent rewriting Tilt's images** and **`###ZARF_VAR_*###` tokens breaking `helm template`** — and are called out below.

## The two loops

Tilt and Zarf do not compete — they cover different phases of the same pipeline. The mistake to avoid is trying to make Tilt's inner loop go through Zarf's package build: that reintroduces the exact minutes-long round-trip Tilt exists to eliminate.

| Dimension       | Tilt (inner loop)                                    | Zarf (outer loop)                                             |
| --------------- | ---------------------------------------------------- | ------------------------------------------------------------- |
| Purpose         | Fast local iteration on a live cluster               | Reproducible, offline/airgap delivery                         |
| Trigger         | File save                                            | Release / promotion                                           |
| Speed target    | ~1–2 s ([[tilt-live-update]])                        | Minutes (build + transfer)                                    |
| Connectivity    | Online, developer workstation                        | Build online, **deploy offline**                              |
| Image handling  | Rebuild + inject content-tag ([[tilt-custom-build]]) | Pre-pull, re-serve from internal registry ([[zarf-packages]]) |
| Config surface  | Tiltfile `set=` / values, live edits                 | `###ZARF_VAR_*###` templating at deploy time                  |
| Chart execution | `helm template` (hooks skipped) — see [[tilt-helm]]  | Real `helm install/upgrade` via `ZarfChart`                   |

## Architecture: point Tilt at the chart your `zarf.yaml` already references

The chart is the shared contract that already exists in your Zarf setup — do not fork it. Add a Tiltfile alongside the existing `zarf.yaml` so both consume the one chart: Tilt renders it in dev, Zarf keeps packaging it for delivery unchanged. This preserves dev/prod parity because the same templates are exercised in both loops.

```
charts/myapp/                 ← existing chart (already referenced by zarf.yaml)
├── Chart.yaml
├── values.yaml               ← delivery values (may carry ###ZARF_VAR_*### tokens)
├── values-dev.yaml           ← NEW: Tilt overrides — concrete values, no Zarf tokens
└── templates/

zarf.yaml                     ← UNCHANGED: ZarfChart → charts/myapp (delivery path)
Tiltfile                      ← NEW: helm() → k8s_yaml(), docker_build, live_update
```

**If `zarf.yaml` references the chart remotely** (a `ZarfChart` with `url:`/OCI rather than `localPath`), Tilt still needs the chart on local disk: either vendor a local copy for `helm()`, or pull it with the `helm_remote` extension ([[tilt-helm]]). Tilt's `helm()` is offline-only and cannot template a remote chart in place.

### Dev side (Tiltfile)

Render the existing chart with Tilt's built-in `helm()` and let Tilt inject the locally-built image (see [[tilt-helm]], [[tilt-templating-yaml]]). Tilt runs `helm template`, splits the output into resources, auto-injects the freshly built image digest, and re-renders on any chart file change.

```python
# Tiltfile
docker_build('myapp', './myapp', live_update=[
    sync('./myapp/src', '/app/src'),
])

k8s_yaml(helm(
    './charts/myapp',
    name='myapp',
    namespace='dev',
    values=['./charts/myapp/values-dev.yaml'],
))
k8s_resource('myapp', port_forwards=['8080:8080'])
```

> **Gotcha (existing Zarf clusters) — the Zarf Agent will hijack Tilt's images.** On a `zarf init`'d cluster, the Zarf Agent is a mutating admission webhook that rewrites every pod's image reference to Zarf's internal registry ([[zarf-packages]]). Tilt builds an image locally and injects a `tilt-<hash>` ref that only exists in your local/Tilt registry — the Agent rewrites it to an internal-registry path that has never seen that image, so pods fail `ImagePullBackOff`. **Do not run Tilt's dev workloads in an Agent-managed namespace.** Options, best first: (1) run Tilt against a **separate local dev cluster** (Kind/k3d — see [[tilt-choosing-clusters]]) that was never `zarf init`'d; (2) deploy into a namespace carrying the label **`zarf.dev/agent: ignore`**, which tells the Agent to skip it (a per-resource `zarf.dev/agent: ignore` label overrides the namespace and takes priority — this same label, applied to pre-existing namespaces at `zarf init` time, is why `default`/`kube-system` are left alone); (3) point Tilt's `default_registry` at Zarf's internal registry so the rewritten ref resolves — fiddly and rarely worth it.

> **Caveat — hooks are skipped.** `helm()` uses Tilt's own deploy engine, so Helm chart **hooks do not run** ([[tilt-helm]]). If the chart relies on pre-install/post-install hooks (migrations, CRD installs), either (a) model those as separate Tilt resources (`local_resource` / a Job manifest), or (b) deploy the chart via a real `helm install` using `k8s_custom_deploy` (below), which is closer to what Zarf does in production.

### Delivery side (zarf.yaml)

Your existing `zarf.yaml` is unchanged — the `ZarfChart` component still points at the same chart. Zarf pre-pulls the images (`zarf dev find-images`), runs a genuine `helm install`, and templates values with `###ZARF_VAR_*###` at deploy time ([[zarf-creating-package]], [[zarf-packages]]). Because the chart's _logic_ is now also exercised in dev under Tilt, Zarf keeps owning the delivery concerns (image pre-pull, SBOM, signing, offline templating) exactly as before. Shown here for reference:

> **Gotcha — keep Zarf tokens out of the dev values file.** `###ZARF_VAR_*###` is a Zarf-only convention resolved at `zarf package deploy`. Tilt's `helm()` runs plain `helm template`, which does not understand those tokens — it renders them literally, producing invalid YAML or garbage config. This is precisely why the two loops read **different values files**: `values-dev.yaml` (concrete values, Tilt-renderable) versus the delivery `values.yaml` (may carry `###ZARF_VAR_*###`). Put Zarf tokens only in files Tilt never templates, and keep any shared keys token-free.

```yaml
kind: ZarfPackageConfig
metadata:
  name: myapp
  version: 1.0.0
components:
  - name: myapp
    required: true
    charts:
      - name: myapp
        localPath: charts/myapp # same chart Tilt renders
        namespace: myapp
        valuesFiles:
          - charts/myapp/values.yaml
    images:
      - ttl.sh/myapp:1.0.0 # the image you built & pushed for release
```

## Bridge patterns (when you must involve Zarf in the loop)

### 1. Deploy a real Helm release under Tilt via `k8s_custom_deploy`

Closest dev-time approximation of Zarf's production behavior — runs actual `helm upgrade --install` so **hooks fire**, while Tilt still tracks status and streams logs ([[tilt-templating-yaml]]). The `helm_resource` extension wraps this same pattern for consumed third-party charts ([[tilt-helm]]).

```python
k8s_custom_deploy(
    'myapp',
    apply_cmd='helm upgrade --install myapp ./charts/myapp -n dev --create-namespace && '
              'kubectl get -n dev deploy/myapp -o yaml',
    delete_cmd='helm uninstall myapp -n dev',
    deps=['./charts/myapp'],
    image_deps=['myapp'],   # Tilt injects the built image ref
)
```

### 2. Test the actual Zarf package build/deploy as an on-demand resource

Keep this **out** of the fast loop — make it a manual-trigger `local_resource` so it never fires on every file save (see [[tilt-local-resource]], [[tilt-manual-update-control]]). Use it to smoke-test that the package still builds and deploys — a "does my release artifact work?" button, not an inner-loop step. Wrapping it as a [[tilt-custom-buttons|custom uibutton]] makes it one click in the UI.

```python
local_resource(
    'zarf-package',
    cmd='zarf package create . --confirm',
    deps=['zarf.yaml', 'charts/myapp'],
    trigger_mode=TRIGGER_MODE_MANUAL,
    auto_init=False,
)
local_resource(
    'zarf-deploy',
    cmd='zarf package deploy zarf-package-myapp-*.tar.zst --confirm',
    resource_deps=['zarf-package'],
    trigger_mode=TRIGGER_MODE_MANUAL,
    auto_init=False,
)
```

### 3. Image ref alignment

Tilt deploys **content-based immutable tags** it generates at build time (`myapp:tilt-<hash>`), while Zarf deploys the **pinned tag you declare** in `zarf.yaml` and re-serves from its internal registry ([[tilt-custom-build]], [[zarf-packages]]). Keep the chart's image reference a **templated value** (`image.repository` / `image.tag`) so Tilt can override it via injection / `values-dev.yaml`, and Zarf's `images:` list plus the Zarf Agent registry rewrite can handle it at deploy time. Never hard-code a tag in `templates/` — that breaks both injection paths.

## Decision guide

| You want to…                                   | Use                                                          |
| ---------------------------------------------- | ------------------------------------------------------------ |
| Fast edit-run loop on your own chart           | Tilt `helm()` + `docker_build` live_update ([[tilt-helm]])   |
| Dev with real Helm semantics (hooks, ordering) | `k8s_custom_deploy` running `helm upgrade --install`         |
| Consume a third-party chart in the dev cluster | `helm_resource` extension ([[tilt-helm]])                    |
| Validate the offline release artifact          | Manual `local_resource` calling `zarf package create/deploy` |
| Ship to an airgapped cluster                   | Zarf package with `ZarfChart` ([[zarf-packages]])            |

## Key takeaways

1. **Don't route the inner loop through Zarf.** Add Tilt beside the existing Zarf path; leave `zarf.yaml` and the release flow untouched. Tilt for dev speed, Zarf for delivery — the same philosophy as "[[gitops|Kubernetes for prod]], Tilt for dev."
2. **The existing Helm chart is the shared contract.** Point Tilt at the chart `zarf.yaml` already references; don't fork it. This keeps dev/prod parity high.
3. **Keep Tilt off the Zarf Agent.** On a `zarf init`'d cluster the Agent rewrites Tilt's images to the internal registry and breaks them — dev on a separate cluster or an Agent-ignored namespace.
4. **Mind the hook gap.** Tilt's `helm()` skips hooks; use `k8s_custom_deploy` when you need production-faithful Helm behavior during dev.
5. **Keep image tags templated** so Tilt's injection and Zarf's registry rewrite both work without editing templates.
6. **Expose Zarf as a manual button, not an auto step**, to smoke-test the release artifact without slowing iteration.

## Sources & related pages

- Wiki: [[tilt-helm]], [[tilt-templating-yaml]], [[tilt-custom-build]], [[tilt-local-resource]], [[tilt-manual-update-control]], [[zarf-packages]], [[zarf-creating-package]], [[zarf-deploying-packages]]
- [Tiltfile API — `k8s_custom_deploy`, `helm()`](https://docs.tilt.dev/api.html)
- [Tilt — Modifying YAML for Dev](https://docs.tilt.dev/templating.html)
- [Zarf — Airgap Native Package Manager](https://github.com/zarf-dev/zarf)
- [Zarf FAQ — Agent mutation policies & the `zarf.dev/agent: ignore`/`mutate` labels](https://docs.zarf.dev/faq)
