---
title: "Integrating Bazel with Tilt"
tags: [tilt, bazel, build]
sources: [tilt-integrating-bazel]
updated: 2026-07-01
---

# Integrating Bazel with Tilt

Official guide for wiring a [[bazel]] workspace into a [[tilt]] dev loop using
`custom_build` and `local`. The approach works with
[rules_docker](https://github.com/bazelbuild/rules_docker) for images and
[rules_k8s](https://github.com/bazelbuild/rules_k8s) for Kubernetes YAML.
A full runnable example lives at
[tilt-dev/bazel_example](https://github.com/tilt-dev/bazel_example); a
progression from simple build to live-update is in [[tilt-example-bazel]].

## Core pattern

A [[tiltfile]] only needs two things: Kubernetes YAML and Docker images. Both
are obtained by calling Bazel through Tilt's `local()` and `custom_build()`
functions.

### Getting YAML from Bazel

`rules_k8s` targets emit resolved YAML when run without `.apply`:

```bash
bazel run //:snack-server   # prints Kubernetes YAML to stdout
```

Wrap this in a Tiltfile helper and pass the result to `k8s_yaml`:

```python
def bazel_k8s(target):
    return local("bazel run %s" % target)

k8s_yaml(bazel_k8s(":snack-server"))
```

### Building images with `custom_build`

`rules_docker` loads an image into the local Docker daemon via:

```bash
bazel run //path/to:image -- --norun
```

Bazel names the resulting image predictably:

```
"bazel/" + <directory of BUILD file> + ":" + <rule name>
# e.g. "bazel/snack:image"
```

Use [[tilt-custom-build]] (`custom_build`) to register this as the build
command for that image name:

```python
custom_build(
    'bazel/snack',
    'bazel run --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 //snack:image -- --norun',
    [],       # deps list — filled in later; see dependency tracking below
    tag="image",
)
```

The `--platforms` flag cross-compiles Go binaries for Linux containers; adjust
for other languages.

Wrap in a helper:

```python
def bazel_build(image, target):
    custom_build(
        image,
        'bazel run --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 %s -- --norun' % target,
        [],
        tag="image",
    )

k8s_yaml(bazel_k8s(":snack-server"))
bazel_build('bazel/snack', '//snack:image')
```

## Dependency tracking

Without explicit dependency lists Tilt never knows which file changes should
trigger a rebuild. Bazel's `bazel query` exposes this information.

Two query templates cover both cases:

```python
# Files that Bazel reads to execute the target (BUILD files, generated sources)
BAZEL_BUILDFILES_CMD = """
  bazel query 'filter("^//", buildfiles(deps(set(%s))))' --order_output=no
""".strip()

# Source files that end up in the build output
BAZEL_SOURCES_CMD = """
  bazel query 'filter("^//", kind("source file", deps(set(%s))))' --order_output=no
""".strip()
```

A helper converts Bazel labels (`//snack:main.go`) to relative filesystem paths
and registers them with Tilt's `watch_file`:

```python
def watch_labels(labels):
    watched_files = []
    for l in labels:
        if l.startswith("@"):
            continue
        elif l.startswith("//external/") or l.startswith("//external:"):
            continue
        elif l.startswith("//"):
            l = l[2:]
        path = l.replace(":", "/")
        if path.startswith("/"):
            path = path[1:]
        watch_file(path)
        watched_files.append(path)
    return watched_files
```

### YAML dependencies

Changes to BUILD files or the raw YAML template should re-execute the
[[tiltfile]] (so Tilt re-fetches the resolved YAML). Wire both query results
into `bazel_k8s`:

```python
def bazel_k8s(target):
    build_deps = str(local(BAZEL_BUILDFILES_CMD % target)).splitlines()
    source_deps = str(local(BAZEL_SOURCES_CMD % target)).splitlines()
    watch_labels(build_deps)
    watch_labels(source_deps)
    return local("bazel run %s" % target)
```

### Image dependencies

Changes to source files (e.g. `snack/main.go`) should rebuild and redeploy the
image — not re-execute the Tiltfile. Pass `source_deps_files` as the deps list
to `custom_build`:

```python
def bazel_build(image, target):
    build_deps = str(local(BAZEL_BUILDFILES_CMD % target)).splitlines()
    watch_labels(build_deps)          # BUILD file changes → re-exec Tiltfile

    source_deps = str(local(BAZEL_SOURCES_CMD % target)).splitlines()
    source_deps_files = bazel_labels_to_files(source_deps)

    custom_build(
        image,
        BAZEL_RUN_CMD % target,
        source_deps_files,            # source changes → rebuild image only
        tag="image",
    )
```

`bazel_labels_to_files` (omitted above for brevity) converts Bazel label strings
to plain file paths; the full implementation is in the example repo.

## Deterministic image names

Because [[bazel]] builds are [[hermetic-builds|hermetic]], the image name is
always predictable without running a build:

| Component | Value                                   |
| --------- | --------------------------------------- |
| Prefix    | `bazel/`                                |
| Directory | path of the `BUILD` file (e.g. `snack`) |
| Tag       | rule name (e.g. `image`)                |
| Full name | `bazel/snack:image`                     |

This predictability is what makes `custom_build`'s first argument safe to
hard-code.

## Summary

| Step               | Tilt function            | Bazel mechanism                              |
| ------------------ | ------------------------ | -------------------------------------------- |
| Get K8s YAML       | `local()` + `k8s_yaml()` | `bazel run //:target`                        |
| Build image        | `custom_build()`         | `bazel run //path:image -- --norun`          |
| Watch BUILD files  | `watch_file()`           | `bazel query buildfiles(deps(...))`          |
| Watch source files | `custom_build` deps arg  | `bazel query kind("source file", deps(...))` |

## See also

- [[tilt]] — overview of the Tilt dev tool
- [[tiltfile]] — Tiltfile language and concepts
- [[bazel]] — Bazel build system
- [[tilt-custom-build]] — `custom_build` reference
- [[hermetic-builds]] — why Bazel's determinism matters
- [[tilt-example-bazel]] — worked progression example repo
