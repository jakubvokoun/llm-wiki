---
source_url: https://openbao.org/docs/configuration/audit/
fetched: 2026-07-03
---

# Declarative Audit Devices

The `audit` stanza allows definition of [audit devices](/docs/audit/) from the
OpenBao server configuration file. These audit devices are created and removed
on the active node during restarts and `SIGHUP` events. Audit devices cannot
be modified and cannot duplicate existing API-created devices. Removal of the
configuration stanza will result in the audit device being removed; it is
important to have the same configuration across all servers.

# `audit` stanza

The `audit` stanza specifies various configurations for OpenBao to create
new audit devices. It takes two keyword parameters: `type`, the type of the
audit device to create; and `path`, the path of the audit device in the root
namespace. Devices take [the same parameters](/api-docs/system/audit/) as
the API: `description` and other parameters are defined at the top level and
`options` for the audit device is a `string->string` map.

* JSON* HCL

```
{

"audit": [

{

"file": {

"to-stdout": {

"description": "This audit device should never fail.",

"options": {

"file_path": "/dev/stdout",

"log_raw": "true"

}

}

}

}

]

}
```

```
audit "file" "to-stdout" {

description = "This audit device should never fail."

options {

file_path = "/dev/stdout"

log_raw = "true"

}

}
```

Multiple `audit` stanzas may exist and are executed in the order they
are specified in the configuration file(s). No two blocks may share the
same `path`.

## Audit Devices

For more information, see the [API documentation for audit
devices](/api-docs/system/audit/) or the [audit device](/docs/audit/)
documentation.
