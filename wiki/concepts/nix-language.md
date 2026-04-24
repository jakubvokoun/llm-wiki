---
title: "Nix Language"
tags: [nix, functional-programming, build-systems, derivations]
sources: [nix-language-tutorial.md]
updated: 2026-04-23
---

# Nix Language

Purely functional, lazily-evaluated DSL used to write build recipes (_derivations_) for the [Nix](../entities/nix.md) package manager. Every Nixpkgs package and NixOS configuration is written in this language.

## Type System

Dynamically typed. Core types: `string`, `integer`, `float`, `boolean`, `null`, `path`, `list`, `attribute set`, `function`, `derivation`.

## Key Characteristics

| Property          | Detail                                                   |
| ----------------- | -------------------------------------------------------- |
| Purely functional | No mutable state; same input always produces same output |
| Lazy              | Sub-expressions evaluated only when needed               |
| No I/O            | Side effects controlled via fetchers and `import`        |
| Turing complete   | Despite being a DSL, the language is Turing complete     |

## Attribute Sets

The primary data structure. Used everywhere: packages, NixOS options, module args.

```nix
{ name = "value"; nested = { a = 1; }; }
```

Access with `.`: `set.nested.a`

Override with `//`: `set // { name = "new"; }`

## Functions

All functions are single-argument lambdas. Currying handles multiple params.

```nix
# Positional
double = x: x * 2;

# Destructured attribute set
add = { a, b ? 0 }: a + b;
```

## `let` and `inherit`

```nix
let
  x = 1;
  inherit (pkgs) curl git;    # same as: curl = pkgs.curl; git = pkgs.git;
in { tools = [ curl git ]; }
```

## Derivations

A derivation is a build description. Evaluating one registers it with the Nix daemon; building it (`nix-build`) materializes the output in `/nix/store`.

```nix
stdenv.mkDerivation {
  pname   = "myapp";
  version = "1.0";
  src     = ./.;
  buildPhase = "make";
}
```

## `rec` — Avoid When Possible

`rec { a = 1; b = a + 1; }` allows self-reference but creates subtle scoping bugs. Prefer `let` for mutual references. See [Nix Best Practices](../sources/nix-best-practices.md).

## Lookup Paths (Anti-Pattern)

`<nixpkgs>` relies on `NIX_PATH` — not reproducible. Prefer pinned inputs via flakes or `fetchTarball`.

## See Also

- [Nix](../entities/nix.md)
- [Nix Language Basics Tutorial](../sources/nix-language-tutorial.md)
- [Nix Best Practices](../sources/nix-best-practices.md)
- [Atomic Linux](atomic-linux.md)
