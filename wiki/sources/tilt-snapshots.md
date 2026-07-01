---
title: "Sharing Snapshots"
tags: [tilt, debugging, snapshots]
sources: [tilt-snapshots]
updated: 2026-07-01
---

# Sharing Snapshots

A **snapshot** saves [[tilt|Tilt]] state to a file so you or another user can later load it and interactively explore logs and error status for that moment — useful for async debugging and richer bug reports.

## Create & view

**Via CLI** (with a Tilt session running):

```
tilt snapshot create <file>   # writes a JSON file
tilt snapshot view <file>     # opens it; a header indicates you're viewing a snapshot
```

**Via Tilt web UI:** click the snapshot icon (top-right) → **Save Snapshot** to download the file, then `tilt snapshot view <file>` to open it.

## Deprecated: Tilt Cloud

Snapshots were once stored in the hosted **Tilt Cloud** service. The file-based flow replaced it as more flexible and easier to understand.

Related: [[tilt]], [[tilt-debug-faq]], [[tilt-tutorial-3-tilt-ui]].
