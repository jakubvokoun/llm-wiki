---
title: "SLSA v1.2 — Source Requirements"
tags: [slsa, supply-chain-security, source-control]
sources: [slsa-v1.2-source-requirements.md]
updated: 2026-05-07
---

# SLSA Source Requirements

Requirements for software producers and Source Control Systems (SCS) to achieve Source Track levels.

## Source Track levels overview

| Level | Key property |
| --- | --- |
| L1 | Source is available in a version control system |
| L2 | Source history is retained and unalterable |
| L3 | Source changes follow a documented process with machine enforcement |
| L4 | Two-party review required for all changes; strong identity for reviewers |

## Key roles

- **Version Control System (VCS)**: Tool for tracking changes (e.g., Git)
- **Source Control System (SCS)**: Hosted platform providing VCS + access controls (e.g., GitHub, GitLab)
- **Organization**: The team/company that owns the software project
- **Contributor**: Person submitting changes
- **Reviewer**: Person approving changes (separate from contributor at L4)

## Organization requirements per level

### L1 — Exists

- Source code is available in a VCS
- History is retained (all commits accessible)

### L2 — Branch history immutable

- Protected branches cannot have history rewritten (no force push)
- Tags pointing to protected revisions cannot be updated
- Source provenance (from SCS) available describing commit metadata

### L3 — Process enforced

- Organization documents its development process
- SCS enforces technical controls matching the documented process
- Examples: required CI checks, test coverage requirements

### L4 — Two-party review

- All changes to protected branches require approval from at least one person other than the author
- Bot accounts cannot satisfy the human reviewer requirement
- Approvals are invalidated when the proposed change is modified
- One actor cannot control multiple accounts to self-approve

## SCS requirements per level

| Level | SCS must provide |
| --- | --- |
| L1 | VCS with retained history, publicly accessible revision IDs |
| L2 | Protected branch history (no rewrite); signed source provenance |
| L3 | Technical enforcement of documented process; API for querying controls |
| L4 | Two-party review enforcement; identity verification; approval invalidation on change |

## Source VSA format

A Source VSA is issued by a trusted verifier after evaluating the SCS. Contains:

- `verifiedLevels`: which Source Track levels were achieved
- `resourceUri`: identifies the source repository and revision
- `policy`: the policy evaluated against
- `verifier`: the trusted entity issuing the VSA

## Related pages

- [Verifying Source](slsa-v1.2-verifying-source.md) — consumer verification process
- [Threats & Mitigations](slsa-v1.2-threats.md) — threats A–C that Source Track addresses
- Concept: [SLSA Source Track](../concepts/slsa-source-track.md)
