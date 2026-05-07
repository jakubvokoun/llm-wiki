---
title: "UDS Core — UDS Package Requirements"
tags:
  [uds-core, package-requirements, zarf, istio, testing, versioning, security]
sources: [uds-core-package-requirements.md]
updated: 2026-05-07
---

# UDS Core — UDS Package Requirements

UDS Packages must meet standards to ensure they are secure, maintainable, and compatible with UDS Core. Uses RFC-2119 terminology: **MUST** = mandatory, **SHOULD** = strong recommendation, **MAY** = optional.

Mandatory for Defense Unicorns engineers; strongly recommended for external maintainers.

## UDS Operator integration

- **MUST** be declaratively defined as a Zarf package
- **MUST** integrate declaratively (no clickops) with the UDS Operator
- **MUST** be capable of operating in an airgap environment
- **MUST NOT** use local commands outside of `coreutils` or `./zarf` within `zarf actions`
- **SHOULD** prioritize Helm value overrides over Zarf variable templates

## Security, policy, and hardening

- **MUST** minimize scope and number of exemptions to only what is absolutely required; if using `Exemption` CRs, **MUST** document rationale in `docs/justifications.md`
- **MUST** declaratively implement any available application hardening guidelines by default
- **SHOULD** consider security options during implementation for the most secure default (e.g., SAML w/SCIM vs OIDC)

## Packaging lifecycle and configuration

- **MUST** implement monitors for each application metrics endpoint
- **MUST** contain documentation under a `docs` folder (configuration guide + dependencies)
- **MUST** include application metadata for UDS Registry publishing
- **SHOULD** expose all configuration through a Helm chart
- **SHOULD** implement or allow for multiple flavors

## Networking and service mesh

- **MUST** define network policies under `allow` key following least privilege
- **MUST** define external interfaces under `expose` key
- **MUST** deploy and operate successfully with Istio enabled
- **SHOULD** use Istio Ambient unless specific technical constraints require otherwise
- **MAY** use Istio Sidecars; **MUST** document constraints in `docs/justifications.md`
- **SHOULD** avoid workarounds like disabling strict mTLS peer authentication

## Identity and access management

- **MUST** use and create a Keycloak client through the `sso` key for any package providing end-user login
- **SHOULD** name the client `<App> Login` (e.g., `Mattermost Login`)
- **SHOULD** use client id format `uds-<group>-<application>` (e.g., `uds-swf-mattermost`)
- **MAY** end generated Keycloak client secrets with `sso` for easy discovery

## Testing

- **MUST** implement Journey testing (basic user flows and features)
- **MUST** implement Upgrade Testing (current dev package deployed over previous release)

## Package maintenance

- **MUST** be actively maintained by CODEOWNERS
- **MUST** have a dependency management bot (e.g., renovate) opening PRs for updates
- **MUST** publish to standard registry with clear namespace/name (e.g., `ghcr.io/uds-packages/neuvector`)
- **SHOULD** be created from the UDS Package Template
- **SHOULD** lint configurations with `yamllint` and `zarf dev lint`

## Versioning

Format: `<upstream-app-version>-uds.<uds-sub-version>`

| Version       | Meaning                                 |
| ------------- | --------------------------------------- |
| `0.1.0-uds.0` | First UDS release for app version 0.1.0 |
| `0.1.0-uds.1` | Second UDS release, same app version    |
| `0.2.0-uds.0` | After app version bump to 0.2.0         |

## Related pages

- [UDS Package CR](../concepts/uds-package-cr.md)
- [Zarf](../entities/zarf.md)
- [UDS Core — Configuration & Packaging Overview](uds-core-configuration-packaging-overview.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
