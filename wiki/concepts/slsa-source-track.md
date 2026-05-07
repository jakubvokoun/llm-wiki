---
title: "SLSA Source Track"
tags: [slsa, supply-chain-security, source-control]
sources: [slsa-v1.2-source-requirements.md, slsa-v1.2-verifying-source.md]
updated: 2026-05-07
---

# SLSA Source Track

The Source Track addresses how source code is managed, changed, and recorded — protecting against unauthorized modifications and integrity degradation at the source level.

## Trust model

The trust anchor is the **Source Control System (SCS)** — the hosted platform (e.g., GitHub, GitLab) that manages the source repository. Consumers trust specific SCSes and verify source provenance from those SCSes.

## Levels

### Level 1 — Exists

- Source stored in a VCS with retained history
- All commits publicly accessible at stable URLs
- History must be retained (no deletion)

### Level 2 — Branch history immutable

- Protected branches cannot have history rewritten (no force push to main)
- Protected tags cannot be updated
- SCS issues signed source provenance describing commit metadata

### Level 3 — Process enforced

- Organization documents its development process (review requirements, test coverage, etc.)
- SCS enforces these requirements through technical controls
- Machine enforcement, not just policy

### Level 4 — Two-party review

- All changes to protected branches require approval from at least one person other than the author
- Bot accounts cannot satisfy the reviewer requirement
- Approvals invalidated when proposed change is modified after approval
- No single actor can control multiple accounts to self-approve

## Key roles

| Role | Description |
| --- | --- |
| VCS | Tool for tracking changes (Git) |
| SCS | Hosted platform providing VCS + access controls (GitHub, GitLab) |
| Organization | Team/company owning the project |
| Contributor | Person submitting changes |
| Reviewer | Person approving changes (distinct from contributor at L4) |

## Consumer verification (3 steps)

1. **Check SCS controls:** Evaluate or rely on a trusted verifier's assessment of the SCS level
2. **Check expectations:** Source from canonical repo, revision reachable from protected branch
3. **Verify source provenance:** Retrieve signed source provenance, verify signature and fields

## Relationship to Build Track

Source Track complements Build Track:

- **Source Track** ensures the source revision was created appropriately
- **Build Track** ensures the artifact was built from that source on a trusted platform

Together, they provide end-to-end chain of custody from commit to deployed binary.

## Threats addressed

| Threat                         | Level               |
| ------------------------------ | ------------------- |
| B1 — Submit without review     | L4                  |
| B2 — Alter change history      | L2+                 |
| B4 — Forge change metadata     | L2+                 |
| B3 — Render review ineffective | Not fully addressed |
| C — SCM compromise             | Verification-level  |

## Key sources

- [Source Requirements](../sources/slsa-v1.2-source-requirements.md)
- [Verifying Source](../sources/slsa-v1.2-verifying-source.md)
- Related: [SLSA](slsa.md), [Supply Chain Security](supply-chain-security.md)
