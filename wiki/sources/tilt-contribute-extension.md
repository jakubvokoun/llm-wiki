---
title: "Contributing a Tilt Extension"
tags: [tilt, extensions, contributing]
sources: [tilt-contribute-extension]
updated: 2026-07-01
---

# Contributing a Tilt Extension

How to contribute a new [[tilt-extensions|extension]] to the shared [tilt-extensions repo](https://github.com/tilt-dev/tilt-extensions). For using extensions or sharing code within a team, see [[tilt-extensions]].

## 1. Create the extension locally

1. Fork and clone `tilt-extensions`.
2. Add your code at `extension_name/Tiltfile`, e.g.:

   ```python
   def hi():
     print("Hello world!")
   ```

3. In a test project, point the default repo at your local clone and load it:

   ```python
   v1alpha1.extension_repo(name='default', url='file:///abs/path/tilt-extensions')
   load('ext://extension_name', 'hi')
   hi()
   ```

## 2. Package and submit a PR

- Update the root `README.md` describing your extension.
- Add `extension_name/README.md` with: extension name, author, brief description of the functions, and usage.
- Optionally add `extension_name/test/` with a working example project — the repo's CI runs it to verify all servers come up.
- Submit a pull request prefixed with the extension name (e.g. `min_tilt_version: fix bug foobar`).

Ideas but not sure where to start? The [[tilt|Tilt]] community bats around extension ideas, or file a feature request in the issue tracker.

Related: [[tilt-extensions]], [[tiltfile]], [[starlark]].
