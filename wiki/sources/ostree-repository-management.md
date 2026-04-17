---
title: "OSTree Repository Management"
tags:
  [ostree, atomic, repository-management, promotion, mirroring, static-deltas]
sources: [ostree-repository-management.md]
updated: 2026-04-17
---

# OSTree Repository Management

Source: `raw/ostree-repository-management.md` — OSTree official documentation on managing
content across repositories in production pipelines.

## Key Takeaways

1. **Dev/prod repository split** — separate internal high-frequency dev repo from public
   low-frequency prod repo; standard pattern for OS content vendors.
2. **Branch-based promotion pipeline** — use OSTree branches within dev to represent CI stages
   (`buildmain` → `smoketested` → `stage-N-pass`); each stage is a new commit reusing the
   same content objects from the prior stage.
3. **Cross-repo promotion** — use `pull-local` with a checksum (not a branch name) so internal
   stage branches never appear in the prod repo.
4. **Hard links** — when two repos are on the same filesystem, `pull-local` uses hard links,
   making promotion essentially free.
5. **Version metadata** — attach `--add-metadata-string=version=X.Y.Z` to prod commits; shown
   by `ostree admin status`.
6. **Static delta + summary lifecycle** — generate deltas in prod after each release, then
   always run `summary -u` (cannot be concurrent); supports deltas from N versions back.
7. **Scratch deltas** — `--empty` flag bundles all objects into one delta for clients with no
   prior OSTree history; trades server disk for fewer client HTTP requests.
8. **Pruning** — `prune --refs-only --keep-younger-than="6 months ago"` for build/dev repos;
   deleted commits leave tombstone markers.
9. **Tools** — [ostree-releng-scripts](https://github.com/ostreedev/ostree-releng-scripts) for
   scripted workflows; [Pulp OSTree plugin](https://docs.pulpproject.org/plugins/pulp_ostree/)
   for enterprise repository management.

## Command Reference

### Mirroring

```bash
ostree --repo=repo init --mode=archive
ostree --repo=repo remote add exampleos https://exampleos.com/ostree/repo
# full mirror (all history)
ostree --repo=repo pull --mirror --depth=-1 exampleos:exampleos/x86_64/standard
# shallow mirror (last 3 commits)
ostree --repo=repo pull --mirror --depth=3 exampleos:exampleos/x86_64/standard
```

### Branch Promotion (within dev repo)

```bash
# Promote buildmain commit that passed smoketests
ostree commit \
  -b exampleos/x86_64/smoketested/standard \
  -s 'Passed smoketests' \
  --tree=ref=aec070645fe53...
```

### Cross-Repo Promotion (dev → prod)

```bash
# Pull content by checksum (hides stage branch from prod)
checksum=$(ostree --repo=repo-dev rev-parse exampleos/x86_64/stage-3-pass/standard)
ostree --repo=repo-prod pull-local repo-dev ${checksum}

# Create prod release commit with version metadata
ostree --repo=repo-prod commit \
  -b exampleos/x86_64/standard \
  -s 'Release 1.2.3' \
  --add-metadata-string=version=1.2.3 \
  --tree=ref=${checksum}
```

### Delta and Summary Management

```bash
# Delta from previous commit
ostree --repo=repo-prod static-delta generate exampleos/x86_64/standard
# Delta from 2 commits back
ostree --repo=repo-prod static-delta generate \
  --from=exampleos/x86_64/standard^^ \
  --to=exampleos/x86_64/standard
# Scratch delta for initial downloads
ostree --repo=repo-prod static-delta generate \
  --empty \
  --to=exampleos/x86_64/testing-devel
# Always update summary after delta generation
ostree --repo=repo-prod summary -u
```

### Pruning

```bash
# Truncate history older than 6 months (tombstone markers left for deleted commits)
ostree --repo=repo-dev prune --refs-only --keep-younger-than="6 months ago"
```

## Repository Pipeline Model

```
git → [build system] → repo-build (bare-user)
                            │ pull-local
                            ▼
                       repo-dev (archive)
                       branches: buildmain → smoketested → stage-N-pass
                            │ pull-local (by checksum)
                            ▼
                       repo-prod (archive)
                       branches: exampleos/x86_64/standard
                            │ static-delta + summary
                            ▼
                       CDN / HTTP mirror
```

## Design Principles

- OSTree is **not** a primary content store — binaries derive from git; rebuild from source if needed.
- The `archive` format maps naturally to HTTP serving; bare formats for build time only.
- Keep prod history shallow; dev history is for CI/testing lookback only.

## Related

- [OSTree Data Formats](ostree-formats.md)
- [OSTree Buildsystem and Repository Management](ostree-buildsystem-and-repos.md)
- [OSTree Authenticated Remote Repositories](ostree-authenticated-repos.md)
- [OSTree (entity)](../entities/ostree.md)
- [Atomic Linux](../concepts/atomic-linux.md)
