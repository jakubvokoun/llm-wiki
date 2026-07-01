---
title: "Tilt: Accessing Service Endpoints"
tags: [tilt, networking, kubernetes]
sources: [tilt-port-forwards]
updated: 2026-07-01
---

# Tilt: Accessing Service Endpoints

Source: [docs.tilt.dev/accessing_resource_endpoints](https://docs.tilt.dev/accessing_resource_endpoints.html)

[[tilt]] standardizes service endpoint access in the dev dashboard through four mechanisms: static links, `kubectl port-forward` tunnels, bulk forwarding via `kubefwd`, and public tunnels via `ngrok`.

## Static Links (`link`)

Any resource type supports the `link()` function to pin arbitrary URLs in the dashboard:

```python
k8s_resource(
   workload='blog-site',
   links=[
      'blog-db.storage.acme.com',
      link('internal-eng.acme.com/docs/blog-db-reset', 'Blog db reset docs')
   ]
)
```

Links appear on both the main dashboard table and the individual resource page. Supported on `k8s_resource`, `local_resource`, and `dc_resource`.

## `kubectl port-forward` Tunnels

Configured via the `port_forwards` argument of `k8s_resource` in a [[tiltfile]]. Tilt automatically creates a clickable link in the UI — no separate `links=` call needed.

**Same local and container port:**

```python
k8s_resource(workload='blog-site', port_forwards=4002)
# localhost:4002 → container:4002
```

**Different local and container port:**

```python
k8s_resource(workload='blog-site', port_forwards='9000:4002')
# localhost:9000 → container:4002
```

**Multiple port forwards:**

```python
k8s_resource(
   workload='blog-site',
   port_forwards=['9000:4002', '9001:4003']
)
```

**Named port forwards** (using `port_forward(local, container, name=...)`):

```python
k8s_resource(
   workload='blog-site',
   port_forwards=[
      port_forward(9000, 4002, name='blog-hero-post'),
      port_forward(9001, 4003, name='blog-archives')
   ]
)
```

Names replace the raw `localhost:<port>` label in the UI, making multi-port resources self-documenting.

## Bulk Forwarding with `kubefwd`

[`kubefwd`](https://kubefwd.com/) bulk-forwards every service in the deployed [[kubernetes]] namespace — no per-service configuration required. Useful when exploring a cluster or bringing up many services at once.

Load via the Tilt extensions repo:

```python
v1alpha1.extension_repo(name='default', url='https://github.com/tilt-dev/tilt-extensions')
v1alpha1.extension(name='kubefwd:config', repo_name='default', repo_path='kubefwd')
```

**Trade-off:** requires `sudo` because it modifies local DNS.

See the [kubefwd extension README](https://github.com/tilt-dev/tilt-extensions/tree/master/kubefwd) for full options.

## Public Tunnels with `ngrok`

The `ngrok` extension exposes a service on a public URL instead of `localhost`. It adds start/stop buttons directly in the Tilt UI so the tunnel is on-demand, not always-on.

No [[tiltfile]] snippet is shown in the source; refer to the [ngrok extension README](https://github.com/tilt-dev/tilt-extensions/blob/master/ngrok/README.md) for setup.

## Summary Table

| Method              | Scope           | Config location      | Notes                                 |
| ------------------- | --------------- | -------------------- | ------------------------------------- |
| `link()`            | Any resource    | `links=` arg         | Static URL, no tunneling              |
| `port_forwards`     | `k8s_resource`  | `port_forwards=` arg | `kubectl port-forward` under the hood |
| `kubefwd` extension | Whole namespace | Extension loader     | Bulk, requires `sudo`                 |
| `ngrok` extension   | Per service     | Extension loader     | Public URL, on-demand via UI button   |
