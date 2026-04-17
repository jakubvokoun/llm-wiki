---
title: "Supply Chain Security"
tags: [supply-chain, security, sbom, signing, provenance, mcp, npm, sca, cve]
sources:
  [
    owasp-docker-security.md,
    owasp-iac-security.md,
    owasp-mcp-security.md,
    owasp-npm-security.md,
    owasp-vulnerable-dependency-management.md,
  ]
updated: 2026-04-16
---

# Supply Chain Security

Securing the full lifecycle of software artifacts — from source code through build, packaging, distribution, and deployment — against tampering, compromise, or injection of malicious components.

## Key Practices

### Software Bill of Materials (SBOM)

A machine-readable inventory of all components, libraries, and dependencies in an artifact. Enables vulnerability tracking and license compliance.

- Standard format: CycloneDX, SPDX
- Generate at build time; store alongside image

### Image / Artifact Signing

Digitally sign artifacts so consumers can verify integrity and authenticity. Prevents "what you built is what you deployed" attacks.

- Tools: Notary (Notaryproject), Sigstore/Cosign
- Docker Content Trust for Docker images

### Provenance (SLSA)

SLSA (Supply Chain Levels for Software Artifacts) provides a framework for documenting where artifacts came from and how they were built.

- Levels 1-4 with increasing guarantees
- Level 3+: build on dedicated infrastructure, signed provenance

### Trusted Registry

Store signed images + SBOMs in a registry with:

- Strict access controls
- Vulnerability scanning on push
- Metadata management

### Deployment-time Verification

- Validate signatures before deployment (OPA, Kyverno admission webhooks)
- Policy: reject unsigned or vulnerable images

### Artifact Signing (IaC)

- Sign Terraform modules, Helm charts at publish
- TUF (The Update Framework) for secure distribution

## Relation to Container Security

OWASP Docker Rule #13 dedicates a full section to supply chain as an extension of CI/CD scanning (Rule #9). The minimum viable practice: scan + SBOM + sign.

## MCP Server Supply Chain

MCP servers are a new attack vector: packages installed from public registries can be:

- **Typosquatted** — e.g., `mcp-server-filesytem` vs `mcp-server-filesystem`
- **Compromised post-publish** (rug pull attacks)
- **Bundled with malicious tool definitions** that poison LLM behavior

Mitigations:

- Only install from trusted, verified sources
- Review source code and tool definitions before installation
- Verify checksums or code signing
- Scan dependencies for known vulnerabilities
- Use `mcp-scan` to detect poisoned or mutated tool definitions post-installation
- Monitor for post-installation changes to tool descriptions

See [Tool Poisoning](tool-poisoning.md) and [MCP Security](mcp-security.md).

## npm Supply Chain

npm-specific supply chain threats:

- **Typosquatting** — package names visually similar to popular packages; target `process.env` credentials.
- **Slopsquatting** — AI coding assistant hallucinations; attackers pre-register hallucinated package names.
- **Dependency confusion** — publish a public package with same name as internal package but higher version.
- **Run-script abuse** — `postinstall` scripts that execute malicious code on install.

Mitigations:

- `npm install --ignore-scripts` (or `ignore-scripts=true` in `.npmrc`)
- `@lavamoat/allow-scripts` for per-package script allowlisting
- Scoped package names (`@org/package`) for internal packages
- Private npm registry (Verdaccio) with upstream caching
- Generate SBOM: `npx @cyclonedx/cyclonedx-npm`
- Sign with Sigstore/cosign; verify in CI

See [NPM Security](npm-security.md) and [Dependency Confusion](dependency-confusion.md).

## Vulnerable Dependency Response Process

When SCA tools detect a vulnerable dependency, four cases apply:

| Case | Situation                      | Action                                                                                              |
| ---- | ------------------------------ | --------------------------------------------------------------------------------------------------- |
| 1    | Patch available                | Update + run tests; fix API breakage if needed                                                      |
| 2    | Fix delayed (months)           | Apply workaround; wrap vulnerable calls with validation code; add WAF rules; document CVE in README |
| 3    | Provider won't fix             | Fork + patch (OSS) or find alternative; add protective code; write exploit-prevention unit tests    |
| 4    | Discovered externally (no CVE) | Notify provider; apply Case 2 or 3 based on response                                                |

**Transitive dependencies**: act on the direct dependency, not the transitive one. Risk acceptance must go to CRO/CISO with CVSS score justification.

**SCA tooling**: OWASP Dependency Check, npm audit, Snyk, JFrog XRay, OWASP Dependency Track.

See [OWASP Vulnerable Dependency Management Cheat Sheet](../sources/owasp-vulnerable-dependency-management.md).

## Sources

- [OWASP Docker Security Cheat Sheet](../sources/owasp-docker-security.md)
- [OWASP IaC Security Cheat Sheet](../sources/owasp-iac-security.md)
- [OWASP MCP Security Cheat Sheet](../sources/owasp-mcp-security.md)
- [OWASP Vulnerable Dependency Management Cheat Sheet](../sources/owasp-vulnerable-dependency-management.md)
