# Tracks

Status: Approved

SLSA is composed of multiple tracks which are each
composed of multiple levels. Each track addresses different threats
and has its own set of requirements and patterns of use.

## Build Track

The SLSA build track describes increasing levels of trustworthiness and
completeness in a package artifact's provenance. Provenance describes
what entity built the artifact, what process they used, and what the inputs
were. The lowest level only requires the provenance to exist, while higher
levels provide increasing protection against tampering of the build, the
provenance, or the artifact.

The primary purpose of the build track is to enable
verification that the artifact was built as expected.
Consumers have some way of knowing what the expected provenance should look like
for a given package and then compare each package artifact's actual provenance
to those expectations. Doing so prevents several classes of
supply chain threats.

Each ecosystem (for open source) or organization (for closed source) defines
exactly how this is implemented, including: means of defining expectations, what
provenance format is accepted, whether reproducible builds are used, how
provenance is distributed, when verification happens, and what happens on
failure.

Related resources:
- Terminology
- Basics
- Requirements
- Build provenance
- Assessing build platforms

## Source Track

The SLSA source track provides producers and consumers with increasing levels of
trust in the source code they produce and consume. It describes increasing
levels of trustworthiness and completeness of how a source revision was created.

The expected process for creating a new revision is determined solely by that
repository's owner (the organization) who also determines the intent of the
software in the repository and administers technical controls to enforce the
process.

Consumers can review attestations to verify whether a particular revision meets
their standards.

Related resources:
- Requirements
- Source provenance attestations
- Assessing source systems
- Example controls
