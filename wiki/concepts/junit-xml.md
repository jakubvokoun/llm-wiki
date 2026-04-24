---
title: "JUnit XML Format"
tags: [testing, ci-cd, xml, test-results, interoperability]
sources: [junitxml-testmoapp.md]
updated: 2026-04-23
---

# JUnit XML Format

De facto standard format for exchanging test results between testing tools and CI/CD systems. Originated with JUnit (Java), now widely adopted across languages and ecosystems. **No official specification exists** — behavior is defined by convention.

## Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="Suite" tests="3" failures="1" errors="0" skipped="0" time="1.234">
  <testsuite name="MyClass" tests="3" failures="1" time="1.234">
    <testcase name="test_passes" classname="MyClass" time="0.1"/>
    <testcase name="test_fails" classname="MyClass" time="0.5">
      <failure message="Expected 1 but got 2">AssertionError: ...</failure>
    </testcase>
    <testcase name="test_skip" classname="MyClass" time="0.0">
      <skipped message="not implemented yet"/>
    </testcase>
  </testsuite>
</testsuites>
```

## Pass-by-Default Model

A `<testcase>` with no child result element is implicitly **passing**. Only `<failure>`, `<error>`, or `<skipped>` mark non-passing outcomes.

| Child element | Meaning                       |
| ------------- | ----------------------------- |
| (none)        | Pass                          |
| `<skipped>`   | Intentionally skipped         |
| `<failure>`   | Assertion/expectation not met |
| `<error>`     | Unexpected exception or crash |

## Metadata via Properties

Both `<testsuite>` and `<testcase>` accept `<properties>`:

```xml
<properties>
  <property name="browser" value="Chrome 120"/>
  <property name="attachment" value="screenshot.png"/>
</properties>
```

Used for environment info, CI pipeline data, attachments, step tracking.

## Attachment Conventions

| Method           | How                                      |
| ---------------- | ---------------------------------------- |
| File path        | Property value = filesystem path         |
| URL              | Property value = HTTP URL                |
| Inline data URI  | Base64-encoded content embedded directly |
| Output reference | Special markers in `<system-out>`        |

## Tool Variation

Different tools (Jenkins, GitLab CI, GitHub Actions, pytest, Jest, …) support different subsets. Always test against your target consumer when producing JUnit XML.

## Common Producers

- Python: `pytest` with `--junitxml`
- JavaScript: Jest, Mocha
- Java: JUnit 4/5, TestNG
- Go: `gotestsum`
- Ruby: RSpec

## See Also

- [CI/CD Security](cicd-security.md)
- [JUnit XML Format Reference](../sources/junitxml-testmoapp.md)
