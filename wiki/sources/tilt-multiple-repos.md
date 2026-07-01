---
title: "Tilt: Many Tiltfiles and Many Repos"
tags: [tilt, tiltfile, monorepo]
sources: [tilt-multiple-repos]
updated: 2026-07-01
---

# Tilt: Many Tiltfiles and Many Repos

Source: [docs.tilt.dev/multiple_repos](https://docs.tilt.dev/multiple_repos.html)

A reference for organizing multi-service, multi-repository projects using [[tilt]]. The core principle: **do not restructure your project for Tilt — restructure your [[tiltfile]]s to match your project structure.**

## Key APIs

### `load()` — import symbols from another Tiltfile

Loads named constants or functions from a relative path. Suitable for shared libraries.

```python
load('../common/Tiltfile', 'VERSION', 'common_config_yaml')

print('Loading version: ', VERSION)
k8s_yaml(common_config_yaml())
```

Use `load()` when you want to reuse helper functions or constants across multiple services that share dev conventions.

### `include()` — execute a sub-Tiltfile in place

Runs another Tiltfile as if its contents were inlined. No symbol export — side effects only.

```python
include('./frontend/Tiltfile')
include('./backend/Tiltfile')
```

Use `include()` when services have independent Tiltfiles that you occasionally want to run together.

### `load_dynamic()` — conditional loading

Returns a dict of symbols, enabling runtime branching. Less ergonomic than `load()` but necessary for conditional logic.

```python
USE_OAUTH2 = os.path.exists('../.secrets/values-dev.yaml')
USE_TLS = False
if USE_OAUTH2:
  symbols = load_dynamic('../oauth2-proxy/Tiltfile')
  USE_TLS = symbols['USE_TLS']
```

Useful for toggling real vs. fake backends, TLS vs. plain HTTP, or feature-flagged service variants based on what secrets/files are present locally.

## Common Patterns

### Shared library Tiltfile

One `common/Tiltfile` exports helpers; each service's Tiltfile uses `load()` to pull them in. Keeps duplication low when services share deployment conventions.

### Monorepo with per-service sub-Tiltfiles

A root Tiltfile uses `include()` to pull in each service directory:

```python
include('./frontend/Tiltfile')
include('./backend/Tiltfile')
```

### Conditional service loading

Use `os.path.exists` or `os.environ.get` to detect local conditions and load services accordingly (see `load_dynamic()` example above).

### Multi-repo: sibling checkout convention

The simplest multi-repo pattern is to expect sibling directories and fail fast if they are missing:

```python
if not os.path.exists('../backend'):
  fail('Please "git clone" the backend repo in ../backend!')

include('../backend/Tiltfile')
```

Can also accept an environment variable override:

```python
backend_dir = os.environ.get('BACKEND_REPO_DIR', '../backend')
if not os.path.exists(backend_dir):
  fail('Please "git clone" the backend repo in %s!' % backend_dir)

include(os.path.join(backend_dir, 'Tiltfile'))
```

### Multi-repo: `git_resource` extension

For teams that want Tilt to manage checkouts directly, the `git_resource` extension from [[tilt-extensions]] provides `git_checkout()`:

```python
load('ext://git_resource', 'git_checkout')
git_checkout('git@github.com:tilt-dev/tilt-example-html.git#master', '/path/to/local/checkout')
```

See the [`git_resource` README](https://github.com/tilt-dev/tilt-extensions/tree/master/git_resource) for full options.

## Enabling / Disabling Services at Runtime

As the number of services grows, use `tilt enable` / `tilt disable` to run subsets:

| Command                  | Effect                             |
| ------------------------ | ---------------------------------- |
| `tilt enable a b`        | Enable services a and b            |
| `tilt enable --only a b` | Enable a and b, disable all others |
| `tilt enable --all`      | Enable every service               |
| `tilt disable a b`       | Disable a and b                    |
| `tilt disable --all`     | Disable every service              |

For more complex flag-driven configuration (e.g. "edit mode" vs. "run-only mode"), use Tilt's per-user config API (`tiltfile_config`).

## Extension Repositories

[[tilt-extensions]] is the official community extension repo. Teams can also maintain private extension repos and load them via the same `load('ext://...')` syntax. See the Extensions Guide for details.

## Language

[[tiltfile]]s are written in [[starlark]], a Python-like language. All functions above (`load`, `include`, `load_dynamic`, `os.path.exists`, `os.environ.get`, `os.path.join`) are part of the [[tilt]] Starlark API.
