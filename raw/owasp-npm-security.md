# NPM Security Best Practices

The following cheatsheet covers several npm security best practices and productivity tips, useful for JavaScript and Node.js developers.

## 1) Avoid publishing secrets to the npm registry

Whether you're making use of API keys, passwords or other secrets, they can very easily end up leaking into source control or even a published package on the public npm registry.

The npm CLI packs up a project into a tar archive (tarball) in order to push it to the registry. Key considerations:

- If there is either a `.gitignore` or a `.npmignore` file, the contents of the file are used as an ignore pattern when preparing the package for publication.
- If both ignore files exist, everything not located in `.npmignore` is published to the registry. This is a common source of confusion and can lead to leaking secrets.

Another good practice is to use the `files` property in package.json, which works as an allowlist and specifies the array of files to be included in the package. Use `--dry-run` command-line argument to your publish command to review how the tarball is created without actually publishing it.

## 2) Enforce the lockfile

Both Yarn and npm act the same during dependency installation. When they detect an inconsistency between the project's `package.json` and the lockfile, they compensate for such change based on the `package.json` manifest by installing different versions than those that were recorded in the lockfile.

To enforce the lockfile:
- If you're using Yarn, run `yarn install --frozen-lockfile`.
- If you're using npm run `npm ci`.

## 3) Minimize attack surfaces by ignoring run-scripts

The npm CLI allows packages to define scripts to run at specific entry points during the package's installation in a project (e.g., `postinstall` scripts). Bad actors may create or alter packages to perform malicious acts by running any arbitrary command when their package is installed.

Best practices:
- Always vet and perform due-diligence on third-party modules.
- Hold-off on upgrading immediately to new versions.
- Before upgrading, review changelog and release notes.
- When installing packages, add the `--ignore-scripts` suffix to disable execution of any scripts by third-party packages.
- Consider adding `ignore-scripts` to your `.npmrc` project file or global npm configuration.

### Using an allowlist for lifecycle scripts

Disabling lifecycle scripts by default by adding `ignore-script` to your `.npmrc` file is the safest option. If you use packages that rely on lifecycle scripts for legitimate reasons, you can use a plugin like `@lavamoat/allow-scripts` to create an allowlist:

```json
{
  "lavamoat": {
    "allowScripts": {
      "sharp": true
    }
  }
}
```

## 4) Assess npm project health

### npm outdated command

Run `npm outdated` to see which packages are out of date. Dependencies in yellow correspond to the semantic versioning as specified in the package.json manifest, and dependencies colored in red mean there's an update available.

### npm doctor command

Run `npm doctor` to review your npm setup:
- Check the official npm registry is reachable.
- Check that Git is available.
- Review installed npm and Node.js versions.
- Run permission checks on local and global `node_modules`.
- Check the local npm module cache for checksum correctness.

## 5) Audit for vulnerabilities in open source dependencies

Security doesn't end by just scanning for security vulnerabilities when installing a package but should also be streamlined with developer workflows throughout the entire lifecycle of software development.

- Scan for security vulnerabilities in third-party open source projects.
- Monitor snapshots of your project's manifests so you can receive alerts when new CVEs impact them (OWASP Dependency-Track).

## 6) Artifact governance and supply chain protections

### Use a local npm proxy

Verdaccio is a simple lightweight zero-config-required private registry: `npm install --global verdaccio`.

Features:
- Supports the npm registry format including private package features, scope support, package access control.
- Provides capabilities to hook remote registries and route each dependency to different registries and caching tarballs.
- Uses htpasswd security by default, also supports Gitlab, Bitbucket, LDAP.

### Governance & Verification Steps

Supply-chain attacks increasingly target build artifacts, registries and CI credentials:

- Track provenance and produce an SBOM for builds (CycloneDX/SPDX).
- Sign artifacts and build provenance (e.g., use Sigstore/cosign).
- Prefer immutable, access-controlled registries or vetted mirrors.
- Restrict, scope and rotate CI and publisher tokens.
- Verify packages during CI: check signatures or provenance, validate the SBOM, run SCA and static analysis, install from pinned lockfile resolutions.
- Automate monitoring and alerts for unusual publishes, token usage or dependency changes.

## 7) Responsibly disclose security vulnerabilities

Security researchers should follow a responsible disclosure program, which aims to connect the researchers with the vendor or maintainer of the vulnerable asset. Once the vulnerability is correctly triaged, the vendor and researcher coordinate a fix and a publication date.

## 8) Enable 2FA

The npm registry supports two modes for enabling 2FA:
- Authorization-only — when a user logs in to npm or performs profile information changes.
- Authorization and write-mode — profile and log-in actions, as well as write actions such as managing tokens and packages.

Enable via CLI:
```
npm profile enable-2fa auth-and-writes
```

## 9) Use npm author tokens

Tokens can be managed through the npm registry website or CLI. Create a read-only token restricted to a specific IPv4 address range:

```
npm token create --read-only --cidr=192.0.2.0/24
```

Use `npm token list` or `npm token revoke` to manage tokens.

## 10) Understanding typosquatting and slopsquatting attacks

### Typosquatting attacks

Typosquatting is an attack that relies on mistakes made by users, such as typos. Bad actors publish malicious modules to the npm registry with names that look much like existing popular modules. Notable incidents include `cross-env`, `event-stream`, and `eslint-scope`.

One of the main targets for typosquatting attacks are user credentials, since any package has access to environment variables via `process.env`.

### Slopsquatting attacks

Slopsquatting is a newer attack vector that exploits AI coding assistants. When developers ask AI tools to suggest packages, these models may hallucinate package names that do not actually exist. Attackers monitor these hallucinations and publish malicious packages with those exact names.

To protect against slopsquatting:
- Run `npm view <package-name>` before installing any AI-suggested package.
- Check the package download count — legitimate packages have thousands or millions of downloads.
- Verify the package has a real GitHub repository with genuine code, commits and contributors.
- Be suspicious of packages created very recently with no release history.
- Never blindly run `npm install` on packages suggested by AI tools without independent verification.

## 11) Use trusted publishers for secure package publishing

Trusted publishing with OpenID Connect (OIDC) provides a more secure alternative to long-lived tokens by using short-lived, workflow-specific credentials automatically generated during CI/CD processes. Supported on GitHub Actions and GitLab CI/CD Pipelines.

### How trusted publishing works

Trusted publishing creates a trust relationship between npm and your CI/CD provider using OIDC. The npm CLI automatically detects OIDC environments and uses them for authentication before falling back to traditional tokens. This eliminates security risks associated with long-lived write tokens.

### Automatic provenance generation

When publishing via trusted publishing, npm automatically generates provenance attestations that provide cryptographic proof of package authenticity.

## 12) Prevent dependency confusion attacks

A dependency confusion attack occurs when an attacker publishes a malicious package on the public npm registry using the same name as your internal private package, but with a higher version number.

To protect against dependency confusion:
- Always use **scoped package names** for internal packages (e.g., `@yourorg/package-name`).
- Configure your `.npmrc` to explicitly point scoped packages to your private registry.
- Reserve your internal package names on the public npm registry by publishing an empty placeholder.

## Final Recommendations

- Be extra-careful when copy-pasting package installation instructions into the terminal.
- Default to having an npm logged-out user in your daily work routines.
- When installing packages, append the `--ignore-scripts` to reduce the risk of arbitrary command execution.
