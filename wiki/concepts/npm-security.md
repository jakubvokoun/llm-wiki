---
title: "NPM Security"
tags: [npm, nodejs, supply-chain, security, javascript]
sources: [owasp-npm-security.md]
updated: 2026-04-16
---

# NPM Security

Security practices for the npm ecosystem: preventing secrets leakage, enforcing deterministic installs, minimizing run-script attack surfaces, auditing dependencies, and protecting the supply chain.

## Secrets in Published Packages

**Risk**: `.env`, API keys, tokens accidentally included in published npm tarballs.

**Mechanics**:

- If both `.gitignore` and `.npmignore` exist, `.npmignore` controls what's published.
- Updating `.gitignore` without updating `.npmignore` leads to leaks.
- Use `files` array in `package.json` as an explicit allowlist.
- Always test with `npm publish --dry-run`.

## Lockfile Enforcement

Run `npm ci` in CI/CD pipelines — it:

- Requires a `package-lock.json` to exist.
- Aborts if any deviation from the lockfile is detected.
- Never modifies the lockfile.

Equivalent: `yarn install --frozen-lockfile`.

## Run-Script Attack Surface

npm packages can define `postinstall` and other lifecycle scripts that run automatically on install. Attacks: `eslint-scope` (token harvesting), `crossenv` (typosquatting + script execution).

**Mitigations:**

- `npm install --ignore-scripts`
- `.npmrc` with `ignore-scripts=true`
- `@lavamoat/allow-scripts` for per-package script allowlisting

## Dependency Auditing

- `npm audit` — scan against npm advisory database.
- `npm audit fix` — auto-upgrade to non-vulnerable versions.
- `npm outdated` — freshness overview.
- OWASP Dependency-Track — continuous CVE monitoring with SBOM snapshots.

## Supply Chain Protections

See [Supply Chain Security](supply-chain-security.md) for the general framework. npm-specific practices:

- Generate SBOM: `npx @cyclonedx/cyclonedx-npm --validate > sbom.json`
- Sign artifacts with Sigstore/cosign.
- Use private npm registry (Verdaccio) with upstream caching.
- Bind CI tokens to specific workflows/IP ranges; rotate regularly.
- Monitor for unusual publishes and dependency changes.

## Typosquatting

Attackers publish malicious packages with names visually similar to popular packages (e.g., `expres` instead of `express`). Primary targets: `process.env` credentials.

Notable incidents: `cross-env`, `event-stream`, `eslint-scope`.

**Defense**: Verify package names carefully, use `npm info <package>` to check metadata.

## Slopsquatting

A newer attack vector exploiting AI coding assistant hallucinations. AI tools suggest non-existent package names; attackers pre-register those names as malicious packages.

**Key difference from typosquatting**: The suggested name looks completely legitimate — no typo involved.

**Defense**:

- `npm view <package-name>` before installing any AI-suggested package.
- Check download count (legitimate packages have thousands+ downloads).
- Verify GitHub repo with real commit history.
- Be suspicious of very recently created packages.

## Dependency Confusion

See [Dependency Confusion](dependency-confusion.md).

## Account Security

- Enable 2FA with `auth-and-writes` mode.
- Use read-only CIDR-restricted tokens for CI: `npm token create --read-only --cidr=<range>`.
- Default to logged-out npm account in daily development.

## Trusted Publishing

OIDC-based publishing replacing long-lived tokens:

- Supported on GitHub Actions and GitLab CI/CD.
- Automatically generates provenance attestations.
- Short-lived credentials tied to specific workflows.

## Related Pages

- [Supply Chain Security](supply-chain-security.md)
- [Dependency Confusion](dependency-confusion.md)
- [CI/CD Security](cicd-security.md)
- [Node.js Security](nodejs-security.md)
- [OWASP NPM Security Cheat Sheet](../sources/owasp-npm-security.md)
