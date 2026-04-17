---
title: "OSTree Static Deltas for Offline Updates"
tags: [ostree, static-deltas, offline-updates, air-gap]
sources: [ostree-copying-deltas.md]
updated: 2026-04-17
---

# OSTree Static Deltas for Offline Updates

Source: `raw/ostree-copying-deltas.md` — OSTree documentation on copying static deltas for
offline/air-gapped update scenarios.

## Key Takeaways

1. OSTree can export a **self-contained static delta** to a single file (for USB, air-gap transfer).
2. `--min-fallback-size=0` is required to make the delta fully self-contained — prevents the
   delta from referencing loose objects that may not be present on the target.
3. `static-delta apply-offline` imports the file into the local repo; the content is not yet
   deployed — a separate `ostree admin deploy` or `rpm-ostree deploy` step is required.

## Commands

```bash
# Generate self-contained delta file
ostree --repo=/path/to/repo static-delta generate \
  --min-fallback-size=0 \
  --filename=delta-update-file \
  --from=<from-checksum> \
  <to-ref>

# Apply on target (copies content into repo)
ostree --repo=/ostree/repo static-delta apply-offline /path/to/delta-update-file

# Make bootable (choose one)
ostree admin deploy <to-ref>
# or with rpm-ostree
rpm-ostree deploy :<to-ref>
```

## Use Case

Suitable for:

- Air-gapped systems that cannot reach an OSTree remote
- Bandwidth-constrained environments where USB transfer is faster
- Factory provisioning / offline lab environments

## Related

- [OSTree Data Formats](ostree-formats.md) — static delta format details
- [OSTree Repository Management](ostree-repository-management.md) — online delta generation workflow
- [OSTree (entity)](../entities/ostree.md)
