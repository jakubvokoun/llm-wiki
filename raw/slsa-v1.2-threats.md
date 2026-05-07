# Threats & Mitigations

Status: Approved

Comprehensive technical analysis of supply chain threats and their corresponding mitigations with SLSA and other best practices. Threats are labeled (A) through (I) based on where in the software development pipeline they occur.

## Overview

Threat model covers the *software supply chain* — the process by which software is produced and consumed. Dependencies are highly recursive; each dependency has its own threats (A)–(I).

Producers and consumers face *aggregate* risk across all software they produce/consume. SLSA prioritizes mitigations that can be broadly adopted in an automated fashion.

## Source Threats

Source integrity threat: adversary introduces a change to source code that does not reflect the intent of the software producer.

The SLSA Source track mitigates these threats when the consumer verifies source against expectations.

### (A) Producer

Producer intentionally produces code that harms the consumer, or uses practices not deserving of consumer trust.

- **Threat:** Producer intentionally creates a malicious revision.
- **Mitigation:** Cannot be directly mitigated through SLSA. Consumers must establish trust basis: open source repos with active user-base, legal/reputational incentives.

### (B) Modifying the Source

Adversary without admin privileges attempts to introduce unauthorized change.

#### (B1) Submit change without review

- **Directly submit without review (Source L4):** Require approval of all changes. Example: force push to main branch.
- **Single actor controls multiple accounts:** Producer must ensure no actor controls multiple accounts with review privileges. Example: secondary account creates PR, primary account approves.
- **Use a robot account:** All changes require review by two people, even robot changes.
- **Abuse of rule exceptions:** Remove rule exceptions. Example: malicious executable disguised as `.md` file.
- **Highly-permissioned actor bypasses controls (verification):** SCS must have controls to prevent/detect abusive admin behavior.

#### (B2) Evade change management process

- **Alter change history (Source L2+):** SCS prevents branch history alteration. Example: force push to erase malicious commit.
- **Replace tagged content (Source L2+):** SCS does not allow protected tags to be updated.
- **Skip required checks (Source L3+):** Technical controls enforce adherence to development process. Example: test coverage requirements.
- **Modify code after review (Source L4):** SCS invalidates approvals when proposed change is modified.
- **Submit unreviewable change (Source L4):** Code review system renders content meaningfully (e.g., renders images, resolves symlinks).
- **Copy a reviewed change to another context (Source L4):** Approvals are context-specific; upstream requires its own review.
- **Commit graph attacks:** Each revision in protected context must follow intended process. Example: PR with malicious commit X + undoing commit Y hides net malicious change.

#### (B3) Render code review ineffective

- **Collude with another trusted person:** Not addressed by SLSA; producer can increase friction (more/senior reviewers).
- **Trick reviewer ("bugdoor"):** Not addressed by SLSA.
- **Rubber stamping:** Not addressed by SLSA.

#### (B4) Render change metadata ineffective

- **Forge change metadata (Source L2+):** SCS attributes changes to authenticated identities only, records signed source provenance attestations.

### (C) Source Code Management

Adversary introduces change through administrative interface or compromise of underlying infrastructure.

- **Platform admin abuses privileges (verification):** Platform must have controls to prevent/detect admin abuse (two-person approvals, audit logging).
- **Exploit vulnerability in SCM:** Not addressed by SLSA.

## Build Threats

Build integrity threat: adversary introduces behavior to artifact without changing source, or builds from unintended source/dependency/process.

SLSA Build track mitigates these threats when consumer verifies artifacts against expectations.

### (D) External Build Parameters

Adversary builds from a version of source that doesn't match official repo, or changes build parameters to inject behavior.

Mitigation: compare provenance against expectations (requires SLSA Build L1).

- **Build from unofficial fork (expectations):** Verifier requires source location to match expected value.
- **Build from unofficial branch or tag (expectations):** Verifier requires source branch/tag to match or revision to be reachable from expected branch.
- **Build from unofficial build steps (expectations):** Verifier requires build configuration source to match expected value. Example: custom steps provided over RPC instead of `cloudbuild.yaml`.
- **Build from unofficial parameters (expectations):** Verifier requires all external parameters to match expected values. Example: injecting custom compiler flags.
- **Build from modified code after checkout (expectations):** Build platform pulls directly from source repo and accurately records source location.

### (E) Build Process

Adversary introduces unauthorized change to build output, or introduces false information into provenance.

- **Forge provenance values (Build L2+):** Trusted control plane generates all provenance info; worker reports output only.
  - L2: worker generates provenance — mitigated by moving provenance to control plane.
  - L3: hardened against even determined adversaries (strong isolation).
- **Forge output digest (n/a):** Not a problem — any build claiming to produce an artifact could have done so by copying verbatim.
- **Compromise project owner (Build L2+):** Build project owner must not have ability to influence build or provenance.
- **Compromise other build (Build L3):** Builds are isolated from one another; no persistence between builds. Example: malicious build swaps source files for parallel build.
- **Steal cryptographic secrets (Build L3):** Builds isolated from control plane; only control plane has access to signing keys.
- **Poison the build cache (Build L3):** Build caches isolated between builds; cache keyed by transitive closure of all inputs; cache writable only by trusted control plane or entries have SLSA L3 provenance. Example: poisoned `auth.o` injected into cache.
- **Compromise build platform admin (verification):** Platform must have controls to prevent/detect admin abuse.

### (F) Artifact Publication

Adversary uploads package artifact not reflecting official source.

- **Build with untrusted CI/CD (expectations):** Verifier requires provenance showing builder matches expected value.
- **Upload package without provenance (Build L1):** Verifier requires provenance before accepting package.
- **Tamper with artifact after CI/CD (Build L1):** Verifier checks provenance `subject` matches package hash.
- **Tamper with provenance (Build L2):** Verifier only accepts provenance with valid cryptographic signature from acceptable builder.

### (G) Distribution Channel

Adversary modifies package on registry via administrative interface or infrastructure compromise.

Similar to (F) but mitigated by the *consumer* performing verification. Consumer's actions simplified if (F) produces a VSA.

- **Build with untrusted CI/CD (expectations):** Verifier requires provenance or VSA showing expected builder.
- **Issue VSA from untrusted intermediary (expectations):** Verifier requires VSA from trusted intermediary (verified by signing key).
- **Upload package without provenance or VSA (Build L1):** Verifier requires provenance or VSA.
- **Replace package and VSA with another (expectations):** Consumer verifies VSA `resourceUri` matches expected package, not just received package.
- **Tamper with artifact after upload (Build L1):** Verifier checks provenance/VSA `subject` matches package hash.
- **Tamper with provenance or VSA (Build L2):** Verifier requires valid cryptographic signature.

## Usage Threats

Adversary exploits behavior of the consumer.

### (H) Package Selection

Consumer requests package it did not intend.

- **Dependency confusion:** Register package name on public registry that shadows internal registry name. Mitigation: build internal packages on SLSA L2+, define and verify expectations on installation.
- **Typosquatting:** Not addressed by SLSA (source availability requirement is mild deterrent).

### (I) Usage

- **Improper usage:** Consumer uses package insecurely. Not addressed by SLSA (see Secure by Design).

## Dependency Threats

Adversary introduces unintended behavior by compromising an artifact that the target depends on at build time. (Runtime dependencies excluded from model.)

Dependency threats are recursive through supply chain. SLSA v1.2 does not explicitly address these; future versions expected to do so.

### Build Dependency

- **Vulnerable dependency (library, base image, bundled file):** Future Dependency track may provide guidance.
- **Compromised build tool (compiler, utility, OS package):** Partially mitigated by treating build tooling as artifacts to verify. Future Build Environment track may provide guidance. Example: compromised `tar` injects backdoor into all ELF binaries.
- **Compromised runtime dependency used during build:** In addition to build tool mitigations, isolate tests to environment without write access to output artifact.

### Related Threats (Not Dependency Threats)

- **Compromised dependency at runtime:** SLSA threat model does not model runtime dependencies — each is a distinct artifact with its own threats.

## Availability Threats

Adversary denies access to source, change history, or ability to build a package. SLSA does not currently address availability threats.

- **Delete the code:** Not addressed.
- **Dependency temporarily or permanently unavailable:** Not addressed (hermetic/reproducible build solutions may reduce impact).
- **De-list artifact:** Not addressed.
- **De-list provenance:** Not addressed.

## Verification Threats

Threats that compromise the ability to prevent or detect supply chain security threats.

- **Tamper with recorded expectations:** Changes to recorded expectations require authorization (e.g., two-party review). Example: producer modifies config to accept `evil/my-package`.
- **Exploit cryptographic hash collisions:** Use secure algorithms (SHA-256). Example: MD5 collision to substitute malicious file.
