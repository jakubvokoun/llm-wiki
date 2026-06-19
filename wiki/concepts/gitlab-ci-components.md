---
title: "GitLab CI/CD Components"
tags: [gitlab, ci-cd, components, catalog, reusability]
sources: [gitlab-ci-components.md, gitlab-ci-components-examples.md]
updated: 2026-04-23
---

# GitLab CI/CD Components

Reusable units of GitLab CI/CD configuration, versioned and optionally published to the CI/CD Catalog. GA since GitLab 17.0.

## How components work

- Defined in `templates/<name>.yml` or `templates/<name>/template.yml`
- Included via `include: component:` with semver version specifier
- Merged into the consumer's pipeline at creation time
- Parameterized through `spec:inputs` (typed, validated, explicit)

```yaml
include:
  - component: $CI_SERVER_FQDN/my-org/security-components/secret-detection@1.0.0
    inputs:
      stage: build
```

## Version resolution

`~latest` and partial semver (`1`, `1.2`) only work for catalog-published components. Commit SHA → tag → branch → partial semver (priority order).

## Why prefer inputs over variables

|                     | `inputs`                  | CI/CD variables     |
| ------------------- | ------------------------- | ------------------- |
| Type safety         | Yes                       | No                  |
| Required validation | Yes                       | No (empty string)   |
| Explicit contract   | `spec:inputs`             | Implicit            |
| Overridable by user | No (component-controlled) | Yes (pipeline vars) |

## Key patterns

### Conditional configuration via boolean inputs

```yaml
# Hidden jobs for each boolean state
.comp:caching:true:
  cache: { key: $CI_COMMIT_SHA, paths: [...] }

.comp:caching:false:
  extends: null

# Select via extends + interpolation
my-job:
  extends: ".comp:caching:$[[ inputs.enable_caching ]]"
```

### Component context for versioned images

`spec:component: [version]` enables `$[[ component.version ]]` in templates — ensures the component and its Docker image are always the same version.

### Dynamic job names

```yaml
"$[[ inputs.job-prefix ]]-scan":
  stage: $[[ inputs.stage ]]
```

Prevents job name conflicts when consumers include a component multiple times.

## CI/CD Catalog

- Browse at `Explore > CI/CD Catalog`
- Publish by enabling **CI/CD Catalog project** in settings + creating a semver release
- Verified creator badges for GitLab-maintained, Partner, and admin-verified components

## Security

**Users**: pin to SHA, audit source code, use minimal `CI_JOB_TOKEN` scope, avoid passing artifacts to component jobs.

**Maintainers**: enforce 2FA, protected branches (no force push), sign commits, require MR approvals.

## Related

- [GitLab entity](../entities/gitlab.md)
- [GitLab CI/CD Variables](./gitlab-ci-variables.md)
- [CI/CD Security](./cicd-security.md)
- [Supply Chain Security](./supply-chain-security.md)
