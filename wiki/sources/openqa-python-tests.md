---
title: "Writing openQA Tests in Python (liv.pink)"
tags: [openqa, testing, python, perl, tutorial]
sources: [openqa-python-tests.md]
updated: 2026-06-23
---

# Writing openQA Tests in Python

Blog tutorial by **Liv Dywan** (2021-07-15) on writing an [openQA](../entities/openqa.md) [test module](../concepts/openqa-test-api.md) in **Python** as a user of a running instance.

## Key Takeaways

- **A "test" = a test module** — the code that drives the backend (keyboard/mouse, command running, [needle](../concepts/needle-matching.md) checks). Most existing tests are **Perl**; **Python** is a newer addition.
- **The API maps 1:1** — the same [`testapi`](../concepts/openqa-test-api.md) functions exist in both; a Python test is a near line-for-line translation of the Perl one. Perl `use testapi;` ↔ Python `from testapi import *`.
- **Common functions shown** — `assert_screen` (confirm a needle), `assert_and_click` (needle + click), `type_string`, `send_key`, `assert_script_run` (run shell cmd, assert success). Module structure: `run`, helper subs, `post_fail_hook`, `test_flags` (e.g. `{fatal: 1}`).
- **Iterating** — fork the test distribution, push a branch, then run your change with `openqa-clone-custom-git-refspec <PR-url> <test-url> FOO=1`; find the test ID from the o3 job group.
- Example used: `search.py` in `os-autoinst-distri-openQA`.

## Related Pages

- [Test API & Test Modules](../concepts/openqa-test-api.md) · [Needle matching](../concepts/needle-matching.md) · [Writing Tests (official)](openqa-writing-tests.md) · [openQA](../entities/openqa.md)
