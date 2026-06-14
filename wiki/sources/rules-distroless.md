---
title: "rules_distroless README"
tags: [bazel, distroless, containers, build-system]
sources: [rules-distroless.md]
updated: 2026-06-14
---

# rules_distroless README

[Bazel](../entities/bazel.md) ruleset for building Linux/Debian installations from scratch — the tooling behind custom [distroless](../entities/distroless.md) images.

## Key Takeaways

- Provides Bazel rules that **replace imperative Debian commands**: `apt-get install`, `passwd`, `groupadd`, `useradd`, `update-ca-certificates`, `keytool`.
- Currently **beta** (no stable public API yet) but used in production. Primarily funded to support Google's distroless images; scoped to `.deb` packaging only (won't add other package formats).
- Installed via [Bzlmod](../concepts/bazel-modules.md): `bazel_dep(name = "rules_distroless", version = "0.5.1")` from the Bazel Central Registry; pin to a commit with `git_override`/`archive_override`.

## Useful rules

- `apt` — repository rule to install Debian/Ubuntu packages from a snapshot.
- Helpers: `flatten` (merge tar archives), `os_release` (`/etc/os-release`), `locale` (strip `/usr/lib/locale`), `dpkg_statusd` (build `/var/lib/dpkg/status.d` so scanners can discover installed packages).
- Examples for group/user/home creation and CA certificates.

Used with [rules_oci](rules-oci.md) (which recommends rules_distroless for `.deb` packages). Adopters: Google distroless, Arize AI.

## Related

- [Distroless](../entities/distroless.md) · [OCI Images](../concepts/oci-images.md) · [rules_oci](rules-oci.md) · [Bazel Modules (Bzlmod)](../concepts/bazel-modules.md)
