# Docker Security Cheat Sheet

Source: https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html

## Introduction

Docker is the most popular containerization technology. When used correctly, it can enhance security compared to running applications directly on the host system. However, certain misconfigurations can reduce security levels or introduce new vulnerabilities.

The aim of this cheat sheet is to provide a straightforward list of common security errors and best practices to assist in securing your Docker containers.

## Rules

### RULE #0 - Keep Host and Docker up to date

To protect against known container escape vulnerabilities like [Leaky Vessels](https://snyk.io/blog/cve-2024-21626-runc-process-cwd-container-breakout/), which typically result in the attacker gaining root access to the host, it's vital to keep both the host and Docker up to date. This includes regularly updating the host kernel as well as the Docker Engine.

This is due to the fact that containers share the host's kernel. If the host's kernel is vulnerable, the containers are also vulnerable. For example, the kernel privilege escalation exploit, Dirty COW, executed inside a well-insulated container would still result in root access on a vulnerable host.

### RULE #1 - Do not expose the Docker daemon socket (even to the containers)

Docker socket `/var/run/docker.sock` is the UNIX socket that Docker is listening to. This is the primary entry point for the Docker API. The owner of this socket is root. Giving someone access to it is equivalent to giving unrestricted root access to your host.

**Do not enable tcp Docker daemon socket.** If you are running docker daemon with `-H tcp://0.0.0.0:XXX` or similar you are exposing unencrypted and unauthenticated direct access to the Docker daemon.

**Do not expose `/var/run/docker.sock` to other containers.** Mounting the socket read-only is not a solution but only makes it harder to exploit.

### RULE #2 - Set a user

Configuring the container to use an unprivileged user is the best way to prevent privilege escalation attacks. This can be accomplished in three different ways:

1. During runtime using `-u` option: `docker run -u 4000 alpine`
2. During build time via Dockerfile `USER` directive
3. Enable user namespace support (`--userns-remap=default`) in Docker daemon

In Kubernetes, configure via `securityContext.runAsUser`.

### RULE #3 - Limit capabilities

Docker, by default, runs with only a subset of Linux kernel capabilities. Drop all capabilities and add only required ones:

```
docker run --cap-drop all --cap-add CHOWN alpine
```

**Do not run containers with the `--privileged` flag.**

In Kubernetes, configure via `securityContext.capabilities`.

### RULE #4 - Prevent in-container privilege escalation

Always run with `--security-opt=no-new-privileges` to prevent privilege escalation via `setuid` or `setgid` binaries.

In Kubernetes, configure via `securityContext.allowPrivilegeEscalation: false`.

### RULE #5 - Be mindful of Inter-Container Connectivity

Inter-Container Connectivity (icc) is enabled by default. Instead of using `--icc=false`, define specific network configurations with custom Docker networks for granular control.

In Kubernetes, use Network Policies.

### RULE #5a - Be careful when mapping container ports to the host with firewalls like UFW

Docker manages its own `iptables`/`nftables` rules directly and **bypasses UFW entirely**. When you publish a port with `-p 8000:8000`, Docker inserts rules that open that port to all interfaces.

**Mitigations:**
- Bind to localhost only: `docker run -p 127.0.0.1:8000:8000 myimage`
- Use `ufw-docker` to enforce firewall rules over Docker networks

### RULE #6 - Use Linux Security Module (seccomp, AppArmor, or SELinux) for Runtime Security

Do not disable default security profile. Use:
- **Seccomp**: Restrict syscalls to the minimum required
- **AppArmor**: Apply per-container profiles for mandatory access controls
- **SELinux**: Enable on host and ensure containers are labeled properly

Runtime monitoring tools: Falco, Tetragon, Cilium eBPF.

### RULE #7 - Limit resources (memory, CPU, file descriptors, processes, restarts)

Limit resources to avoid DoS attacks:
- Memory: `--memory`
- CPU: `--cpus`
- Restarts: `--restart=on-failure:<number>`
- File descriptors: `--ulimit nofile=<number>`
- Processes: `--ulimit nproc=<number>`

### RULE #8 - Set filesystem and volumes to read-only

Run containers with `--read-only` flag. For temporary storage combine with `--tmpfs`:

```
docker run --read-only --tmpfs /tmp alpine
```

Mount volumes read-only with `:ro` suffix.

In Kubernetes: `securityContext.readOnlyRootFilesystem: true`.

### RULE #9 - Integrate container scanning tools into your CI/CD pipeline

Container scanning tools detect known vulnerabilities, secrets, and misconfigurations.

Free tools: Clair, ThreatMapper, Trivy
Commercial (with free tiers): Snyk, Anchore/Grype, Docker Scout, JFrog XRay, Qualys

Secret scanning: ggshield, SecretScanner
Kubernetes misconfiguration: kubeaudit, kubesec.io, kube-bench
Docker misconfiguration: Docker Bench for Security

### RULE #10 - Keep the Docker daemon logging level at `info`

Default is `info`. Do not run at `debug` log level unless required.

### RULE #11 - Run Docker in rootless mode

Rootless mode ensures Docker daemon and containers run as unprivileged user. Even if an attacker breaks out of the container, they won't have root privileges on the host.

Different from `userns-remap` — rootless means the daemon itself operates without root.

### RULE #12 - Utilize Docker Secrets for Sensitive Data Management

Docker Secrets provide a secure way to store passwords, tokens, SSH keys. Avoid embedding sensitive data in images or runtime commands.

```
docker secret create my_secret /path/to/secret.txt
docker service create --name web --secret my_secret nginx:latest
```

Note: In Kubernetes, secrets are stored in plaintext by default — use etcd encryption or third-party tools instead.

### RULE #13 - Enhance Supply Chain Security

- **Image Provenance**: Document origin/history of container images (SLSA)
- **SBOM Generation**: Create Software Bill of Materials for each image (CycloneDX)
- **Image Signing**: Digitally sign images (Notary/Notaryproject)
- **Trusted Registry**: Store signed images with SBOMs in a secure registry
- **Secure Deployment**: Image validation, runtime security, continuous monitoring (OPA)

## Podman as an alternative to Docker

Podman is an OCI-compliant container tool by Red Hat with security benefits:
1. **Daemonless Architecture**: Fork-exec model instead of central daemon
2. **Rootless Containers**: Runs containers without root privileges by default
3. **SELinux Integration**: Built-in SELinux mandatory access controls

## References

- OWASP Docker Top 10: https://github.com/OWASP/Docker-Security
- Docker Security Best Practices: https://docs.docker.com/develop/security-best-practices/
- Docker Engine Security: https://docs.docker.com/engine/security/
- SLSA: https://slsa.dev/
