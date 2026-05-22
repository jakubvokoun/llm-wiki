---
title: "OpenSCAP — Getting Started"
tags: [openscap, scap, security-compliance, oscap, scap-workbench, scanning]
sources: [openscap-getting-started.md]
updated: 2026-05-22
---

# OpenSCAP — Getting Started

Introductory walkthrough for running a SCAP compliance scan using both the graphical SCAP Workbench and the `oscap` command-line tool.

## Core Concepts

- **SCAP scanner**: reads a SCAP security policy and checks system compliance rule by rule
- **Security policy** (SCAP content): machine-readable rules describing required system configuration; provided by SCAP Security Guide (SSG)

## 1. Graphical Interface (SCAP Workbench)

### Install

```bash
# Fedora / RHEL / CentOS / Scientific Linux
yum install scap-workbench
```

### Workflow

1. Launch SCAP Workbench
2. Select a **security policy** (SSG provides several automatically)
3. Select a **profile** within that policy (subset of rules for a specific baseline)
4. Run the scan — takes a few minutes
5. Review results overview; export as HTML, ARF, or XCCDF

## 2. Command Line (oscap)

### Install

```bash
yum install openscap-scanner
yum install scap-security-guide   # provides policy files
```

### Inspect available profiles

```bash
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

### Run a scan

```bash
oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_rht-ccp \
  --results-arf arf.xml \
  --report report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel6-ds.xml
```

Options:

- `--profile`: selects the security baseline
- `--results-arf`: saves results in ARF (reusable Result DataStream) format
- `--report`: generates a human-readable HTML report

### Policy files location

SSG content is installed to `/usr/share/xml/scap/ssg/content/`. Use datastream files (`*-ds.xml`) for most use cases.

## Related

- [OpenSCAP Base tool](../sources/openscap-base-tool.md)
- [SCAP Security Guide](../sources/openscap-scap-security-guide.md)
- [OpenSCAP Security Compliance](../sources/openscap-security-compliance.md)
- [OpenSCAP Vulnerability Assessment](../sources/openscap-vulnerability-assessment.md)
- [Choosing a SCAP Policy](../sources/openscap-choosing-policy.md)
