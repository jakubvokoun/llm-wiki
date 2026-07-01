---
source_url: https://docs.tilt.dev/snapshots.html
fetched: 2026-07-01
---

# Sharing Snapshots

Snapshots save your Tilt state to a file, so you (or another Tilt user) can later load that file, and interactively explore logs and error status for that moment in time. This can help with async debugging, and add context to bug reports.

## Via Command Line

With a Tilt session running, run `tilt snapshot create <file>` to create a JSON file.

Then, run `tilt snapshot view <file>` to view the Snapshot.

A header on the top of the screen shows that you're viewing a Snapshot.

![](/assets/docimg/snapshots-header.png "Snapshots Header")

## Via Tilt Web

Create a Snapshot by clicking ![](/assets/docimg/snapshots-icon.png "Snapshots Icon")on the top-right of the screen, then clicking the "Save Snapshot" button.

To view the downloaded Snapshot, run `tilt snapshot view <file>` in your Terminal.

![](/assets/docimg/snapshots-menu.png "Snapshots Menu")

## Deprecated: Tilt Cloud

Snapshots were once part of the Tilt Cloud, a hosted service for storing
snapshots.

We've found that the new file-based flow is more flexible and easier to understand.

If you previously used Tilt Cloud and want to learn more about the deprecation,
[read this blog post](https://blog.tilt.dev/2022/05/12/offline-snapshots.html).
