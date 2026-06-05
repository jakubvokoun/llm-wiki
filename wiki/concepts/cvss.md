---
title: "CVSS (Common Vulnerability Scoring System)"
tags: [cvss, severity, first, vulnerability, risk, nvd]
sources:
  [intel-psirt-vulnerability-handling.md, kroah-linux-cve-assignment-process.md]
updated: 2026-06-05
---

# CVSS (Common Vulnerability Scoring System)

A [FIRST](../entities/first.md)-maintained framework for rating the **technical severity** of a vulnerability on a 0–10 scale, via Base, Temporal, and Environmental metric groups.

## Severity bands (Base score)

| Category | Score    |
| -------- | -------- |
| Critical | 9.0–10.0 |
| High     | 7.0–8.9  |
| Medium   | 4.0–6.9  |
| Low      | 0.0–3.9  |

## Severity ≠ risk

CVSS captures intrinsic severity, **not** risk. [Intel](../sources/intel-psirt-vulnerability-handling.md) publishes only the **Base Score** and tells customers to evaluate impact in their own environment — Base score is an _input_ to risk, not the answer.

## The kernel critique

The Linux kernel [CNA](cve-numbering-authority.md) goes further and **refuses to assign severity at all**: open source maintainers don't know how the software is used, so any third-party score (e.g. NVD/NIST) is "false" unless the scorer knows your exact deployment. [GKH asked NIST to stop](https://github.com/cisagov/vulnrichment/issues/262) scoring kernel CVEs, arguing bad scores both delay needed updates and trigger unnecessary ones. The only legitimate scoring is by groups sharing an identical deployment. See [Linux CVE assignment process](../sources/kroah-linux-cve-assignment-process.md).

## Related

- [CVE](cve.md) · [PSIRT](psirt.md) · [Vulnerability Handling](vulnerability-handling.md)
- [FIRST](../entities/first.md)
