---
title: "Tilt Extensions"
tags: [tilt, starlark, reuse, ecosystem]
sources: [tilt-extensions, tilt-contribute-extension, tilt-custom-buttons]
updated: 2026-07-01
---

# Tilt Extensions

**Tilt extensions** package reusable [[tiltfile|Tiltfile]] functionality — [[starlark|Starlark]] functions — so teams can share common configuration instead of copy-pasting it. Loaded with `load('ext://<name>', '<symbol>')`.

## Sources

- **Default repository** — the community [tilt-extensions](https://github.com/tilt-dev/tilt-extensions) repo, referenced via the `ext://` prefix.
- **Custom repositories** — register another Git repo with `v1alpha1.extension_repo`.
- **Local paths** — load Starlark files directly during development.

## Examples

- `uibutton` — adds interactive buttons to the [[tilt-tutorial-3-tilt-ui|web UI]] that run local commands, with inputs like text fields and checkboxes ([[tilt-custom-buttons]]).
- Many helpers for registries, Helm, restart wrappers, namespace management, etc.

## Contributing

New extensions are contributed to the shared repo via pull request — create the Starlark, add metadata/tests, and submit ([[tilt-contribute-extension]]).

Related: [[tilt-snippets]], [[tiltfile]].
