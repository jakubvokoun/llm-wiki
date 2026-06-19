---
title: "CVSS (Common Vulnerability Scoring System)"
tags: [cvss, severity, first, vulnerability, risk, nvd]
sources:
  [
    cvss-v4-specification-document.md,
    cvss-v4-user-guide.md,
    cvss-v4-implementation-guide.md,
    cvss-v4-examples.md,
    cvss-v4-faq.md,
    intel-psirt-vulnerability-handling.md,
    kroah-linux-cve-assignment-process.md,
  ]
updated: 2026-06-19
---

# CVSS (Common Vulnerability Scoring System)

A [FIRST](../entities/first.md)-owned, vendor- and platform-agnostic open framework for rating the **technical severity** of a vulnerability on a 0–10 scale. The current version is **v4.0**. Free to use (attribution required); publishers must provide both the score **and** the vector string so others can see how it was derived.

## Four metric groups (v4.0)

| Group             | Who sets it                    | What it captures                                                                             |
| ----------------- | ------------------------------ | -------------------------------------------------------------------------------------------- |
| **Base**          | Vendor / analyst               | Intrinsic, constant characteristics. Assumes reasonable worst case. Produces the 0–10 score. |
| **Threat**        | Consumer                       | Time-varying exploit maturity (PoC, active exploitation). Was "Temporal" in v3.x.            |
| **Environmental** | Consumer                       | Deployment-specific modifiers + security requirements (CIA criticality).                     |
| **Supplemental**  | Provider (consumer interprets) | Extrinsic context (Safety, Automatable, Recovery, etc.) — **never changes the score**.       |

Base metrics + worst-case defaults for Threat/Environmental produce the headline score; consumers then **enrich** with their own Threat and Environmental data for a sharper input to risk.

## Nomenclature (label which groups you used)

A raw number is ambiguous, so v4.0 mandates a label:

| Label        | Metrics used                  |
| ------------ | ----------------------------- |
| **CVSS-B**   | Base only                     |
| **CVSS-BT**  | Base + Threat                 |
| **CVSS-BE**  | Base + Environmental          |
| **CVSS-BTE** | Base + Threat + Environmental |

NVD and most vendors publish only **CVSS-B**. Applying Threat/Environmental is the consumer's job.

## Base metrics at a glance

- **Exploitability:** Attack Vector (N/A/L/P), Attack Complexity (L/H), **Attack Requirements (AT)** — new in v4.0, splits out prerequisite execution conditions (race conditions, on-path injection) from AC; Privileges Required (N/L/H), **User Interaction** — now three levels (None / Passive / Active).
- **Impact (split system):** the v3 "Scope" concept is replaced by two impact sets — **Vulnerable System** (VC/VI/VA) and **Subsequent System** (SC/SI/SA), each rating Confidentiality / Integrity / Availability as H/L/N. A vulnerability with no downstream effect leaves the Subsequent set at None.

Vector string example: `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`.

## Severity ≠ risk

CVSS captures intrinsic severity, **not** risk. [Intel](../sources/intel-psirt-vulnerability-handling.md) publishes only the Base Score and tells customers to evaluate impact in their own environment — Base score is an _input_ to risk, not the answer. v4.0 leans into this with its **maturity model** ([implementation guide](../sources/cvss-v4-implementation-guide.md)): the goal is to progress from Base-only to Base+Threat+Environmental scoring.

## v4.0 vs v3.1 — what changed and why

- v3.1 scores clustered toward **High/Critical**; v4.0 adds finer metrics (AT, three-level UI, split impacts) to spread the distribution and improve discrimination.
- "Temporal" → **Threat**; Remediation Level and Report Confidence were dropped; the group now centers on **Exploit Maturity (E)**. Applying threat data only ever **lowers** the score.
- Scores are not directly comparable across versions; the [FAQ](../sources/cvss-v4-faq.md) gives a heuristic for deriving v3.1 vectors from v4.0.

## Relationship to EPSS / SSVC

CVSS answers _"how severe?"_ — not _"how likely to be exploited?"_ ([EPSS](epss.md)) or _"what should I do?"_ ([SSVC](ssvc.md)). They are complements, not replacements: CVSS is a common input to both. The FAQ also discusses applying CVSS concepts to AI/LLM issues and its relation to AIVSS.

## The kernel critique

The Linux kernel [CNA](cve-numbering-authority.md) **refuses to assign severity at all**: maintainers don't know how the software is deployed, so any third-party score (NVD/NIST) is "false" unless the scorer knows your exact environment. [GKH asked NIST to stop](https://github.com/cisagov/vulnrichment/issues/262) scoring kernel CVEs — bad scores both delay needed updates and trigger unnecessary ones. This aligns with v4.0's own message: the Base score is just a starting point. See [Linux CVE assignment process](../sources/kroah-linux-cve-assignment-process.md).

## Related

- [CVE](cve.md) · [PSIRT](psirt.md) · [Vulnerability Handling](vulnerability-handling.md) · [EPSS](epss.md) · [SSVC](ssvc.md)
- [FIRST](../entities/first.md)
- Sources: [Specification](../sources/cvss-v4-specification-document.md) · [User Guide](../sources/cvss-v4-user-guide.md) · [Implementation Guide](../sources/cvss-v4-implementation-guide.md) · [Examples](../sources/cvss-v4-examples.md) · [FAQ](../sources/cvss-v4-faq.md)
