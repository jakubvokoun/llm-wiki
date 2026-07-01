---
title: "Tiltfile Per-User Configuration"
tags: [tilt, tiltfile, configuration]
sources: [tilt-tiltfile-config]
updated: 2026-07-01
---

# Tiltfile Per-User Configuration

[[tilt]] lets Tiltfile maintainers expose named options that app developers can set without ever editing the [[tiltfile]]. The system separates two roles:

- **Maintainer** — defines which options exist and how the [[tiltfile]] responds to them.
- **User** — sets option values via CLI flags, `tilt_config.json`, or `tilt args` at runtime.

## Defining Options

Options are declared with typed `config.define_*` calls before `config.parse()` is invoked. All definitions must happen before the parse call.

### `config.define_string_list(name, args=False)`

Declares a multi-value string option. Pass `args=True` to make it absorb positional arguments (at most one option per Tiltfile may be positional).

```python
config.define_string_list("to-run", args=True)
config.define_string_list("to-edit")
```

CLI without `args=True`: `tilt up -- --to-edit b --to-edit c`  
CLI with `args=True`: `tilt up -- b c` (positional, no flag name needed)

### `config.define_string(name)`

Declares a single-value string option.

```python
config.define_string("namespace")
```

CLI: `tilt up -- --namespace staging`

### `config.define_bool(name)`

Declares a boolean flag.

```python
config.define_bool("verbose")
```

CLI: `tilt up -- --verbose` (true) or `tilt up -- --verbose=False`

## Parsing and Using Options

```python
cfg = config.parse()
```

`cfg` is a plain [[starlark]] dict. Access values with `.get(key, default)` to handle the case where the user did not set the option.

```python
to_run = cfg.get("to-run", [])
```

## Common Patterns

### Subset of services (positional args)

```python
config.define_string_list("to-run", args=True)
cfg = config.parse()
config.set_enabled_resources(cfg.get("to-run", []))
```

`tilt up` → all resources; `tilt up a b d` → only a, b, d. This reimplements Tilt's default positional-args behavior explicitly.

### Named groups of services

```python
config.define_string_list("to-run", args=True)
cfg = config.parse()
groups = {
  "consumer":    ["a", "b", "c"],
  "enterprise":  ["a", "b", "d"],
}
resources = []
for arg in cfg.get("to-run", []):
    if arg in groups:
        resources += groups[arg]
    else:
        resources.append(arg)  # individual service name also accepted
config.set_enabled_resources(resources)
```

`tilt up consumer` resolves to the consumer list without the user knowing its members.

### Selective editing (keep pre-built images for everything else)

```python
config.define_string_list("to-edit")
cfg = config.parse()
to_edit = cfg.get("to-edit", [])
if "b" in to_edit:
    docker_build("b", "./b")
# services not in to_edit use the image tag already in YAML
```

`tilt up -- --to-edit b --to-edit c` builds only b and c locally.

### Start with all resources disabled

```python
config.clear_enabled_resources()
```

Resources are visible in the UI and can be enabled interactively (`tilt enable a b`) or via [[tilt-disable-resources]] patterns.

### Grouping resources in the web UI

Pass `labels=` to `k8s_resource()`, `local_resource()`, or `dc_resource()`. Resources with the same label appear in a collapsible group. A resource may carry multiple labels and will appear under each group.

```python
k8s_resource("app",     port_forwards="3000", labels="frontend")
k8s_resource("storage", port_forwards="8080", labels="database")
local_resource("flush_database", "curl http://localhost:8080/flush",
               resource_deps=["storage"], labels=["database", "script"])
```

## `tilt_config.json`

A `tilt_config.json` file placed next to the Tiltfile is read automatically. It must be a single JSON object whose keys match defined option names:

```json
{ "to-edit": ["b", "c"] }
```

- CLI args take precedence over the file when both specify the same key.
- Tilt watches the file; changing it while Tilt is running triggers a Tiltfile reload.
- External tools (e.g., onboarding scripts) can write this file to pre-populate options without user intervention.

## Changing Args at Runtime

Users can update args for a running Tilt session without restarting:

```
tilt args -- --to-edit b      # add/change flag-style args
tilt args a b                 # replace positional args
tilt args --clear             # reset to bare tilt up state
```

Args set this way continue to take precedence over `tilt_config.json` for the lifetime of that session.

## Default Behavior Without `config.parse`

Without any config calls, passing positional args to `tilt up` already sets enabled resources. The explicit equivalent is:

```python
config.define_string_list("args", args=True)
cfg = config.parse()
config.set_enabled_resources(cfg.get("args", []))
```

## Flag Type Summary

| Function                                      | CLI form                | Result type      |
| --------------------------------------------- | ----------------------- | ---------------- |
| `config.define_string_list("foo")`            | `--foo bar --foo baz`   | `["bar", "baz"]` |
| `config.define_string_list("foo", args=True)` | `bar baz` (positional)  | `["bar", "baz"]` |
| `config.define_string("foo")`                 | `--foo bar`             | `"bar"`          |
| `config.define_bool("foo")`                   | `--foo` / `--foo=False` | `True` / `False` |

At most **one** option may use `args=True`.

## Related Pages

- [[tilt]] — overview of the Tilt dev environment tool
- [[tiltfile]] — structure and execution model of Tiltfiles
- [[starlark]] — the Python-dialect language used in Tiltfiles
- [[tilt-disable-resources]] — `config.clear_enabled_resources()` and selective enable/disable
