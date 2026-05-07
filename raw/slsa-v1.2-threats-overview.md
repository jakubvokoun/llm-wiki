# Supply chain threats

Status: Approved

Attacks can occur at every link in a typical software supply chain, and these
kinds of attacks are increasingly public, disruptive, and costly in today's
environment.

This page is an introduction to possible attacks throughout the supply chain and how
SLSA could help. For a more technical discussion, see Threats & mitigations.

## Summary

**Note that SLSA does not currently address all of the threats presented here.**

SLSA's primary focus is supply chain integrity, with a secondary focus on
availability. Integrity means protection against tampering or unauthorized
modification at any stage of the software lifecycle. Within SLSA, we divide
integrity into source integrity vs build integrity.

**Source integrity:** Ensure that the source revision represents the intent of the producer, that all expected processes were followed and that the revision was not modified after being accepted.

**Build integrity:** Ensure that the package is built from the correct,
unmodified sources and dependencies according to the build recipe defined by the
software producer, and that artifacts are not modified as they pass between
development stages.

**Availability:** Ensure that the package can continue to be built and
maintained in the future, and that all code and change history is available for
investigations and incident response.

### Real-world examples

Many recent high-profile attacks were consequences of supply chain integrity vulnerabilities, and could have been prevented by SLSA's framework. For example:

| Threats from | Known example | How SLSA could help |
|---|---|---|
| Producer | SpySheriff | SLSA does not directly address this threat but could make it easier to discover malicious behavior in open source software, by forcing it into the publicly available source code. |
| Authoring & reviewing | SushiSwap | Two-person review could have caught the unauthorized change. |
| Source code management | PHP | A better-protected source code system would have been a much harder target for the attackers. |
| External build parameters | The Great Suspender | A SLSA-compliant build server would have produced provenance identifying the actual sources used, allowing consumers to detect such tampering. |
| Build process | SolarWinds | Higher SLSA Build levels have stronger security requirements for the build platform, making it more difficult for an attacker to forge the SLSA provenance and gain persistence. |
| Artifact publication | CodeCov | Provenance of the artifact in the GCS bucket would have shown that the artifact was not built in the expected manner from the expected source repo. |
| Distribution channel | Attacks on Package Mirrors | Similar to above, provenance of the malicious artifacts would have shown that they were not built as expected or from the expected source repo. |
| Package selection | Browserify typosquatting | SLSA does not directly address this threat, but provenance linking back to source control can enable and enhance other solutions. |
| Usage | Default credentials | SLSA does not address this threat. |
| Dependency threats | event-stream | Applying SLSA recursively to all dependencies would prevent this particular vector, because the provenance would indicate that it either wasn't built from a proper builder or that the binary did not match the source. |

| Availability threat | Known example | How SLSA could help |
|---|---|---|
| Dependency becomes unavailable | Mimemagic | SLSA does not directly address this threat. |

A SLSA level helps give consumers confidence that software has not been tampered
with and can be securely traced back to source—something that is difficult, if
not impossible, to do with most software today.
