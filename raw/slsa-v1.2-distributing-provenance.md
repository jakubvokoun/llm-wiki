# Build: Distributing provenance

Status: Approved

In order to make provenance for artifacts available after generation
for verification, SLSA requires the distribution and verification of provenance
metadata in the form of SLSA attestations.

## Background

The package ecosystem's maintainers are responsible for reliably
redistributing artifacts and provenance, making the producers' expectations
available to consumers, and providing tools to enable safe artifact consumption.

## Relationship between releases and attestations

Attestations SHOULD be bound to artifacts, not releases.

A single "release" of a project might include multiple artifacts from builds on different platforms,
architectures, or environments. It is often difficult to determine when a release is 'finished'
because many ecosystems allow adding new artifacts to old releases. Therefore, the set of attestations
for a given release MAY grow over time.

Package ecosystems SHOULD support multiple individual attestations per release.

## Relationship between artifacts and attestations

Package ecosystems SHOULD support a one-to-many relationship from build
artifacts to attestations. SLSA is primarily concerned with build attestations (provenance) produced by the
same maintainers as the artifacts themselves.

Provenance SHOULD accompany the artifact at publish time, and
package ecosystems SHOULD provide a way to map a given artifact to its
corresponding attestations.

The provenance SHOULD have a filename directly related to the build artifact filename. For example: `<filename>.attestation` or `<filename>.intoto.jsonl`.

## Where attestations are published

Producers MUST publish attestations in at least one place, and SHOULD publish in more than one place:

* **Publish attestations alongside the source repository releases**: If the
  source repository hosting provider offers an artifact "release" feature (e.g. GitHub releases, GitLab releases),
  producers SHOULD include provenance as part of such releases.
* **Publish attestations alongside the artifact in the package registry**:
  Many software repositories already support publishing sidecar files alongside an artifact
  (e.g. PyPI supports `.asc` files for PGP signatures). This option requires a 1:1 mapping between artifact and attestation.
* **Publish attestations elsewhere, record their existence in a transparency log**: Once an attestation has been generated and published, a hash of the attestation and a pointer to where it is indexed SHOULD be published to a third-party transparency log such as Rekor from Sigstore.

Long-term, package registries SHOULD support uploading and distributing provenance alongside the artifact.

## Immutability of attestations

Attestations SHOULD be immutable. Once an attestation is published for a given artifact, that attestation cannot be overwritten. Instead, a new release with new artifacts SHOULD be created.

## Format of the attestation

The provenance format SHOULD be in-toto SLSA Build Provenance, but another format MAY be used if both producer and consumer agree and all other requirements are met.

## Considerations for source-based ecosystems

Ecosystems installing directly from source repositories require no provenance publication or verification. However, ecosystems installing from source via intermediaries that transform the original source (constituting a "build") SHOULD provide build provenance.
