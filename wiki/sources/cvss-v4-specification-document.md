---
title: "CVSS v4.0 Specification Document"
tags: [cvss, severity, first, vulnerability, standard]
sources: [cvss-v4-specification-document.md]
updated: 2026-06-19
---

# CVSS v4.0 Specification Document

The official, normative [FIRST](../entities/first.md) specification for [CVSS](../concepts/cvss.md) v4.0 (document v1.2). Defines the metrics, vector string, nomenclature, and scoring rules.

## Core model

- **Four metric groups:** Base (intrinsic, worst-case, produces 0–10), Threat (time-varying exploit maturity), Environmental (deployment-specific), Supplemental (extrinsic context, never affects score).
- Base + Supplemental are set by the **provider**; Threat + Environmental are the **consumer's** to enrich. Consumers feed the result into a broader risk process (regulatory needs, customers impacted, monetary/safety/reputational loss — all explicitly **out of scope** for CVSS).
- **Assumption:** assess every metric as if the attacker has perfect knowledge of the vulnerability and advanced knowledge of the target's default defenses; CVSS is agnostic to who scores it.

## Nomenclature

Numbers are labeled by the groups used: **CVSS-B**, **CVSS-BT**, **CVSS-BE**, **CVSS-BTE**. NVD and vendors typically publish CVSS-B only. In v4.0 all groups are always present in the calculation; absent Threat/Environmental selections use "Not Defined" defaults.

## Base metrics

- **Exploitability:** Attack Vector (N/A/L/P), Attack Complexity (L/H — evasion of ASLR/DEP, obtaining target secrets), **Attack Requirements (AT)** new — execution prerequisites like race conditions / on-path injection, Privileges Required (N/L/H), **User Interaction** now three-level (None / Passive / Active).
- **Impact (Scope replaced):** two sets — **Vulnerable System** (VC/VI/VA) and **Subsequent System** (SC/SI/SA), each C/I/A rated H/L/N. "System of interest" = coherent computing logic with shared security policy; a component used solely by another system is scored as part of it. Impacts outside the vulnerable system go in the Subsequent set; in the Environmental group, Subsequent impact can include **human safety**.
- Score the **final** impact ("end game"), and only count _increases_ in access/privilege.

## Threat / Environmental / Supplemental

Threat centers on Exploit Maturity (PoC vs active exploitation) and only lowers the score. Environmental holds modified base metrics + security requirements specific to a deployment. Supplemental (Safety, Automatable, Recovery, Value Density, Provider Urgency, Vulnerability Response Effort) conveys context without changing the number.

## See also

- [CVSS](../concepts/cvss.md) (concept)
- [User Guide](cvss-v4-user-guide.md)
- [Implementation Guide](cvss-v4-implementation-guide.md)
- [Examples](cvss-v4-examples.md)
- [FAQ](cvss-v4-faq.md)
- [FIRST](../entities/first.md)
- [CVE](../concepts/cve.md)
