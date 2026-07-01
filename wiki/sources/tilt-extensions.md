---
title: "Tilt Extensions — Using and Loading"
tags: [tilt, extensions, starlark]
sources: [tilt-extensions]
updated: 2026-07-01
---

# Tilt Extensions — Using and Loading

How to use and manage [[tilt-extensions|Tilt extensions]] — shareable snippets of [[tiltfile|Tiltfile]] functionality (version checks, build/deploy scripts, custom buttons). See the concept page [[tilt-extensions]] for the overview.

## Using an extension

```python
load('ext://hello_world', 'hi')
hi()
```

The `ext://` prefix loads from the community [tilt-extensions repo](https://github.com/tilt-dev/tilt-extensions): Tilt checks the repo out in the background, reads `hello_world/Tiltfile`, and binds the `hi` symbol into local scope.

## Sharing code within a single repo (no extension system)

`load()`'s first arg can be a relative path:

```python
load('./common/Tiltfile', 'hi')
```

`load()` binds fixed symbols; for dynamic scripting use `load_dynamic`, which returns a dict:

```python
symbols = load_dynamic('./common/Tiltfile')
hi = symbols.get('hi')
```

## Explicit repo/extension declaration (v0.25+)

`load('ext://hello_world', 'hi')` is shorthand for:

```python
v1alpha1.extension_repo(name='default', url='https://github.com/tilt-dev/tilt-extensions')
v1alpha1.extension(name='hello_world', repo_name='default', repo_path='hello_world')
load('ext://hello_world', 'hi')
```

This lets you:

- **Load from local disk** for experimentation: `url='file:///abs/path/tilt-extensions'` (absolute paths only).
- **Replace the default repo with a pinned fork:** `url='https://github.com/my-org/tilt-extensions', ref='v0.25.0'`.
- **Add extra repos** alongside `default` (`name='my-repo'`, then point an extension's `repo_name` at it).
- **Private repos:** configure Git auth in the background, e.g. an SSH `insteadOf` rewrite in `~/.gitconfig`.

## Debugging with the CLI

```
tilt get extensionrepo
tilt get extensionrepo default -o jsonpath='{.status}' | jq
tilt get extension
tilt get extension hello_world -o jsonpath='{.status}' | jq
```

## Storage note (upgrading from < v0.25.0)

Older Tilt vendored extension code into a `tilt_modules/` dir next to the Tiltfile (caused monorepo/vendoring/file-watch grief). Since **v0.25.0**, extension code lives in the **XDG data directory**, customizable via XDG env vars.

To contribute an extension upstream, see [[tilt-contribute-extension]]. Related: [[tilt]], [[starlark]], [[tilt-custom-buttons]].
