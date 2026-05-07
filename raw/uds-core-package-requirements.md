# UDS Package Requirements

UDS Packages must meet a set of standards to ensure they are secure, maintainable, and compatible with UDS Core. This page defines those standards using RFC-2119 terminology: **MUST** indicates a mandatory requirement, **SHOULD** a strong recommendation, and **MAY** an optional practice.

These requirements are mandatory for Defense Unicorns engineers. For external maintainers, they are strongly recommended to promote consistency, quality, and security across the UDS ecosystem.

## UDS Operator integration

* **MUST** be declaratively defined as a Zarf package.
* **MUST** integrate declaratively (i.e. no clickops) with the UDS Operator.
* **MUST** be capable of operating within an airgap (internet-disconnected) environment.
* **MUST** not use local commands outside of `coreutils` or `./zarf` self references within `zarf actions`.
* **SHOULD** limit the use of Zarf variable templates and prioritize configuring packages via Helm value overrides.

## Security, policy, and hardening

* **MUST** minimize the scope and number of exemptions, to only what is absolutely required by the application. UDS Packages **MAY** make use of the UDS `Exemption` custom resource for exempting any Pepr policies, but in doing so they **MUST** document rationale for the exemptions (in `docs/justifications.md`).
* **MUST** declaratively implement any available application hardening guidelines by default.
* **SHOULD** consider security options during implementation to provide the most secure default possible (i.e. SAML w/SCIM vs OIDC).

## Packaging lifecycle and configuration

* **MUST** (except if the application provides no application metrics) implement monitors for each application metrics endpoint using its built-in chart monitors, `monitor` key, or manual monitors in the config chart.
* **MUST** contain documentation under a `docs` folder at the root that describes how to configure the package and outlines package dependencies.
* **MUST** include application metadata for UDS Registry publishing.
* **SHOULD** expose all configuration through a Helm chart (ideally in a `chart` or `charts` directory). This allows UDS bundles to override configuration with Helm overrides.
* **SHOULD** implement or allow for multiple flavors (ideally with common definitions in a common directory).

## Networking and service mesh

* **MUST** define network policies under the `allow` key as required in the UDS `Package` Custom Resource. These policies **MUST** adhere to the principle of least privilege, permitting only strictly necessary traffic.
* **MUST** define any external interfaces under the `expose` key in the UDS `Package` Custom Resource.
* **MUST** not rely on exposed interfaces being accessible from the deployment environment (bastion or pipeline).
* **MUST** deploy and operate successfully with Istio enabled.
* **SHOULD** use Istio Ambient unless specific technical constraints require otherwise.
* **MAY** use Istio Sidecars, when Istio Ambient is not technically feasible. Must document the specific technical constraints in `docs/justifications.md` if using Sidecars.
* **SHOULD** avoid workarounds with Istio such as disabling strict mTLS peer authentication.

## Identity and access management

* **MUST** use and create a Keycloak client through the `sso` key for any UDS Package providing an end-user login.
* **SHOULD** name the Keycloak client `<App> Login` (i.e. `Mattermost Login`) to provide login UX consistency.
* **SHOULD** clearly mark the Keycloak client id with the group and app name `uds-<group>-<application>` (i.e. `uds-swf-mattermost`).
* **MAY** end any generated Keycloak client secrets with `sso` to easily locate them when querying the cluster.

## Testing

* **MUST** implement Journey testing, covering the basic user flows and features of the application.
* **MUST** implement Upgrade Testing to ensure that the current development package works when deployed over the previously released one.

## Package maintenance

* **MUST** be actively maintained by the package maintainers identified in CODEOWNERS.
* **MUST** have a dependency management bot (such as renovate) configured to open PRs to update the core package and support dependencies.
* **MUST** publish the package to the standard package registry, using a namespace and name that clearly identifies the application (e.g., `ghcr.io/uds-packages/neuvector`).
* **SHOULD** be created from the UDS Package Template.
* **SHOULD** lint their configurations with appropriate tooling, such as `yamllint` and `zarf dev lint`.

## Versioning

Versions follow the format `<upstream-app-version>-uds.<uds-sub-version>`.

* `upstream-app-version` — the version of the application itself.
* `uds-sub-version` — the UDS release number, starts at `0` and increments with each release that doesn't change the app version.

Example where App Version is `0.1.0`:
- First UDS release: `0.1.0-uds.0`
- Second UDS release (same app version): `0.1.0-uds.1`
- After app version increment to `0.2.0`: `0.2.0-uds.0`
