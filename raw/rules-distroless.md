# `rules_distroless`

Bazel helper rules to aid with some of the steps needed to create a Linux / Debian installation. These rules are designed to replace commands such as `apt-get install`, `passwd`, `groupadd`, `useradd`, `update-ca-certificates`.

Caution: `rules_distroless` is currently in beta and does not yet offer a stable Public API. However, many users are already successfully using it in production environments. Check [Adopters](#adopters) to see who's already using it.

## Contributing

This ruleset is primarily funded to support [Google's `distroless` container images](https://github.com/GoogleContainerTools/distroless). We may not work on feature requests that do not support this mission.

We will however accept fully tested contributions via pull requests if they align with the project goals (e.g. add support for a different compression format) and may reject requests that do not (e.g. supporting other packaging formats other than `.deb`).

There's limited maintainer time for this project, so we strongly encourage focused, small, and readable Pull Requests.

## Usage

Add the following to your `MODULE.bazel` file:

```
bazel_dep(name = "rules_distroless", version = "0.5.1")
```

You can find the latest release version in the [Bazel Central Registry](https://registry.bazel.build/modules/rules_distroless).

If you want to use a specific commit (e.g. there are commits in `main` that are still not part of a release) you can use one of the few mechanisms that Bazel provides to override repos.

You can use [`git_override`](https://bazel.build/versions/6.0.0/rules/lib/globals#git_override), [`archive_override`](https://bazel.build/versions/6.0.0/rules/lib/globals#archive_override), etc (or [`local_path_override`](https://bazel.build/versions/6.0.0/rules/lib/globals#local_path_override) if you want to test a local patch):

```
bazel_dep(name = "rules_distroless", version = "0.5.1")

git_override(
    module_name = "rules_distroless",
    remote = "https://github.com/bazel-contrib/rules_distroless.git",
    commit = "a69bc1949d5daf2d1b0906890667d69b0897688b",
)
```

## Examples

The [examples](https://github.com/bazel-contrib/rules_distroless/blob/main/examples) demonstrate how to accomplish typical tasks such as **create a new user group** or **create a new home directory**:

* [groupadd](https://github.com/bazel-contrib/rules_distroless/blob/main/examples/group)
* [passwd](https://github.com/bazel-contrib/rules_distroless/blob/main/examples/passwd)
* [useradd --home](https://github.com/bazel-contrib/rules_distroless/blob/main/examples/home)
* [update-ca-certificates](https://github.com/bazel-contrib/rules_distroless/blob/main/examples/cacerts)
* [keytool](https://github.com/bazel-contrib/rules_distroless/blob/main/examples/java_keystore)
* [apt-get install](https://github.com/bazel-contrib/rules_distroless/blob/main/examples/debian_snapshot) from Debian repositories.
* [apt-get install](https://github.com/bazel-contrib/rules_distroless/blob/main/examples/ubuntu_snapshot) from Ubuntu repositories.

We also have `distroless`-specific rules that could be useful:

* [flatten](https://github.com/bazel-contrib/rules_distroless/blob/main/examples/flatten): flatten multiple `tar` archives.
* [os_release](https://github.com/bazel-contrib/rules_distroless/blob/main/examples/os_release): create an `/etc/os-release` file.
* [locale](https://github.com/bazel-contrib/rules_distroless/blob/main/examples/locale): strip `/usr/lib/locale` to be smaller.
* [dpkg_statusd](https://github.com/bazel-contrib/rules_distroless/blob/main/examples/statusd): creates a `/var/lib/dpkg/status.d` package database for scanners to discover installed packages.

## Public API Docs

To read more specific documentation for each of the rules in the repo please check the following docs:

* [apt](https://registry.bazel.build/docs/rules_distroless#apt-defs-bzl): repository rule for installing Debian/Ubuntu packages.
* [apt macro](https://registry.bazel.build/docs/rules_distroless#apt-apt-bzl): legacy macro for installing Debian/Ubuntu packages.
* [rules](https://registry.bazel.build/docs/rules_distroless#distroless-defs-bzl): various helper rules to aid with creating a Linux / Debian installation from scratch.

## Adopters

* [Google's `distroless` container images](https://github.com/GoogleContainerTools/distroless)
* [Arize AI](https://www.arize.com)

Are you using `rules_distroless`? Please send us a Pull Request to add your project or company name here!
