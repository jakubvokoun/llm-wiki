# Nix Language Basics - Tutorial Summary

## Overview

The Nix language is a domain-specific, purely functional programming language designed specifically for creating and composing derivations—precise descriptions of how to transform existing files into new ones.

**Key Applications:**
- Nixpkgs: The world's largest software distribution, written entirely in Nix
- NixOS: A Linux distribution configured declaratively using Nix language and Nixpkgs

## Core Concepts

### Names and Values

The language provides three mechanisms for assigning names to values:

**Attribute Sets** - Collections of name-value pairs enclosed in braces:
```nix
{
  string = "hello";
  integer = 1;
  list = [ 1 "two" false ];
  nested = { a = "value"; };
}
```

**Let Expressions** - For scoped name bindings:
```nix
let
  x = 1;
  y = 2;
in
x + y
```

**Recursive Attribute Sets** - Allow self-reference within the set:
```nix
rec {
  one = 1;
  two = one + 1;
}
```

### String Features

**String Interpolation** - Insert expressions into strings with `${ }`:
```nix
let name = "Nix"; in "hello ${name}"
# Evaluates to: "hello Nix"
```

**Indented Strings** - Multi-line strings using double single quotes:
```nix
''
  multi
  line
  string
''
```

**File System Paths** - Direct path syntax:
```nix
./relative/path    # Relative to current file
/absolute/path     # Absolute path
```

## Functions

Every function takes exactly one argument. Multiple arguments use currying (nested functions).

**Single Argument:**
```nix
x: x + 1
```

**Multiple Arguments:**
```nix
x: y: x + y
```

**Attribute Set Destructuring:**
```nix
{ a, b }: a + b
```

With defaults:
```nix
{ a, b ? 0 }: a + b
```

Allowing extra attributes:
```nix
{ a, b, ... }: a + b
```

**Named Attribute Set:**
```nix
{ a, b, ... }@args: a + b + args.c
```

## Function Libraries

**Builtins** - Functions built into the language interpreter (implemented in C++):
```nix
builtins.toString
```

Notable exception is `import`, available at top level:
```nix
import ./file.nix
```

**Nixpkgs Library** - Accessed via `pkgs.lib`, providing extensive utility functions:
```nix
pkgs.lib.strings.toUpper "example"
```

## Impurities

The language supports reading files as build inputs through controlled impurity:

**File Paths** - Copying files to the Nix store during evaluation:
```nix
"${./data}"  # Results in /nix/store/<hash>-data
```

**Fetchers** - Built-in functions for network downloads:
- `builtins.fetchurl` - Download individual files
- `builtins.fetchTarball` - Download and unpack archives
- `builtins.fetchGit` - Clone git repositories
- `builtins.fetchClosure` - Fetch Nix store closures

## Derivations

Derivations are the fundamental concept—descriptions of how to build files from inputs. The primitive function is `derivation()`, though it's typically wrapped by `stdenv.mkDerivation()` in practice.

Key property: Derivations evaluate to attribute sets that can be interpolated as strings, producing their Nix store output paths:

```nix
"${pkgs.nix}"  # Produces: /nix/store/<hash>-nix-<version>
```

## Practical Examples

**Shell Environment:**
```nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShellNoCC {
  packages = with pkgs; [ cowsay ];
  shellHook = ''cowsay hello'';
}
```

**Package Declaration:**
```nix
{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hello";
  version = "2.12";
  src = fetchurl { url = "mirror://gnu/..."; };
}
```

## Running Examples

Use `nix repl` for interactive evaluation or `nix-instantiate --eval file.nix` for file-based evaluation. The `--strict` flag forces full evaluation of lazy structures.
