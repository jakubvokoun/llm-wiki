---
title: "Tilt Editor Support"
tags: [tilt, editor, lsp, ide]
sources: [tilt-editor-support]
updated: 2026-07-01
---

# Tilt Editor Support

[[tilt]] provides editor integration for writing [[tiltfile]]s with less friction — autocomplete, signature help, and syntax highlighting reduce the need to context-switch to documentation.

## VS Code

- Official extension: **Tiltfile** (`tilt-dev.Tiltfile`) on the VS Code Marketplace
- Features: syntax highlighting, autocomplete, and signature support for [[tiltfile]] functions
- All code is open source

## JetBrains IDEs (TextMate bundle)

- Package: [tiltfile.tmbundle](https://github.com/tilt-dev/tiltfile.tmbundle)
- Works with any IDE that supports TextMate bundles: IntelliJ GoLand, PyCharm, WebStorm
- Provides syntax highlighting

## Emacs (lsp-mode)

Requires `lsp-mode`. Add to `.emacs`:

```elisp
(require 'python-mode)

(define-derived-mode tiltfile-mode
  python-mode "tiltfile"
  "Major mode for Tilt Dev."
  (setq-local case-fold-search nil))

(add-to-list 'auto-mode-alist '("Tiltfile$" . tiltfile-mode))

(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-language-id-configuration
    '(tiltfile-mode . "tiltfile"))

  (lsp-register-client
    (make-lsp-client :new-connection (lsp-stdio-connection `("tilt" "lsp" "start"))
                     :activation-fn (lsp-activate-on "tiltfile")
                     :server-id 'tilt-lsp)))
```

Connects to the embedded Tilt language server via `tilt lsp start`.

## Other Editors / Language Server

Tilt ships an embedded language server based on [Tree Sitter](https://tree-sitter.github.io/) and [[starlark]]:

- Repo: [starlark-lsp](https://github.com/tilt-dev/starlark-lsp)
- Start manually: `tilt lsp start`
- Adding support to a new editor typically requires a few lines of config to launch the server and wire up the LSP connection
