# Build: Verifying artifacts

Status: Approved

SLSA uses provenance to indicate whether an artifact is authentic or not, but
provenance doesn't do anything unless somebody inspects it. SLSA calls that
inspection **verification**.

## How to verify

Verification SHOULD include the following steps:

* Ensuring that the builder identity is one of those in the map of trusted
  builder id's to SLSA level.
* Verifying the signature on the provenance envelope.
* Ensuring that the values for `buildType` and `externalParameters` in the
  provenance match the expected values.
* Rejecting unrecognized `externalParameters` to err on the side of caution.

### Step 1: Check SLSA Build level

Configure the verifier's roots of trust by recognizing builder identities and the maximum SLSA Build level each builder is trusted up to. This typically involves mapping builder public keys and `builder.id` to SLSA levels.

For each artifact and provenance:
1. Verify the envelope's signature using roots of trust.
2. Verify that the statement's `subject` matches the digest of the artifact.
3. Verify that the `predicateType` is `https://slsa.dev/provenance/v1`.
4. Look up the SLSA Build Level using recognized public keys and `builder.id`.

**Important:** SLSA Build L3 does **not** cover compromise of the build platform itself, such as by a malicious insider. Verifiers SHOULD carefully consider which build platforms are added to the roots of trust.

Threat mitigations:
- Threat E (Build process): SLSA Build L3 protects against compromise of the build process by an external adversary.
- Threat F (Artifact publication): SLSA Build L2 covers tampering after the build.
- Threat G (Distribution channel): Verification outside the package registry covers compromise of the registry.
- Threat I (Usage): Verification by the consumer covers compromise of the package in transit.

### Step 2: Check expectations

Compare the provenance against expected values to mitigate threat "D" (external build parameters).

You SHOULD compare the provenance against expected values for at least:

| What | Why |
| --- | --- |
| Builder identity | To prevent an adversary from building the correct code on an unintended platform |
| Canonical source repository | To prevent an adversary from building from an unofficial fork |
| `buildType` | To ensure that `externalParameters` are interpreted as intended |
| `externalParameters` | To prevent an adversary from injecting unofficial behavior |

Verification tools SHOULD reject unrecognized fields in `externalParameters`.

### Step 3: (Optional) Check dependencies recursively

Recursively check the `resolvedDependencies` to mitigate dependency threats. A Verification Summary Attestation (VSA) can make dependency verification more efficient by recording the result of prior verifications.

## Forming Expectations

Expectations are known provenance values that indicate the corresponding artifact is authentic.

Possible models for forming expectations include:

* **Trust on first use:** Accept the first version of the package as-is. On each version update, compare the old provenance to the new provenance and alert on any differences.
* **Defined by producer:** The package producer tells the verifier what their expectations ought to be. Verifier SHOULD provide an authenticated communication mechanism with protection against adversarial modification.
* **Defined in source:** The source repository tells the verifier what their expectations ought to be. This is how the Go ecosystem works.

## Architecture options

Options for where provenance verification can happen (non-mutually exclusive):

### Package ecosystem

During package upload, a package ecosystem can ensure that the artifact's provenance matches expected values for that package name's provenance before accepting it. This option is RECOMMENDED whenever possible.

### Consumer

Consumers can form their own expectations or use the default expectations provided by the package producer and/or package ecosystem. Client-side verification tooling ensures that the artifact's provenance matches their expectations before use.

### Monitor

A monitor is a service that verifies provenance for a set of packages and publishes the result. Consumers can continuously poll a monitor to detect artifacts that do not meet the monitor's expectations.
