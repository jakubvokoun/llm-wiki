# Source: Verifying source

Status: Approved

SLSA uses attestations to indicate security claims associated with a repository
revision, but attestations don't do anything unless somebody inspects them. SLSA
calls that inspection **verification**.

At Source L3+, Source Control Systems (SCSs) issue detailed provenance attestations of the process that was used to create specific revisions. Source Verification Summary Attestations (Source VSAs) make verification more efficient by recording the result of prior verifications.

## How to verify a source revision

The source consumer checks:
1. If they trust the SCS that issued the VSA and if the VSA applies to the revision they've fetched.
2. If the claims made in the VSA match their expectations for how the source should be managed.
3. (Optional): If the evidence presented in the source provenance matches the claims made in the VSA.

### Step 1: Check the SCS

Configure the verifier's roots of trust, meaning the recognized SCS identities and the maximum SLSA Source level each SCS is trusted up to. The root of trust configuration is likely in the form of a map from (SCS public key identity, VSA `verifier.id`) to (SLSA Source level).

Given a revision and its VSA, follow the VSA verification instructions and validation model using the revision identifier to perform subject matching and checking the `verifier.id` against the root-of-trust.

### Step 2: Check Expectations

Verify that the VSA meets your expectations to mitigate adversarial modifications.

You SHOULD compare the VSA against expected values for at least:

| What | Why |
| --- | --- |
| `verifier.id` identity | To prevent an adversary from substituting a VSA making false claims from an unintended SCS. |
| `subject.digest` | To prevent an adversary from substituting a VSA from another revision. |
| `verificationResult` | To prevent an adversary from providing a VSA for a revision that failed some aspect of the organization's expectations. |
| `predicate.resourceUri` | To prevent an adversary from substituting a VSA for the intended repository for another. |
| `subject.annotations.sourceRefs` | To prevent an adversary from substituting the intended revision from one branch with another. |
| `verifiedLevels` | To ensure the expected controls were in place for the creation of the revision. |

### Step 3: Verify Evidence using Source Provenance (Optional)

Optionally, at SLSA Source Level 3 and up, check the source provenance attestations directly. Form expectations about the claims in source provenance attestations and how they map to a revision's properties claimed in its VSA in conjunction with the SCS and the producer.

## Forming Expectations

Possible models for forming expectations include:

* **Trust on first use:** Accept the first version of the revision as-is. On each update, compare the old VSA to the new VSA and alert on any differences.
* **Defined by producer:** The revision producer tells the verifier what their expectations ought to be. The verifier SHOULD provide an authenticated communication mechanism with protection against unauthorized modifications.

## Architecture options

VSA verification can happen at: the build system at source fetch time, the package ecosystem at build artifact upload time, the consumers at download time, or via a continuous monitoring system. All are valid and at least one SHOULD be used.
