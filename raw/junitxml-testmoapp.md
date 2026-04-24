# JUnit XML Format Reference

## Project Overview

This repository documents the common usage of JUnit-style XML files across testing and CI tools. It serves as a comprehensive reference guide for developers building software that produces or consumes these XML files.

The project notes that "the JUnit XML file format has been made popular by the JUnit project and has since become the de facto standard format to exchange test results between tools." However, since no official specification exists, this documentation captures conventions supported by many popular tools.

## Core Structure

JUnit XML files use a hierarchical structure with:
- **testsuites** (root element, optional)
- **testsuite** (represents classes, folders, or test groups)
- **testcase** (individual test results)

Test cases are considered passed by default unless they contain result elements like `skipped`, `failure`, or `error`.

## Key Features

### Basic Elements
- Test suites with aggregated metrics (tests, failures, errors, skipped counts)
- Test cases with execution time, assertions, and file references
- Result indicators for skipped, failed, and errored tests

### Properties & Metadata
Both suites and cases support additional properties for:
- Environment variables and version information
- Browser and CI pipeline references
- Custom configuration data
- Multi-line text values

### Attachments
The documentation outlines four attachment approaches:
1. **File paths** as property values
2. **URLs** for externally hosted files
3. **Inline data URIs** with base64 encoding
4. **Output-based references** using special formatting conventions

### Common Conventions
- **Attachment properties**: Named `attachment`, `attachment1`, etc.
- **Steps**: Documented via `step*` properties with optional status indicators
- **Type hints**: Format like `url:name` or `console:log` for specialized rendering

## Example Resources

The repository includes example files demonstrating:
- Basic structure (junit-basic.xml)
- Complete implementation (junit-complete.xml)
- Properties usage (testcase-properties.xml)
- Output handling (testcase-output.xml)
- Convention examples (conventions.xml)

## Standards Note

The documentation acknowledges that tools generate different "flavors" of this format and that "not all elements are supported by all tools." It emphasizes that this reference documents commonly supported features rather than a rigid specification.
