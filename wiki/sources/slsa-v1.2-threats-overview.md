---
title: "SLSA v1.2 — Supply Chain Threats Overview"
tags: [slsa, supply-chain-security, threat-modeling]
sources: [slsa-v1.2-threats-overview.md]
updated: 2026-05-07
---

# Supply Chain Threats Overview

SLSA categorizes supply chain threats into 9 groups labeled (A) through (I), covering the full lifecycle from source creation to end-user consumption.

## Threat categories

| ID | Category | Description |
| --- | --- | --- |
| A | Producer | Intentionally malicious code from the software producer |
| B | Modifying the source | Unauthorized changes to source before build |
| C | Source code management (SCM) | Infrastructure-level compromise of the SCM platform |
| D | External build parameters | Build from wrong source, branch, or with injected parameters |
| E | Build process | Tampering during build execution, or forged provenance |
| F | Artifact publication | Upload artifact not matching intended source |
| G | Distribution channel | Registry compromise or MITM during distribution |
| H | Package selection | Consumer requests wrong package (typosquatting, dependency confusion) |
| I | Usage | Consumer uses package insecurely |

## Real-world examples

| Attack | Threat | Description |
| --- | --- | --- |
| SolarWinds | E | Build process compromise injected backdoor into Orion build output |
| Codecov | D/E | CI script modification exfiltrated credentials to alter subsequent builds |
| event-stream (npm) | A | Malicious maintainer published version targeting bitcoin wallets |
| PHP | C | Server compromise pushed backdoor commit directly to `php-src` |
| SushiSwap | B | Supply chain attack through malicious dependency |

## What SLSA mitigates

- **Source track** addresses threats A, B, C through source provenance and two-party review
- **Build track** addresses threats D, E, F, G through build provenance and signature verification
- Threats H, I require complementary measures (package ecosystem controls, secure-by-design)

## Dependency threats

Dependencies are highly recursive — threats apply recursively through the supply chain. SLSA v1.2 does not fully address dependency threats; future versions are expected to.

## Related pages

- [Threats & Mitigations (detailed)](slsa-v1.2-threats.md) — full technical analysis with examples and mitigations per sub-threat
- Concept: [SLSA](../concepts/slsa.md)
- Concept: [Supply Chain Security](../concepts/supply-chain-security.md)
