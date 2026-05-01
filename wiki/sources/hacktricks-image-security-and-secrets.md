---
title: "HackTricks — Image Security, Signing, and Secrets"
tags:
  [
    container-security,
    image-security,
    secrets-management,
    supply-chain,
    hacktricks,
  ]
sources: [hacktricks-image-security-and-secrets.md]
updated: 2026-05-01
---

# HackTricks — Image Security, Signing, and Secrets

Source: [HackTricks](../entities/hacktricks.md)

## Key Takeaways

Container security starts **before** the workload launches. A backdoored, stale, or secret-embedded image means runtime hardening is already working on a compromised artifact. Image provenance, vulnerability scanning, signing, and secret hygiene form the pre-runtime security layer.

## Image Trust and Signing

Docker Content Trust (Notary + TUF) historically required signed images:

```bash
export DOCKER_CONTENT_TRUST=1
docker pull nginx:latest
tar -zcvf private_keys_backup.tar.gz ~/.docker/trust/private
```

The specific tooling has evolved, but the principle remains: **image identity and integrity should be verifiable, not assumed**.

## Vulnerability Scanning

Two questions: (1) known vulnerable packages? (2) unnecessary attack surface?

```bash
trivy -q -f json alpine:3.19
snyk container test nginx:latest --severity-threshold=high
```

A vulnerability in an unused package differs in risk from an exposed RCE path — but both inform hardening decisions.

## Build-Time Secrets

Classic mistake: copying secrets into image layers or passing via `ARG`/`ENV`. **Image layers are durable** — deleting a file in a later layer does not remove it from history.

BuildKit secure approach (ephemeral, never enters a committed layer):

```bash
export DOCKER_BUILDKIT=1
docker build --secret id=my_key,src=path/to/my_secret_file .
```

## Runtime Secrets

Prefer volumes / Docker secrets / Kubernetes Secrets over plain environment variables:

```yaml
# Docker Compose
services:
  my_service:
    image: centos:7
    secrets:
      - my_secret
secrets:
  my_secret:
    file: ./my_secret_file.txt
```

In Kubernetes: Secret objects, projected volumes, service-account tokens. Risk: broad RBAC, host mounts, or weak Pod design can still expose them.

## Exploitation / Discovery

### Secrets in environment / filesystem

```bash
env | grep -iE 'secret|token|key|passwd|password'
find / -maxdepth 4 \( -iname '*.env' -o -iname '*secret*' -o -iname '*token*' \) 2>/dev/null | head -n 100
grep -RniE 'secret|token|apikey|password' /app /srv /usr/src 2>/dev/null | head -n 100
```

### Build history leak check

```bash
docker history --no-trunc <image>
docker save <image> -o /tmp/image.tar
tar -tf /tmp/image.tar | head
```

Secrets may remain in earlier layers even after being deleted from the final filesystem.

### Embedded `.env` files

```bash
find / -type f -iname '*.env*' 2>/dev/null
cat /usr/src/app/.env 2>/dev/null
```

Embedded signing keys, JWT secrets, or cloud credentials can turn container compromise into API compromise or lateral movement.

## Runtime Defaults Table

| Platform          | Default state                          | Key risks                                                   |
| ----------------- | -------------------------------------- | ----------------------------------------------------------- |
| Docker / BuildKit | Supports secure secrets, not default   | Copying secrets via ARG/ENV, disabled provenance checks     |
| Podman / Buildah  | OCI-native, strong workflows available | Embedding secrets in Containerfiles, permissive bind mounts |
| Kubernetes        | Native Secrets + projected volumes     | Overbroad Secret mounts, service-account token misuse       |
| Registries        | Integrity optional unless enforced     | Unsigned images, weak admission control, poor key mgmt      |

## Related Pages

- [Secrets Management](../concepts/secrets-management.md)
- [Supply Chain Security](../concepts/supply-chain-security.md)
- [Container Security](../concepts/container-security.md)
- [HackTricks](../entities/hacktricks.md)
