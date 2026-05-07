# Guiding principles

Status: Approved

This page is an introduction to the guiding principles behind SLSA's design
decisions.

## Simple levels with clear outcomes

Use levels to communicate security state and to
encourage a large population to improve its security stance over time. When
necessary, split levels into separate tracks to recognize progress in unrelated
security areas.

**Reasoning:** Levels simplify how to think about security by boiling a complex
topic into an easy-to-understand number. It is clear that level N is better than
level N-1, even to someone with passing familiarity.

Guidelines:

* **Define levels in terms of concrete security outcomes.** Each level should
  have clear and meaningful security value, such as stopping a particular
  class of threats. Give each level an easy-to-remember mnemonic, such as
  "Provenance exists."
* **Balance level granularity.** Too many levels makes SLSA hard to understand
  and remember; too few makes each level hard to achieve.
* **Use tracks sparingly.** Additional tracks add extra complexity to SLSA, so
  a new track should be seen as a last resort. Each track should have a clear,
  distinct purpose with a crisply defined objective.

## Trust platforms, verify artifacts

Establish trust in a small number of platforms and systems—such as change management, build,
and packaging platforms—and then automatically verify the many artifacts
produced by those platforms.

**Reasoning**: Trusted computing bases are unavoidable. Hardening and verifying platforms is difficult and
expensive manual work, and each trusted platform expands the attack surface of the
supply chain. Verifying that an artifact is produced by a trusted platform,
though, is easy to automate.

**Benefits**: Allows SLSA to scale to entire ecosystems or organizations with a near-constant
amount of central work.

### Corollary: Minimize the number of trusted platforms

A corollary to this principle is to minimize the size of the trusted computing
base. Every platform we trust adds attack surface and increases the need for
manual security analysis. Where possible:

* Concentrate trust in shared infrastructure.
* Remove the need to trust components. For example, use end-to-end signing
  to avoid the need to trust intermediate distribution platforms.

## Trust code, not individuals

Securely trace all software back to source code rather than trust individuals who have write access to package registries.

**Reasoning**: Code is static and analyzable. Individuals, on the other hand, are prone to mistakes,
credential compromise, and sometimes malicious action.

**Benefits**: Removes the possibility for a trusted individual—or an
attacker abusing compromised credentials—to tamper with source code
after it has been committed.

## Prefer attestations over inferences

Require explicit attestations about an artifact's provenance; do not infer
security properties from a platform's configurations.

**Reasoning**: Theoretically, access control can be configured so that the only path from
source to release is through the official channels. In practice, though, these configurations are almost impossible to get right and
keep right. There are often over-provisioning, confused deputy problems, or
mistakes.

Access control is still important, but SLSA goes further to provide defense in depth: it **requires proof in
the form of attestations that the package was built correctly**.

**Benefits**: The attestation removes intermediate platforms from the trust base and ensures that
individuals who are accidentally granted access do not have sufficient permission to tamper with the package.

## Support anonymous and pseudonymous contributions

SLSA supports anonymous and pseudonymous 'identities' within the software supply chain.
While organizations that implement SLSA may choose otherwise, SLSA itself does not require,
or encourage, participants to be mapped to their legal identities.

**Reasoning**: SLSA uses identities for multiple purposes: as a trust anchor for attestations
or for attributing actions to an actor. Choice of identification technology is left to the organization and technical
stacks implementing the SLSA standards. When identities are strongly authenticated and used consistently they can often be leveraged
for both of these purposes without requiring them to be mapped to legal identities.

**Benefits**: By not requiring legal identities SLSA lowers the barriers to its adoption,
enabling all of its other benefits and maintaining support for anonymous and pseudonymous
contribution as has been practiced in the software industry for decades.
