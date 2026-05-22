---
title: "OpenSCAP — Security Policy Customization (Tailoring)"
tags: [openscap, scap, tailoring, customization, xccdf, scap-workbench]
sources: [openscap-customization.md]
updated: 2026-05-22
---

# OpenSCAP — Security Policy Customization (Tailoring)

Customization (also called _tailoring_) allows adjusting SCAP security policies without modifying the original content.

## What Is Customization?

Customization stores adjustments separately from the original policy, allowing the base policy to receive updates and bugfixes without overwriting your changes. It can:

- **Select / deselect** individual rules or rule groups
- **Change rule values** (e.g., minimum password length)
- Make a policy **stricter** or **more lenient** (e.g., allow root SSH login)

You can also tailor signed XCCDF content without invalidating the signatures.

## How to Customize with SCAP Workbench

1. Open any content in SCAP Workbench
2. Click **Customize** — creates a new profile inheriting everything from the original
3. Select/deselect rules and groups; change XCCDF Values
4. Test on a few machines
5. Save as an **XCCDF Tailoring file** (XML format containing only the new profile)

The original content file is still required for evaluation alongside the tailoring file.

## Deploying Tailoring Files

The tailoring XML file can be used with:

- `oscap` command-line tool
- SCAP Workbench
- OpenSCAP Daemon
- Spacewalk
- Foreman

## Key Concepts

- **Profiles extend, not replace**: tailored profiles inherit from the base profile
- **Separation of concerns**: original policy content stays intact; customizations are portable
- **XCCDF Values**: per-rule configurable parameters (password length, retry counts, etc.)

## Related

- [SCAP Security Guide](../sources/openscap-scap-security-guide.md)
- [OpenSCAP Getting Started](../sources/openscap-getting-started.md)
- [Choosing a SCAP Policy](../sources/openscap-choosing-policy.md)
- [OpenSCAP Base Tool](../sources/openscap-base-tool.md)
