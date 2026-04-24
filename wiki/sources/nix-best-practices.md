---
title: "Nix Best Practices (nix.dev)"
tags: [nix, best-practices, reproducibility, nixpkgs]
sources: [nix-best-practices.md]
updated: 2026-04-23
---

# Nix Best Practices

Official nix.dev guide covering 7 best practices for writing correct, reproducible Nix expressions.

## 1. Always Quote URLs

Bare URL syntax (`https://example.com`) is deprecated (RFC 45). Always use quoted strings:

```nix
# Bad
fetchurl https://example.com/file.tar.gz

# Good
fetchurl "https://example.com/file.tar.gz"
```

## 2. Avoid `rec { ... }`

`rec` enables self-reference but causes subtle `infinite recursion` errors when shadowing names.

```nix
# Pitfall
let a = 1; in rec { a = a; }  # infinite recursion!

# Good: use let...in
let a = 1; in { a = a; b = a + 2; }

# Self-reference without rec: name the set explicitly
let
  argset = { a = 1; b = argset.a + 2; };
in argset
```

## 3. Avoid `with` at Top Level

`with pkgs;` brings all attributes into scope — hurts static analysis, creates ambiguous name origins, has non-intuitive scoping rules.

```nix
# Bad
with (import <nixpkgs> {});
# ... lots of code using names of unknown origin

# Good: explicit let binding
let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) curl jq;
in # ...

# Alternative for buildInputs
buildInputs = builtins.attrValues { inherit (pkgs) curl jq; };
```

## 4. Avoid `<...>` Lookup Paths

`<nixpkgs>` resolves via `$NIX_PATH` — differs machine to machine, breaks reproducibility. Different developers get different revisions.

```nix
# Bad (for production code)
import <nixpkgs> {}

# Good: pin explicitly (fetchTarball with sha256, or flake input)
import (fetchTarball { url = "..."; sha256 = "..."; }) {}
```

If a tool requires `$NIX_PATH`, set it to a known value under version control. On NixOS: `nix.nixPath` option.

## 5. Reproducible Nixpkgs Configuration

Even with a pinned Nixpkgs, `import <nixpkgs> {}` reads host system configuration files — non-reproducible.

```nix
# Always set config and overlays explicitly
import <nixpkgs> { config = {}; overlays = []; }
```

## 6. Updating Nested Attribute Sets

The `//` update operator is **shallow** — right-side values completely replace left-side values at the top level:

```nix
{ a = { b = 1; }; } // { a = { c = 3; }; }
# Result: { a = { c = 3; }; }   ← b is lost!
```

For deep merges use `pkgs.lib.recursiveUpdate`:

```nix
pkgs.lib.recursiveUpdate { a = { b = 1; }; } { a = { c = 3; }; }
# Result: { a = { b = 1; c = 3; }; }
```

## 7. Reproducible Source Paths

Using `src = ./.` derives the store path from the **parent directory name** — non-reproducible if the directory name changes.

```nix
# Bad: store path includes working dir name
src = ./.;

# Good: fix the symbolic name with builtins.path
src = builtins.path { path = ./.; name = "myproject"; };
```

## Summary

| Practice       | Rule                                        |
| -------------- | ------------------------------------------- |
| URLs           | Always quote                                |
| `rec`          | Avoid — use `let...in`                      |
| `with`         | Avoid at top level — use `inherit` in `let` |
| `<nixpkgs>`    | Avoid in production — pin explicitly        |
| Nixpkgs import | Pass `config = {}; overlays = []`           |
| Nested update  | Use `lib.recursiveUpdate` not `//`          |
| Source paths   | Use `builtins.path` with explicit `name`    |

## See Also

- [Nix Language](../concepts/nix-language.md)
- [Nix](../entities/nix.md)
- [Nix Language Basics Tutorial](nix-language-tutorial.md)
