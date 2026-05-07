# Source: Requirements for producing source

Status: Approved

## Objective

The primary purpose of the SLSA Source track is to provide producers and consumers with increasing levels of trust in the source code they produce and consume. It describes increasing levels of trustworthiness and completeness of how a source revision was created.

## Definitions

A **Version Control System (VCS)** is a system for managing the version history of a set of files (Git, Mercurial, Subversion).

| Term | Description |
| --- | --- |
| Source Repository (Repo) | A self-contained unit holding content and revision history for a set of files. |
| Source Revision | A specific, logically immutable snapshot of the repository's tracked files, uniquely identified by a revision identifier (e.g. git commit SHA). |
| Named Reference | A user-friendly name for a specific source revision (e.g. `main` or `v1.2.3`). |
| Change | A modification to the state of the Source Repository. |
| Change History | A record of the history of Source Revisions that preceded a specific revision. |
| Branch | A Named Reference that moves to track the Change History of a cohesive line of development. |
| Tag | A Named Reference intended to be immutable. |

A **Source Control System (SCS)** is a platform or combination of services that hosts a Source Repository and provides a trusted foundation for managing source revisions by enforcing policies for authentication, authorization, and change management.

| Term | Description |
| --- | --- |
| Organization | A set of people who collectively create Source Revisions within a Source Repository. |
| Proposed Change | A proposal to make a Change in a Source Repository. |
| Source Provenance | Information about how a Source Revision came to exist. |

### Source Roles

| Role | Description |
| --- | --- |
| Administrator | A human who can perform privileged operations on one or more projects. |
| Trusted person | A human authorized by the organization to propose and approve changes to the source. |
| Trusted robot | Automation authorized by the organization to act in explicitly defined contexts. |
| Untrusted person | A human with limited access to the project. |

## Basics

| Track/Level | Requirements | Focus |
| --- | --- | --- |
| Source L1 | Use a version control system. | Generation of discrete Source Revisions for precise consumption. |
| Source L2 | Preserve Change History and generate Source Provenance. | Reliable history through enforced controls and evidence. |
| Source L3 | Enforce organizational technical controls. | Consumer knowledge of guaranteed technical controls. |
| Source L4 | Require code review. | Improved code quality and resistance to insider threats. |

### Level 1: Version controlled

Source is stored and managed through a modern version control system. Intended for organizations currently storing source in non-standard ways. Migrating to appropriate tools is an important first step toward operational maturity.

### Level 2: History & Provenance

Branch history is continuous, immutable, and retained, and the SCS issues Source Provenance Attestations for each new Source Revision. Source Provenance provides strong, tamper-resistant evidence of the process used to produce a Source Revision.

### Level 3: Continuous technical controls

The SCS is configured to enforce the Organization's technical controls for specific Named References. A verifier can use this published data to ensure that a given Source Revision was created in the correct way.

### Level 4: Two-party review

The SCS requires two trusted persons to review all changes to protected branches. Makes it harder for an actor to introduce malicious changes into the software.

## Requirements

### Organization requirements

- **Choose an appropriate SCS**: Must select an SCS capable of reaching their desired SLSA Source Level. (L1+)
- **Configure the SCS to control access and enforce history**: Must configure access controls to restrict sensitive operations. Tags MUST be configured to prevent being moved or deleted. (L2+)
- **Safe Expunging Process**: May only allow removal of content to meet legal or privacy compliance requirements. (L2+)
- **Continuous technical controls**: Must provide evidence of continuous enforcement via technical controls for any claims made. (L3+)

### Source Control System requirements

- **Repositories are uniquely identifiable**: Repository ID MUST be uniquely identifiable within the context of the SCS. (L1+)
- **Revisions are immutable and uniquely identifiable**: Revision ID MUST be uniquely identifiable within the context of the repository. (L1+)
- **Human readable changes**: SCS MUST provide tooling to display changes between revisions in human readable form. (L1+)
- **Source Verification Summary Attestations**: SCS MUST generate a source VSA to indicate the SLSA Source Level of any revision. (L1+)
- **History**: SCS MUST record all changes to Named References, including when they occurred, who made them, and the new Source Revision ID. (L2+)
- **Continuity**: Control continuity MUST be established and tracked from a specific start revision. (L2+)
- **Identity Management**: SCS MUST provide an identity management system for identifying and authenticating actors. (L2+)
- **Source Provenance**: Source Provenance MUST be created contemporaneously with the branch being updated. (L2+)
- **Protected Named References**: SCS MUST provide the ability for an organization to enforce customized technical controls for Named References. (L3+)
- **Two-party review**: Changes in protected branches MUST be agreed to by two or more trusted persons prior to submission. (L4)

## Communicating source levels

There are two broad categories of source attestations:

1. **Source verification summary attestations (Source VSAs)**: Communicate what high level security properties a given source revision meets. Issued using the Verification Summary Attestations format.
2. **Source provenance attestations**: Provide trustworthy, tamper-proof metadata to determine what high level security properties a given source revision has. Format is left to SCSs.

### Source verification summary attestation fields

- `subject.uri`: URI where a human can find details about the revision.
- `subject.digest`: MUST include the revision identifier (e.g. `gitCommit`).
- `subject.annotations.sourceRefs`: List of references that pointed to this revision.
- `resourceUri`: URI of the repository.
- `verifiedLevels`: MUST include the SLSA source track level (`SLSA_SOURCE_LEVEL_0` through `SLSA_SOURCE_LEVEL_3`).
