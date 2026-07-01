---
title: "Tilt Example: Java/Spring Boot Live Update"
tags: [tilt, example, java, live-update]
sources: [tilt-example-java]
updated: 2026-07-01
---

# Tilt Example: Java/Spring Boot

A walkthrough of progressively optimising a [[tilt]] dev loop for a Spring Boot app running on [[kubernetes]]. Source repo: [tilt-example-java](https://github.com/tilt-dev/tilt-example-java).

## The Application

A minimal Spring MVC server (`IndexController`) that serves an HTML template via `@GetMapping("/")`. Built with Gradle and the `bootJar` task.

## Staged Optimisation

| Approach           | Deploy Time |
| ------------------ | ----------- |
| Naive              | 87.7 s      |
| Local Compile      | 13.4 s      |
| Optimized Layers   | 6.5 s       |
| With `live_update` | 4.8 s       |

---

### Step 0 — Naive (87.7 s)

Three files are all that's needed to start:

- `Dockerfile` — full build inside the container
- `kubernetes.yaml` — Deployment manifest
- `Tiltfile` — ties them together

```python
docker_build('example-java-image', '.')
k8s_yaml('kubernetes.yaml')
k8s_resource('example-java', port_forwards=8000)
```

`docker_build` rebuilds the image from source on every change, which means downloading Gradle, downloading all Spring dependencies, and compiling from scratch each time.

Benchmarking is added via `local_resource` (see [[tiltfile]]): a `deploy` resource runs `record-start-time.sh`, and `example-java` declares `resource_deps=['deploy']` so Tilt sequences them correctly.

---

### Step 1 — Benchmark Harness

```python
local_resource('deploy', './record-start-time.sh')
k8s_resource('example-java', port_forwards=8000, resource_deps=['deploy'])
```

`local_resource` exposes a manual trigger button in the Tilt UI. The server reads the recorded start time and displays elapsed seconds — giving a reproducible end-to-end metric.

---

### Step 2 — Local Compile (13.4 s)

Compile the fat Jar on the host with Gradle; copy only the artifact into the [[docker]] image.

```python
local_resource(
  'example-java-compile',
  './gradlew bootJar',
  deps=['src', 'build.gradle'],
  resource_deps=['deploy'])

docker_build(
  'example-java-image',
  './build/libs',
  dockerfile='./Dockerfile')
```

The [[docker]] context shrinks to `./build/libs` — only the compiled Jar — so the image layer is tiny and dependency downloads are skipped entirely.

---

### Step 3 — Optimised Dockerfile / Unpacked Jar (6.5 s)

A fat Jar bundles many internal files. Unpacking it exposes natural [[docker]] layer boundaries (lib dependencies vs application classes), dramatically improving cache hit rate.

**`local_resource` compile step:**

```python
local_resource(
  'example-java-compile',
  './gradlew bootJar && '
  'unzip -o build/libs/example-0.0.1-SNAPSHOT.jar -d build/jar',
  deps=['src', 'build.gradle'],
  resource_deps=['deploy'])
```

**Dockerfile (layers ordered least-to-most-frequently changed):**

```dockerfile
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
ADD BOOT-INF/lib   /app/lib
ADD META-INF       /app/META-INF
ADD BOOT-INF/classes /app
ENTRYPOINT java -cp .:./lib/* dev.tilt.example.ExampleApplication
```

Alternative: [Jib](https://github.com/GoogleContainerTools/jib) applies the same unpacking trick via Maven/Gradle plugins; the example repo includes a `custom_build`-based [[tiltfile]] for it.

---

### Step 4 — `live_update` (4.8 s)

[[tilt-live-update]] syncs changed files directly into the running container, bypassing image rebuild and pod rescheduling entirely.

```python
load('ext://restart_process', 'docker_build_with_restart')

local_resource(
  'example-java-compile',
  gradlew + ' bootJar && '
  'unzip -o build/libs/example-0.0.1-SNAPSHOT.jar -d build/jar-staging && '
  'rsync --inplace --checksum -r build/jar-staging/ build/jar',
  deps=['src', 'build.gradle'],
  resource_deps=['deploy'])

docker_build_with_restart(
  'example-java-image',
  './build/jar',
  entrypoint=['java', '-noverify', '-cp', '.:./lib/*', 'dev.tilt.example.ExampleApplication'],
  dockerfile='./Dockerfile',
  live_update=[
    sync('./build/jar/BOOT-INF/lib', '/app/lib'),
    sync('./build/jar/META-INF',     '/app/META-INF'),
    sync('./build/jar/BOOT-INF/classes', '/app'),
  ],
)
```

Key points:

- **`docker_build_with_restart`** — a wrapper from the `restart_process` extension that triggers a process restart after each `live_update` cycle.
- **`sync` steps** — push lib JARs, metadata, and compiled `.class` files into the container without rebuilding the image.
- **`rsync --checksum`** — copies only files whose content has actually changed, preventing Tilt from treating unmodified files as dirty and syncing them unnecessarily.
- **`-noverify`** JVM flag — skips bytecode verification to reduce restart time.

## CI

The repo uses CircleCI with [`ctlptl`](https://github.com/tilt-dev/ctlptl) to spin up a single-use [[kubernetes]] cluster, then runs `tilt ci` to deploy all resources and assert they reach a healthy state.

## Related Examples

- [[tilt-example-go]]
- [[tilt-example-nodejs]]
- [[tilt-example-python]]
- [[tilt-example-csharp]]

## Further Reading

- [Spring Boot Docker guide](https://spring.io/guides/topicals/spring-boot-docker/) — additional layer caching and container optimisation techniques
- [Quarkus live-update example](https://github.com/tilt-dev/tilt-example-java/tree/master/201-quarkus-live-update) — native hot-reload alternative for JVM apps
- [restart_process extension](https://github.com/tilt-dev/tilt-extensions/tree/master/restart_process)
