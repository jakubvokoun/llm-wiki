---
title: "Team Onboarding Checklist"
tags: [tilt, team, onboarding]
sources: [tilt-onboarding-checklist]
updated: 2026-07-01
---

# Team Onboarding Checklist

Questions to work through before asking teammates to `tilt up`, for the best onboarding experience with [[tilt|Tilt]].

## Setup and compatibility

- Tested Tilt on **all operating systems** your team develops on?
- Do colleagues know how to run [[kubernetes|Kubernetes]] locally? (See [[tilt-choosing-clusters]] / [[tilt-local-vs-remote]].)
- Do all the services people hack on start up OK in Tilt?
- Are known gotchas or spurious errors on `tilt up` **documented**?

## Enhancements, errors, optimizations

- Edit a file — does the server auto-update? ([[tilt-control-loop]])
- Updates slow? Add a [[tilt-live-update|live_update]] rule to sync changes faster.
- Unnecessary rebuilds? Add [[tilt-file-changes|ignore rules]].
- Is auto-update right for every server, or should some use [[tilt-manual-update-control|manual update control]]?
- Does a syntax error surface a Tilt error your teammates can find? Do runtime errors show in the Tilt logs?

## Support, socialization, follow-up

- A dedicated place (Slack/mailing list) to discuss dev-env improvements?
- Do teammates know where to get help when the workflow breaks or slows?
- Is there a **README** to help teammates `tilt up` and go?
- Other teams in the org that could benefit from a cloud-native dev environment?

When ready, fork the [tilt-init repo](https://github.com/tilt-dev/tilt-init) as a starting point.

Related: [[tilt]], [[tilt-snapshots]].
