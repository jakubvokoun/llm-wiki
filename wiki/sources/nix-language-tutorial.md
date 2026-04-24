---
title: "Nix Language Basics Tutorial (nix.dev)"
tags: [nix, functional-programming, build-systems, nixos, nixpkgs]
sources: [nix-language-tutorial.md]
updated: 2026-04-23
---

# Nix Language Basics Tutorial

Official nix.dev tutorial covering the Nix expression language — a purely functional DSL used to author [Nixpkgs](https://github.com/NixOS/nixpkgs) (world's largest software distribution) and [NixOS](https://nixos.org) configurations.

## Core Characteristics

- **Purely functional** — no mutable state, no side effects during evaluation
- **Lazy** — expressions evaluated on demand
- **Domain-specific** — designed exclusively for describing derivations (build recipes)
- **Dynamically typed** — types checked at evaluation time

## Name Binding

Three mechanisms:

**Attribute set** — key/value collection, the primary data structure:

```nix
{
  string  = "hello";
  integer = 1;
  list    = [ 1 "two" false ];
  nested  = { a = "value"; };
}
```

**Let expression** — scoped binding:

```nix
let x = 1; y = 2; in x + y
```

**Recursive attribute set (`rec`)** — allows self-reference:

```nix
rec {
  one = 1;
  two = one + 1;
}
```

## Strings

- **Interpolation**: `"hello ${name}"`
- **Indented strings**: `''multi\nline''` (strip common leading whitespace)
- **File system paths**: `./relative` or `/absolute` — automatically copied to Nix store

## Functions

Every function takes exactly **one argument**. Multiple parameters use currying:

```nix
# Single argument
x: x + 1

# Curried (multiple args)
x: y: x + y

# Attribute set destructuring
{ a, b }: a + b

# With defaults
{ a, b ? 0 }: a + b

# With rest / named set
{ a, b, ... }@args: a + b + args.c
```

## Standard Libraries

| Library    | Access      | Notes                                                |
| ---------- | ----------- | ---------------------------------------------------- |
| `builtins` | top-level   | Built into the interpreter (C++); ~80 functions      |
| `import`   | top-level   | Load a `.nix` file                                   |
| `pkgs.lib` | via nixpkgs | Extensive utility functions for strings, lists, sets |

## Impurities (Controlled)

| Mechanism                        | What it does                                 |
| -------------------------------- | -------------------------------------------- |
| Path interpolation `"${./file}"` | Copies file to Nix store, returns store path |
| `builtins.fetchurl`              | Download a file                              |
| `builtins.fetchTarball`          | Download + unpack archive                    |
| `builtins.fetchGit`              | Clone a git repository                       |
| `builtins.fetchClosure`          | Fetch a Nix store closure                    |

## Derivations

The fundamental concept — a description of how to build output files from inputs. Evaluation produces a path in `/nix/store/<hash>-<name>`.

```nix
# Low-level primitive
derivation { ... }

# Practical wrapper
stdenv.mkDerivation {
  pname = "hello";
  version = "2.12";
  src = fetchurl { url = "..."; };
}
```

Derivations coerce to their store path string when interpolated:

```nix
"${pkgs.nix}"  # → /nix/store/<hash>-nix-<version>
```

## Common Patterns

**Shell environment** (`shell.nix`):

```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShellNoCC {
  packages = with pkgs; [ cowsay ];
}
```

**Interactive REPL**: `nix repl`

**File evaluation**: `nix-instantiate --eval file.nix --strict`

## See Also

- [Nix Language](../concepts/nix-language.md)
- [Nix](../entities/nix.md)
- [Nix Best Practices](nix-best-practices.md)
