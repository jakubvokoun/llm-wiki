---
title: "JUnit XML Format Reference (testmoapp)"
tags: [testing, ci-cd, xml, test-results, junit]
sources: [junitxml-testmoapp.md]
updated: 2026-04-23
---

# JUnit XML Format Reference

Community-maintained reference by [Testmo](https://testmo.com) documenting the JUnit XML format — the de facto standard for exchanging test results between tools. No official specification exists; this captures conventions supported by many popular CI/CD and testing tools.

## Document Structure

Hierarchical XML:

```
testsuites (optional root)
└── testsuite (class, folder, or test group)
    └── testcase (individual test result)
```

Tests **pass by default** — a testcase is passing unless it contains a result child element.

## Result Elements

| Element   | Meaning                        |
| --------- | ------------------------------ |
| `skipped` | Test was intentionally skipped |
| `failure` | Assertion/expectation failed   |
| `error`   | Unexpected exception/crash     |

## Suite and Case Attributes

**testsuite**: `name`, `tests`, `failures`, `errors`, `skipped`, `time`, `timestamp`, `hostname`, `file`

**testcase**: `name`, `classname`, `time`, `assertions`, `file`, `line`

## Properties and Metadata

Both `testsuite` and `testcase` accept `<properties>` child elements with arbitrary key/value pairs. Common uses:

- Environment variables and version info
- Browser and CI pipeline references
- Custom configuration
- Multi-line text values

## Attachments

Four conventions for attaching artifacts to test results:

1. **File paths** — property value is a filesystem path
2. **URLs** — property value is an HTTP URL to an external file
3. **Inline data URIs** — base64-encoded content embedded directly
4. **Output-based references** — special formatting in `<system-out>` or `<system-err>`

Property naming convention: `attachment`, `attachment1`, `attachment2`, …

## Steps

Test steps documented via `step*` properties with optional status indicators (e.g. `step1`, `step1_status`).

## Type Hints

Properties may include format hints: `url:name`, `console:log`, etc., for specialized rendering in consuming tools.

## Standards Note

Tools produce different "flavors" — not all elements are supported by all tools. This reference documents the commonly supported subset, not a rigid specification.

## Key Takeaways

- No formal standard — conventions only; expect tool variation
- Pass-by-default model: absence of failure element = pass
- Properties mechanism is the extension point for metadata and attachments
- Four attachment strategies let producers embed or reference artifacts flexibly

## See Also

- [CI/CD Security](../concepts/cicd-security.md)
