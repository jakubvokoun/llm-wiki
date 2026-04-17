---
title: "Dependency Confusion"
tags: [supply-chain, npm, security, attack]
sources: [owasp-npm-security.md]
updated: 2026-04-16
---

# Dependency Confusion

A supply chain attack where an attacker publishes a malicious package on a public registry using the same name as an internal/private package, but with a higher version number, causing the package manager to resolve the public malicious version.

## How It Works

1. Target discovers an organization's internal package name (from leaked `package.json`, job postings, error messages, stack traces).
2. Attacker publishes a malicious package to the public npm registry with the **same name** but a **higher version number**.
3. When a developer or CI runs `npm install`, the package manager resolves the public version (higher semver wins by default).
4. The malicious package executes arbitrary code via `postinstall` scripts.

## Discovery Vectors

- Leaked `package.json` files on public GitHub repositories.
- Job postings that mention internal tools or packages.
- Error messages or stack traces revealing internal dependency names.

## Mitigations

### Scoped Package Names

Use `@yourorg/package-name` instead of `package-name` for all internal packages. Scoped packages on the public npm registry are owned by the organization, preventing takeover.

### Private Registry Configuration

Configure `.npmrc` to route scoped packages to your private registry:

```
@yourorg:registry=https://your-private-registry.example.com
```

### Reserve Public Names

Publish empty placeholder packages on the public npm registry for any internal package names that are not scoped, to block attackers from claiming them.

### Access Controls

Enforce that internal packages can only be resolved from the private registry.

## Relation to Typosquatting

Dependency confusion exploits a **correct package name** (same name, higher version), unlike typosquatting which exploits **incorrect spelling**. Both are supply chain attacks but require different defenses.

## Related Pages

- [Supply Chain Security](supply-chain-security.md)
- [NPM Security](npm-security.md)
- [CI/CD Security](cicd-security.md)
- [OWASP NPM Security Cheat Sheet](../sources/owasp-npm-security.md)
