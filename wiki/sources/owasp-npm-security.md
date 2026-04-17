---
title: "OWASP NPM Security Cheat Sheet"
tags: [owasp, npm, nodejs, supply-chain, security]
sources: [owasp-npm-security.md]
updated: 2026-04-16
---

# OWASP NPM Security Cheat Sheet

## Summary

12 npm security best practices covering secrets prevention, lockfile enforcement, run-script attack surfaces, dependency auditing, supply chain protections, 2FA, typosquatting, slopsquatting (AI hallucination attacks), trusted publishers, and dependency confusion attacks.

## Key Takeaways

### Secrets in Published Packages

- `.gitignore` does NOT automatically protect files from being published to npm registry.
- If both `.gitignore` and `.npmignore` exist, `.npmignore` takes precedence; forgotten `.npmignore` leads to leaks.
- Use `files` property in `package.json` as an allowlist.
- Use `npm publish --dry-run` to preview the tarball contents.

### Lockfile Enforcement

- Run `npm ci` (or `yarn install --frozen-lockfile`) in CI to prevent lockfile drift.

### Run-Scripts Attack Surface

- `postinstall` scripts in npm packages can execute arbitrary code on install.
- Mitigations: `--ignore-scripts`, `.npmrc` with `ignore-scripts=true`, or `@lavamoat/allow-scripts` allowlist.

### Dependency Auditing

- `npm audit` (available since npm v6) to find vulnerable packages.
- `npm outdated` for freshness review; `npm doctor` for environment health.
- OWASP Dependency-Track for continuous CVE monitoring.

### Supply Chain Protections

- Generate SBOM with CycloneDX: `npx @cyclonedx/cyclonedx-npm`.
- Sign artifacts with Sigstore/cosign.
- Use private registry (Verdaccio) with caching to reduce exposure to compromised upstream.
- Restrict and rotate CI/publisher tokens; bind to workflows or IP ranges.

### Typosquatting

- Attackers publish malicious packages with names similar to popular packages.
- Notable incidents: `cross-env`, `event-stream`, `eslint-scope`.
- Main target: environment variables (`process.env`) containing credentials.

### Slopsquatting (New Attack Vector)

- AI coding assistants hallucinate package names; attackers pre-register those names.
- Unlike typosquatting, the package name looks completely legitimate.
- Defense: run `npm view <package>` before installing AI-suggested packages; check download count, GitHub repo, creation date.

### Trusted Publishers (OIDC)

- Replaces long-lived npm tokens with short-lived, workflow-specific OIDC credentials.
- Supported on GitHub Actions and GitLab CI/CD.
- Automatically generates provenance attestations.

### Dependency Confusion

- Attacker publishes malicious package on public npm with same name as internal package but higher version.
- Defense: use scoped packages (`@org/package`), configure `.npmrc` to point scopes to private registry, publish placeholder packages on public npm.

### Account Security

- Enable 2FA with `auth-and-writes` mode.
- Use read-only CIDR-restricted tokens for CI.
- Use `npm token list` and `npm token revoke` to manage tokens.

## Related Pages

- [NPM Security](../concepts/npm-security.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [Dependency Confusion](../concepts/dependency-confusion.md)
- [CI/CD Security](../concepts/cicd-security.md)
- [OWASP](../entities/owasp.md)
