---
title: "openQA Test API & Test Modules"
tags: [openqa, testing, perl, python, lua, dsl]
sources:
  [openqa-writing-tests.md, openqa-python-tests.md, openqa-getting-started.md]
updated: 2026-06-23
---

# openQA Test API & Test Modules

The API tests use to drive the system under test, provided by [os-autoinst](../entities/os-autoinst.md) ([`testapi.pm`](https://github.com/os-autoinst/os-autoinst/blob/master/testapi.pm)). Because it reads like a domain-specific language, it is often called the **openQA DSL**. Full reference: [open.qa/api/testapi](http://open.qa/api/testapi/).

## Languages

Tests can be written in **Perl** (the original and most common), **Python** (requires `Inline::Python`) or **Lua** (requires `Inline::Lua`). The API maps transparently across all three — the same function names are available, so a Python test is essentially a line-for-line translation of the Perl one.

## Test modules

A **test module** is a single test case in one file (e.g. `sshxterm.pm`). It must implement at least a `run` subroutine and be loaded in the distribution's `main.pm` via `loadtest`. A **test suite** is a collection of modules run serially.

```perl
use Mojo::Base 'basetest', -signatures;   # enables modern Perl
use testapi;
sub run { assert_screen 'desktop', 300; }
```

```python
from testapi import *
def run(self):
    assert_screen('desktop', 300)
```

### Module interface

- `run(self)` — the actual test steps (required).
- `test_flags()` _(optional)_ — dict controlling behaviour on completion:
  - `fatal` — abort the whole suite if this module fails (overall `failed`)
  - `always_run` — run even if a previous module was `fatal`
  - `ignore_failure` — a failure doesn't affect the overall result
  - `milestone` — update the SUT's `lastgood` snapshot after success
  - `no_rollback` — don't roll back to `lastgood` on failure
- `post_fail_hook()` _(optional)_ — runs on failure (e.g. collect logs, switch to a console).
- `pre_run_hook()` / `post_run_hook()` _(optional)_.

## Common API functions

| Function                         | Purpose                                                          |
| -------------------------------- | ---------------------------------------------------------------- |
| `assert_screen 'tag'[, timeout]` | Fail unless a [needle](needle-matching.md) with that tag matches |
| `assert_and_click 'tag'`         | Match a needle, then click its click point                       |
| `send_key 'ret'`                 | Press a single key (e.g. `ctrl-alt-f3`)                          |
| `type_string '...'`              | Type text on the keyboard                                        |
| `assert_script_run 'cmd'`        | Run a shell command and assert it succeeded                      |
| `record_soft_failure`            | Record a known non-critical issue (→ `softfailed`)               |

## Related Pages

- [Needle matching](needle-matching.md)
- [Jobs](openqa-jobs.md)
- [os-autoinst](../entities/os-autoinst.md)
- [openQA](../entities/openqa.md)
- [Writing Tests (source)](../sources/openqa-writing-tests.md)
- [Python tests (source)](../sources/openqa-python-tests.md)
