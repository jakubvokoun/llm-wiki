---
title: "Custom Buttons (uibutton)"
tags: [tilt, ui, extensions]
sources: [tilt-custom-buttons]
updated: 2026-07-01
---

# Custom Buttons (uibutton)

Custom buttons add a clickable action to the [[tilt-tutorial-3-tilt-ui|Tilt web UI]] that runs a local command — lighter-weight than a full [[tilt-local-resource|local_resource]] for one-off workflow actions. The simplest path is the **`uibutton`** [[tilt-extensions|extension]]; complex cases can build buttons directly via Tilt's API (see the `cancel` extension).

## Basic button

```python
load('ext://uibutton', 'cmd_button')
cmd_button('letters:yarn install',
           argv=['sh', '-c', 'cd letters && yarn install'],
           resource='letters',            # attaches to a resource (table + resource view)
           icon_name='cloud_download',    # Material icon
           text='yarn install')
```

Logs go into the attached resource's logs. Omit `resource` and set `location=location.NAV` to place the button in the nav instead.

## Inputs

Buttons can collect input, rendered as a form when the user clicks the button's arrow. Input values are passed as environment variables (use `sh -c` so the shell expands them).

| Input        | UI         | Notes                                                |
| ------------ | ---------- | ---------------------------------------------------- |
| `bool_input` | checkbox   | `true_string` / `false_string` set the env var value |
| `text_input` | text field | arbitrary user text                                  |

```python
load('ext://uibutton', 'cmd_button', 'bool_input', 'location')
cmd_button('migrate db',
           argv=['sh', '-c', 'yarn run db:migrate $DRYRUN'],
           location=location.NAV,
           icon_name='developer_board',
           text='Run database migration',
           inputs=[bool_input('DRY_RUN', true_string='--dry-run', false_string='')])
```

A `text_input` example passing `$NAME`, or a "pod exec" button that reads a resource + command and runs `kubectl exec`, follow the same pattern. Full details: the [uibutton README](https://github.com/tilt-dev/tilt-extensions/blob/master/uibutton/README.md).

Related: [[tilt]], [[tilt-extensions]], [[tilt-local-resource]].
