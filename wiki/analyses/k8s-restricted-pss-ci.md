---
title: "CI on restricted-PSS Kubernetes: shell jobs and rootless image builds"
tags: [kubernetes, ci, pod-security, seccomp, apparmor, rootless, buildkit]
sources: []
updated: 2026-06-23
---

# CI on restricted-PSS Kubernetes: shell jobs and rootless image builds

Moving CI runners from a privileged Docker-in-Docker host to the [Kubernetes](../entities/kubernetes.md) executor under [Pod Security Standards](../concepts/pod-security.md) splits cleanly into two cases with very different outcomes. Ordinary shell and test jobs run comfortably in a **PSS-`restricted`** namespace — the long-standing security win over a docker executor. Container-**image** builds do not: under `restricted` they cannot run by any method, rootless included. The reusable conclusion is a two-namespace, two-pool pattern — keep general jobs locked down, and isolate image builds in a separate, deliberately less-restricted namespace whose privileged posture is then fenced back in by other controls.

This page generalizes a hands-on bring-up (one runner controller, the Kubernetes executor, [GitLab](../entities/gitlab.md) Runner, [BuildKit](../entities/docker.md)-rootless) into the pattern, the empirical evidence for why image builds escape `restricted`, and the non-obvious fixes that cost the most time.

## Why the Kubernetes executor under restricted PSS is the win

A docker-executor runner runs jobs as containers on a shared daemon; image builds typically need `privileged: true` (DinD) or a mounted docker socket. That privilege is ambient and hard to revoke per job.

Under the Kubernetes executor, each job is a Pod, so the namespace's Pod Security Standard governs what a job may request. Labelling the build namespace **`restricted`** makes the admission controller reject `privileged`, `hostPath`, `hostNetwork`, host PID/IPC, and privilege escalation **at creation time** — an exploited job cannot even start a Pod that asks for them. See [admission controllers](../concepts/admission-controllers.md), [Kubernetes security](../concepts/kubernetes-security.md), and [CI/CD security](../concepts/cicd-security.md).

## The architecture pattern

- **Controller namespace** — holds only the runner Deployment. Its ServiceAccount has API rights, scoped to managing build Pods in the build namespace(s) and nothing cluster-wide.
- **Build namespace(s)** — where job Pods land. A dedicated build ServiceAccount is mounted into every job Pod with **no** RBAC bound to it and `automountServiceAccountToken: false`, so a compromised job has no path to the API server. See [RBAC](../concepts/rbac.md).
- **One runner Deployment, multiple pools** — a single controller can serve several `[[runners]]` entries distinguished by tag, each pinned to a different namespace and security profile. This is what lets one runner span a `restricted` general pool and a separate build pool.

Hardening that applies to the controller itself, not just the jobs: pinned image tag (no `latest`), `readOnlyRootFilesystem: true` with an `emptyDir` for the writable config/home/tmp paths, an init container that copies the read-only ConfigMap into a writable dir so the runner can persist its system ID, `cap_drop: [ALL]`, `allowPrivilegeEscalation: false`, `seccompProfile: RuntimeDefault`, resource requests/limits on every container, and a default-deny [NetworkPolicy](../concepts/network-policy.md) with a narrow egress allowlist (DNS, the API server, the CI server). These embody [defense in depth](../concepts/defense-in-depth.md) and [secure-by-default](../concepts/secure-by-default.md).

| Decision                                                           | Rationale                                                                                                          |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| Two ServiceAccounts (controller vs build)                          | Controller needs API rights to spawn Pods; jobs need none. Splitting keeps a compromised job off the API server.   |
| `automountServiceAccountToken: false` on the build SA              | No token in job Pods, so no API surface from inside a job.                                                         |
| General build namespace = PSS `restricted`                         | `privileged`, `hostPath`, `hostNetwork`, privesc all rejected at admission. The core win over the docker executor. |
| `readOnlyRootFilesystem` + `emptyDir` + init-container config copy | Runner cannot be modified at runtime; writable paths are explicit and ephemeral.                                   |
| `cap_drop: [ALL]`, no privesc, `seccompProfile: RuntimeDefault`    | Minimal kernel surface for controller and every job Pod.                                                           |
| Pinned runner image tag                                            | No `latest`; bump deliberately to track the CI server version.                                                     |
| Token in a Secret, created imperatively                            | Never in a ConfigMap or the repo.                                                                                  |

## Why container-image builds cannot run under restricted PSS

This is the load-bearing finding. PSS `restricted` simultaneously mandates **all** of: `runAsNonRoot`, `allowPrivilegeEscalation: false` (i.e. `no_new_privs`), `seccompProfile: RuntimeDefault`, and `cap_drop: [ALL]`. Every container-image builder needs at least one of these relaxed:

| Builder            | Needs                                            | Blocked by, under `restricted`                                                                    |
| ------------------ | ------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| Rootless `dockerd` | userns clone; setuid `newuidmap`; remount of `/` | `RuntimeDefault` seccomp; `no_new_privs`; the default [AppArmor](../entities/apparmor.md) profile |
| Rootless BuildKit  | same (entrypoint uses a userns-creating shim)    | same — disabling the build sandbox does **not** help                                              |
| Kaniko             | runs as uid 0                                    | `runAsNonRoot: true`                                                                              |

`baseline` PSS is also insufficient: it forbids `Unconfined` seccomp, which a rootless builder needs. So the build namespace must be PSS **`privileged`** (effectively unenforced), while the runner config keeps the build Pods non-privileged by other means.

The plausible-sounding plan to run a rootless builder _inside_ the `restricted` namespace is therefore not achievable — worth flagging early to anyone who proposes it, because the failure is at the Linux-kernel/admission layer, not a config typo.

### The empirical failure ladder

Each rung was observed on a real cluster; together they pin down exactly which control blocks which step. See [seccomp](../concepts/seccomp.md), [Linux namespaces](../concepts/linux-namespaces.md), [Linux capabilities](../concepts/linux-capabilities.md), [mandatory access control](../concepts/mandatory-access-control.md), and [AppArmor profiles](../concepts/apparmor-profiles.md).

1. Rootless `dockerd` in `restricted` → `rootlesskit: fork/exec /proc/self/exe: operation not permitted`. `RuntimeDefault` seccomp blocks the user-namespace clone without `CAP_SYS_ADMIN`.
2. Same, but with `Unconfined` seccomp in a non-restricted namespace → gets past the clone, then dies at `newuidmap ... operation not permitted`. `no_new_privs` neutralizes the setuid helper.
3. Rootless BuildKit in `restricted` → identical `/proc/self/exe` failure (its entrypoint also creates a user namespace).
4. Build namespace at PSS `baseline` → admission rejects `Unconfined` seccomp outright, so the namespace must be PSS `privileged`.
5. Rootless BuildKit in a `privileged` namespace with `Unconfined` seccomp + `allowPrivilegeEscalation: true` → next failure `failed to share mount point: /: permission denied`. The default AppArmor profile blocks `mount`.
6. Add `appArmorProfile: Unconfined` → **build succeeds**.

The working recipe for a rootless image build: PSS-`privileged` namespace + `seccompProfile: Unconfined` + `appArmorProfile: Unconfined` + `allowPrivilegeEscalation: true` + `runAsUser: 1000` + default capabilities. Note the posture is still **non-privileged** (`privileged: false`, no host namespaces, no host paths) — it relaxes only the four kernel confinements rootless tooling genuinely requires, not container isolation as a whole.

### A related blocker: host-level unprivileged-userns restriction

The same rootless flow hits a second, independent wall on recent hosts — and this one bites even a plain Docker-in-Docker runner, not just Kubernetes. On Ubuntu 24.04 / kernel 6.8, the host sets `kernel.apparmor_restrict_unprivileged_userns=1`. Creating an **unprivileged** user namespace (`unshare --user`) then transitions the process into the kernel's restrictive `unprivileged_userns` [AppArmor](../entities/apparmor.md) profile, which denies **every** `mount(2)` — tmpfs, proc, bind alike. The decisive detail: this transition is driven by the **host sysctl at userns-creation time**, so `--security-opt apparmor=unconfined` / `seccomp=unconfined` on the container do **not** override it. This is the classic "passes locally, fails on CI" failure — a local daemon runs in the init userns with no enforced AppArmor, while the CI host enforces the restriction.

The escape on such a host is `--cap-add SYS_ADMIN`: the kernel exempts userns creation by a `CAP_SYS_ADMIN` holder, so the `unshare` becomes a privileged creation and mounts work (still keep `seccomp=unconfined` for `clone`/`unshare`). That is far short of `--privileged` — but `SYS_ADMIN` and `Unconfined` are themselves disallowed under PSS `restricted`, which is exactly why this work belongs in the separate `privileged`-PSS build namespace, not the general pool. See [Linux namespaces](../concepts/linux-namespaces.md) and [Linux capabilities](../concepts/linux-capabilities.md).

## The two-pool solution

| Pool (tag) | Namespace PSS             | Pod posture                                                                               | Use                   |
| ---------- | ------------------------- | ----------------------------------------------------------------------------------------- | --------------------- |
| general    | `restricted`              | `runAsNonRoot`, `cap_drop: [ALL]`, no privesc, `RuntimeDefault` seccomp                   | shell / test jobs     |
| build      | `privileged` (unenforced) | non-privileged, but `Unconfined` seccomp + `Unconfined` AppArmor + privesc + default caps | rootless image builds |

The residual risk is explicit: a PSS-`privileged` namespace no longer _forbids_ a genuinely `privileged: true` Pod — only the runner configuration currently prevents one. Close that gap with a policy admission controller (e.g. an OPA/Gatekeeper or Kyverno rule) that bans `privileged: true`, host namespaces, and host-path mounts in the build namespace, re-imposing the specific bans PSS gave up while still permitting the rootless relaxations. Pair it with a build-Pod egress allowlist. This is the layered-controls answer to "PSS is too coarse here."

## Rootless BuildKit vs DinD: the trade

- **No daemon, no privilege.** A daemonless rootless build (`buildctl-daemonless.sh`-style) replaces both the privileged DinD sidecar and any mounted docker socket.
- **Registry auth without `docker login`.** Write a registry `config.json` from the CI job token; the builder reads it directly.
- **What you lose.** Some Dockerfile-lint integrations wired into a docker-based build path don't carry over and must be re-added as a separate step. SBOM/vulnerability scanning is unaffected — scan the pushed image artifact as before. See [OCI images](../concepts/oci-images.md) and [supply-chain security](../concepts/supply-chain-security.md).
- **What it does _not_ cover.** Rootless BuildKit solves plain `docker build` (`FROM` + `RUN` + push). It does **not** solve OS-image / rootfs bootstrap — `mmdebstrap`, `debootstrap`, `chroot`, `dracut` and friends, which need real `mount(2)` calls inside the build, not just an image layer. Those run into the unprivileged-userns mount restriction above; rootless tooling does not make them work under a confined profile. Treat "build a container image" and "build an OS image" as different problems with different infrastructure.

For builds that need full kernel isolation — OS-image bootstrap included, or anything even rootless tooling can't satisfy — the next step up is a VM-based builder (e.g. KubeVirt) rather than relaxing the namespace further.

## Non-obvious fixes (Kubernetes executor)

These cost disproportionate debugging time and aren't prominent in the docs:

- **`--config` is mandatory when the runner runs non-root.** `gitlab-runner run` defaults its config path to `$HOME/.gitlab-runner/config.toml`; as a non-root user with `HOME=/`, it silently ignores `/etc/gitlab-runner`. Pass `--config=/etc/gitlab-runner/config.toml` explicitly.
- **The auth token must live in `config.toml`, not an env var.** The env token is read by `register`, not `run`. With an empty token the runner contacts the server with no credential and shows as never-contacted while jobs 400. Inject the Secret into the config at init.
- **Seccomp needs the advanced pod-spec patch.** The executor's per-container security-context seccomp keys were silently ignored in the version tested — the generated Pod had an empty `seccompProfile` even though `cap_drop` applied. Enable the advanced pod-spec feature flag and set the pod-level `securityContext.seccompProfile` via a single-line JSON merge patch (a multi-line YAML patch breaks the ConfigMap block scalar).
- **Jobs need a writable `HOME`.** Running as a non-root uid with no home, `git` fails with `could not lock config file //.gitconfig`. Set `HOME` to a writable, job-scoped path.

## Decision shape

- **Shell / test jobs → `restricted`, always.** No reason to relax; it is the default win.
- **Image builds → a separate `privileged`-PSS namespace + rootless builder + a policy admission controller** re-imposing the privileged/host bans PSS no longer enforces, plus an egress allowlist. Treat the looser PSS as a scoped exception, not a slope.
- **Full-isolation builds → VM-based builder**, kept off the shared kernel entirely.

The general lesson generalizes beyond CI: PSS `restricted` is the right default, but it is all-or-nothing per namespace. When one workload class genuinely needs a specific kernel confinement relaxed, isolate it in its own namespace and rebuild the dropped guarantees with finer-grained controls ([admission policy](../concepts/admission-controllers.md), [NetworkPolicy](../concepts/network-policy.md), dedicated ServiceAccounts) rather than loosening a shared namespace.

## Related Pages

- [Kubernetes](../entities/kubernetes.md)
- [GitLab](../entities/gitlab.md)
- [Docker](../entities/docker.md)
- [AppArmor](../entities/apparmor.md)
- [Pod Security](../concepts/pod-security.md)
- [Admission controllers](../concepts/admission-controllers.md)
- [Kubernetes security](../concepts/kubernetes-security.md)
- [RBAC](../concepts/rbac.md)
- [Network policy](../concepts/network-policy.md)
- [Seccomp](../concepts/seccomp.md)
- [AppArmor profiles](../concepts/apparmor-profiles.md)
- [Linux namespaces](../concepts/linux-namespaces.md)
- [Linux capabilities](../concepts/linux-capabilities.md)
- [Mandatory access control](../concepts/mandatory-access-control.md)
- [Container security](../concepts/container-security.md)
- [CI/CD security](../concepts/cicd-security.md)
- [GitLab CI pipeline security](../concepts/gitlab-ci-pipeline-security.md)
- [OCI images](../concepts/oci-images.md)
- [Supply-chain security](../concepts/supply-chain-security.md)
- [Defense in depth](../concepts/defense-in-depth.md)
- [Secure by default](../concepts/secure-by-default.md)
- [Immutable infrastructure](../concepts/immutable-infrastructure.md)
