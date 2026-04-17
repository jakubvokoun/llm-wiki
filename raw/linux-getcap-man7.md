# getcap(8) — Linux manual page

## NAME

```
getcap - examine file capabilities
```

## SYNOPSIS

```
getcap [-v] [-n] [-r] [-h] filename [ ... ]
```

## DESCRIPTION

```
getcap displays the name and capabilities of each specified file.
```

## OPTIONS

```
-h  prints quick usage.

-n  prints any non-zero user namespace root user ID value found to
    be associated with a file's capabilities.

-r  enables recursive search.

-v  display all searched entries, even if the have no file-
    capabilities.

NOTE: an empty value of '=' is not equivalent to an omitted (or
removed) capability on a file. This is most significant with
respect to the Ambient capability vector, since a process with
Ambient capabilities will lose them when executing a file having
'=' capabilities, but will retain the Ambient inheritance of
privilege when executing a file with an omitted file capability.
This special empty setting can be used to prevent a binary from
executing with privilege. For some time, the kernel honored this
suppression for root executing the file, but the kernel developers
decided after a number of years that this behavior was unexpected
for the superuser and reverted it just for that user identity.
Suppression of root privilege, for a process tree, is possible,
using the capsh(1) --mode option.

filename
    One file per line.
```

## REPORTING BUGS

Please report bugs via:
https://bugzilla.kernel.org/buglist.cgi?component=libcap&list_id=1090757

## SEE ALSO

```
capsh(1), cap_get_file(3), cap_to_text(3), capabilities(7),
user_namespaces(7), captree(8), getpcaps(8) and setcap(8).
```
