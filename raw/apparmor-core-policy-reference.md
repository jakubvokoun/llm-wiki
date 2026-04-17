(DRAFT) **WARNING:** this document is in a very early stage of creation it is not in any shape yet to be used as a reference manual

Intro
-----

This document the core of AppArmor policy, including both documentation
of the reference profile language\*, its semantics, and guidelines and
semantics for AppArmor policy enforcement in general. It does not cover
the [standardized layout of policy](Policy_Layout), nor the compiled
[binary representation](Binary_Profile_Language) of the policy that
is loaded into the kernel, the kernel interfaces, the tools or any
other components built around the core enforcement engine.

AppArmor policy is written in a declarative language in which the order
of rules with in a given section or block, does not matter. Policy
is by [convention](Policy_Layout) written so that it is contained
in multiple files but this is not a requirement, it could just as
easily be written in a single file. The policy language is compiled
to a architecture independent [binary](Binary_Profile_Language)
format that is loaded into the kernel for enforcement.

The base unit of AppArmor confinement is the **profile**, it contains
a set rules which are enforced when the profile is associated with a
running program. The rules within the profile provide a white list
of different permission that are allowed, along with a few other
special rules.

The text in AppArmor policy is split into two sections the preamble
and the profile definitions. The preamble must occur at the head of
the file and once profile definitions begin, no more preamble rules
are allowed (even in files that are included into the profile). When
AppArmor policy (set of profiles) is split across multiple files
each file can have its own preamble section, which may be the same or
different from other files preamble. File included with in a profile
section can not have a preamble section.

Other languages could be constructed and compiled to the binary
representation used by the AppArmor enforcement engine, but the
project currently only supports the language documented below.

Versions of the Policy language
-------------------------------

The policy language has seen multiple minor revisions and
extensions. The v2.x versions of the language are all minor extensions
and improvements the v3.x version of the language makes several
extensions in both syntax and semantics.

The largest difference between the v2 and v3 formats is to do with
semantic changes. The v2 format implicitly grants permissions for
several new rule types that are explicitly required in the v3 format.

For example:

-   In the v2 format capability sys\_admin, is all that is required to mediate mount
-   In the v3 format capability sys\_admin, and mount rules are required for mediation of mount

The v2 format can be compiled to a v3 format compatible binary by
implicitly including generic rules that cover the new mediation
types. The v3 format can be forced to compile into a v2 compatible
binary by excluding mediation types that are not supported in older
releases.

Documentation of language syntax
--------------------------------

Through this document the syntax of the profile language
is described through words, examples, and a modified [Naur
form](http://en.wikipedia.org/wiki/Backus%E2%80%93Naur_Form%7CBackus).
Generally the Backus Naur form for a particular part of the language
will appear at the begin of the section followed by expanded
explanation and examples. The complete language syntax reference is
at the [end of the document.](????)

The modified Backus naur form uses the following syntax (which is
similar to pcre regular expressions).

```
 <name> - denotes a subpattern (rule).  That is matched against.
 <name> := begins the definite of a subpattern (rule).
 '' - single quotes are used to denote literal text
 ( ) group rules and text together
 [ ] - square bracket denote the eclosed pattern is optional, that is can appear 0 or 1 time
 * - a trailing * on a pattern indicate the pattern may appear 0 or more times
 + - a trailing + on a pattern indicate the pattern may appear 1 or more times
 | - is used to separate alternate subpatterns within an expression
```

Pattern matching
----------------

The AppArmor language supports pattern matching that is used at
various points in the language.

### AppArmor globbing syntax

AppArmor uses a file globbing syntax similar to that used by the
bash shell. Globbing is not standard full regular expression syntax
instead it uses a few characters known as wild cards. The AppArmor
wildcards have slightly different semantics than that of bash.

-   <b>\*</b> - match zero or more characters at the directory level. When looking at the path as a string this will match every character except <b>/</b>
    -   This will match dot files (file names starting with <b>.</b>), excepting the special dot files <b>.</b> and <b>..</b>, if it is placed immediately after the directory /
        eg. /dir/\*
    -   This will not ever match an empty directory string eg. /dir//
    -   pcre equivalent is (\[^/\\000\]\*)
-   <b>\*\*</b> - match 0 or more characters over multiple directory levels.
    -   This will match dot files (file names starting with <b>.</b>), excepting the special dot files <b>.</b> and <b>..</b>, if it is placed immediately after the directory /
        eg. /dir/\*\*
    -   pcre equivalent is (\[^\\000\]\*)
-   <b>?</b> - match a single character that is not <b>/</b>
    -   pcre equivalent is \[^/\]
-   <b>{}</b> - alternation - a comma separated list of alternate strings that can be matched. An empty string is allowed and means no string is a viable alternative
    -   pcre equivalent is (|)
-   <b>\[\]</b> - character class
    -   same as pcre syntax
-   <b>\[^\]</b> - inverted character class
    -   same as pcre syntax
-   <b>{\*^}</b> - a <b>proposed</b> glob similar to \* with an alternation style list of things it is not allowed to match.
    eg. /etc/{\*^shadow} is the same as allowing everything /etc/\* matches except /etc/shadow
    eg. /etc/{\*^shadow,passwd} is the same as /etc/\* - /etc/{shadow,passwd}
    eg. /etc/{\*^\*shadow} is the same as /etc/\* - /etc/\*shadow
    \* note that an empty alternation entry is not allowed ie. {\*^shadow,}
-   <b>{\*\*^}</b> - a <b>proposed</b> glob similar to \*\* with an alternation style list of things is is not allowed to match eg. /etc/{\*\*^shadow} is the same as /etc/\*\* matches - /etc/shadow
    eg. /etc/{\*\*^shadow,passwd} is the same as /etc/\*\* - /etc/{shadow,passwd}
    eg. /etc/{\*\*^\*shadow} is the same as /etc/\*\* - /etc/\*shadow
    \* note that an empty alternation entry is not allowed ie. {\*\*^shadow,}

Notes:

-   Nesting expressions in alternations - first allowed in apparmor 2.3
-   special characters can be matched against by escaping them with the **\\** character. eg. \\\*
    -   the escape character **\\** is matched by escaping it. eg. \\\\
-   characters can be expressed as a number using the escape character **\\** followed by the characters number.
    -   octal number representation \\001
    -   hexadecimal number representation \\x5f

#### Examples using globbing to match files

```
/dir/file - match a specific file
/dir/*    - match any files in a directory (including dot files)
/dir/a*   - match any file in a directory starting with <b>a</b>
/dir/*.png - match any file in a directory ending with <b>.png</b>
/dir/[^.]* - match any file in a directory except dot files
 /dir/ - match a directory
/dir/*/ - match any directory within /dir/
/dir/a*/ - match any directory within /dir/ starting with a
/dir/*a/ - match any directory within /dir/ ending with a
 /dir/** - match any file or directory in /dir/ or any directory below /dir/
/dir/**/ - match any directory in /dir/ or any directory below /dir/
/dir/**[^/] - match any file in /dir/ or any directory below /dir/
```

### AppArmor pcre syntax (currently not supported)

**TODO**: cleanup use same syntax style in globbing and pcre and examples

Sometime AppArmor globbing is insufficient for expressing the desired
match, in these cases access to a subset of pcre regular expression
syntax is available.

-   <b>'(' <expr> ')'</b> - group expr to be treated as a single expr
-   <b> <expr> '\*' </b> - match expr 0 or more times
-   <b> <expr> '+' </b> - match expr 1 or more times
-   <b> <expr> '?' </b> - match expr 0 or 1 time
-   <b>\[\]</b> - character class
-   <b> <expr> '|' <expr> </b> - alternation. Match <expr> or <expr>
-   <b> '^' <expr> </b> - anchor the expression to the beginning of the string
-   <b> <expr> '$' </b> - anchor the expression to the tail of the string.
    -   same as pcre syntax
-   <b>\[^\]</b> - inverted character class
    -   same as pcre syntax

In AppArmor when pcre pattern matching is used the expressions are
always anchored. That is that the pattern must start with **^**
and end with **$**. If an expression is not anchored it will not be
treated as pcre based pattern; e.g.:

```
 ^/(foo|bar)+/$
```

Preamble section
----------------

The preamble consists of a set of rules that globally affect the
profiles that are defined in the following profile section of the
file. In general the rules that appear in the preamble can not appear
in the profile.

### Rules allowed within the preamble section

-   variable definitions
-   alias and rewrite rules
-   conditional rules
-   comments
-   include - as long as they don't include rules restricted to the profile body

### Rules not allowed in the preamble section

capability rules rlimit rules file rules network rules ipc rules children profile and hats

-   alias & rewrite rules. Alias and rewrite rules can be used to rewrite all matching paths in a profile and are done after variable resolution. They are useful for site-specific configuration, without having to customize a shipped profile.
    Eg. if mysql databases are stored in /home/mysql:
    alias /var/lib/mysql/ -&gt; /home/mysql/,
    rewrite /var/lib/mysql/ -&gt; /home/mysql/,
    As of AppArmor 2.5 there are two forms of these rules.
    -   alias - adds new rules for each path that the rule matches.
        NOTE: A bug in AppArmor 2.3, 2.4 causes alias rules to behave as rewrite rules.

    -   rewrite - rewrites existing rules that match the rule. A subtlety with rewrite rules that may not be immediately apparent is the mapping will mask the original path. In the above example, there is no way for an application to access files that are actually in /var/lib/mysql/ once the alias is in use in the profile.

<!-- -->

-   variables
-   include - as long as the files that are included only contain preamble rules

Profile section
---------------

```
 <profile section> ::= <profile>*
```

The profile section consists of one or more profiles. Generally if
there is more than one profile the profiles are logically related but
the do not have to be. The order profiles appear within the profile
section is irrelevant though it is generally recommend that the main
profile comes first with supporting, or hat profiles trailing.

### Profile

```
 <profile> ::= <profile header> '{' <profile body> '}'
 <profile header> ::= <attachment specification> <profile flags>
 <profile header> ::= 'profile' <profile_name> <profile flags>                    (AppArmor 2.3 and later)
 <profile header> ::= 'profile' <attachment specification> <profile flags>        (AppArmor 2.3 and later)
 <profile header> ::= 'profile' <profile_name> <attachment specification> <profile flags>  (AppArmor 2.6 and later)
```

The profile (also known as a domain) is the base unit of confinement
within AppArmor. It contains the set of rules that will be enforced on
a task. It starts with a header which specifies the profile's name(s)
and flags that control certain aspects of a profiles behavior. The
body of the profile then contains a the set of rules defining what
is allowed. The set of rules is a white list, that is anything not
specified is not allowed. Profile rules just like rules in the preamble
are declarative and order does not matter.

The profile header contains the name(s) of the profile and flags
that govern the behavior of the profile. A profile begins with the
sometimes option profile keyword followed the name(s) and or attachment
specification of the profile and then the optional profile flags.

The profile keyword is optional if the profile is an attachment
specification (begins with a **/**) otherwise it is required.

#### Profile names and attachment specifications

```
 <attachment specification> ::= ('/'|[:alphanum:]|<variable>)[^[:whitespace:]) ????? check lexer for exact pattern
 <profile name> ::= [:alphanum:] ?????? check lexer for exact pattern
```

The attachment specification is used by AppArmor to determine which
executables a profile will attach to. If alternate profile name is not
supplied the attachment specification is also used as the profiles
name and if an attachment specification is not specified a profile
name must be provided.

The name of a profile is very import in AppArmor. It provides not
only a name(s) that users can associate to the set of profile rules,
but is also used for labeling, ipc, and in the case that the name is
an attachment specification it determines to which executables the
profile attaches.

Profile names begin with an optional namespace name (see namespaces
below) followed by the profile name. Profile names must begin with
either an alphanumeric character or if an attachment specification
**/** or a variable that when expanded matches the aforementioned
restrictions, and they can not begin with the sequence **//** and
within the profile // has special meaning. Profile names can not end
with the **/** character, nor can they end with the **,** character
unless the **,** is escaped or the profile name is quoted. Profile
names can not contain white space unless the white space is escaped
or the profile name is quoted. Escaping is done by placing the **\\**
character in front of the character to be escaped and quoting is done
using two **"** characters, one at the beginning of the profile name
and one at the end.

If the profile name begins with a **/** character then the
profile name is more than just a handle, it provides an attachment
specification. That is during exec the profile name is matched against
when deciding which profile to attach. If it the profile name does
not begin with **/** then it must begin with the profile keyword.

When a profile name is begun with a variable each value in the variable
list must meet the leading alphanumeric character or **/**. For
variables specified internal a profile name the restriction on each
variable value is the same as the restriction on characters within
the profile name.

Example valid profile names:

```
 /bin/example
 /bin/example\ name
 “/bin/example name”
 @{var}
 @{var}/example
 “@{var}/example”
 “/bin/@{var}”
 profile /bin/example
 profile example
 profile “example name”
 profile “example\ name”
 /bin/example\,
 “/bin/example,”
 profile example /bin/example
```

Example invalid profile names:

```
 /bin/example/          # ends with /
 /bin/example,          # ends with , that isn't escaped or quoted
 /bin/example name      # This is multiple names not a single name
 "/bin/example name     # needs an ending quote character
 :profile               # starts with a :
 +profile               # starts with a +
```

##### Special character sequences within the profile name

```
 //
 ://
 +//
```

##### Multiple profile names (not yet supported)

The specification for this feature is not finished.

##### Multiple attachments

Multiple attachments can be achieved in apparmor 2.6 and later by
specifying a profile name and then an attachment with alternations
in the regex; e.g.:

```
 profile foo /{usr/bin,bin}/foo
```

##### Profile names that specify attachment

Profiles that begin with **/** are used in determining whether a
profile matches, and attaches, to an executable. For unconfined
tasks, and tasks confined by a profile doing a px based transition
the profile name is matched against the executable name, and if a
match is made then the profile is attached to the task.

[Information on how the profile name interacts with the exec transition rules](#Execute_rules)

###### Profile names with globbing (AppArmor 2.4 and later)

Profiles that specify attachment can contain AppArmor pattern
matching characters, allowing the profile to match against more than
one executable.

```
 /bin/** {
    #profile body
 }
```

This example would match against all executables in /bin/, when
multiple profiles overlap their attachment specification then the most
specific match wins. If the most specific match can not be determined
then the longest left match wins. For example:

```
 /bin/foo {
    #profile body
 } 
  /bin/f* {
    #profile body
 } 
  /bin/** {
    #profile body
 } 
```

When matching against the executable /bin/foo, the /bin/foo profile is an exact match so it is chosen.
For the executable /bin/fat, the profile /bin/foo does not match, and /bin/f\* is more specific than
 /bin/\*\* so, /bin/f\* is the profile that will be attached.

If a special pattern match character is to be part of the profile
name and not used to indicate pattern matching then the character
must be escaped with a leading **\\** character. Quoting the profile
name will not prevent the special pattern matching characters from
being interpreted as pattern matching characters.

##### Profile names without attachment specification (AppArmor 2.3 and later)

Profile names do not begin with the **/** character are not used when
determining which profile to attach to a task during an exec as their
name does not reside in the filesystem namespace. Instead they are
used only used when explicitly asked for either through a named exec
transition or via the change\_profile api.

Creating profiles without attachment is much the same as creating
standard profiles except that the “profile” key word appears
before the name of the profile.

Example
-------

```
 profile An.unattached.profile {

   # profile body
 }
```

The profile names have a few limitations, they can not begin with
the ':', '.' or '+' characters (though they may be used internally)
and they can only contain whitespace characters if the name is
quoted. Starting the profile name with '/' is the same as specifying
a standard profile that will attach to a program of the same name.

Example
-------

```
 profile /bin/ping {
     ...
 }
```

is the same as just doing

```
 bin/ping {
     ...
 }
```

###### Uses for profiles that don't attach

Profiles don't provide confinement unless they are attached to a
running program. Profiles without attachment specification will not
attach to a program when it is invoked (the executable name will never
match the profile name), nor can they be transitioned to through a
standard px transition rule. For one of these profiles to be attached
so it provides confinement either change\_profile profile or the new
named (specified) profile transition is used.

This type of profile provides for more flexibility and advanced uses
such as providing roles, or specialized profiles for system utilities
that generally should not be confined by a system wide profile. For
example, grep generally should not have its own profile but, it can
be useful to have a specialized profile for an invocation of grep
from within a confined shell script.

##### Profiles with names and attachment specifications (AppArmor 2.6+)

As of AppArmor 2.6 it is possible to specify the profile name separate
from the profile attachment.

```
 profile name /example/attachment { }
```

As of 3.???? it is possible to make the attachment conditional upon
the user or executable owner

```
 profile name owner=jj /example/attachment { }
 profile name user=foo /example/attachment { }
```

##### Profile namespaces (AppArmor 2.3+)

AppArmor allows for profiles to exist in different [profile
namespaces](AppArmor_Namespaces), this allows virtualizing policy for
vhosts, or other container solutions. While the recommended way of
doing this is using initscripts and [profile layout](Policy_Layout)
it is possible to specify a the namespace a profile belongs to as
part of its name.

###### Namespace limitations in AppArmor 2.5

-   There is no tool or initscript support so setting up namespaces is a completely manual process
-   namespaces can not be automatically attached to a container, but a userspace program can use the change\_profile call to enter a profile namespace. After which profiles loaded from the container will be loaded to the namespace without any further intervention.

###### Namespace limitations in AppArmor 2.3 and 2.4

-   Namespaces were flat not hierarchical
-   Only confined tasks could live in a separate namespace, unconfined tasks always reverted to the default namespace
-   the first namespace was referred to as the default namespace, which is now the root namespace of the namespace hierarchy
-   There was no tool or initscript support so using them was a completely manual process

##### profile flags

```
 <profile flags> ::= ( 'flags=(' | '(' ) <flag keyword> (' ' <flag keyword>)* ')'
 <flag keyword> ::= <mode flag> | <relative flag> | <attach flag>
 <mode flag> ::= 'enforce' | 'complain' | 'debug' | 'kill'
 <relative flag> ::= 'chroot_relative' | 'namespace_relative'
 <attach flag> ::= 'attach_disconnected' | 'no_attach_disconnected' | 'chroot_attach' | 'chroot_no_attach'
```

NOTE:

-   'debug' is obsolete and may result in a parse error (tested on 2.8)
-   'enforce' and 'kill' are not yet supported (tested on 2.8)

If profile flags are not specified a default of enforce, namespace
relative, no\_attach\_disconnected, chroot\_no\_attach mode is used,
v2. NOTE

-   policy version flags
    -   v2 - version 2 of the profile language is being used
    -   v3 - version 3 of the profile language is being used, it has some extensions that slight change the semantics of policy.
-   audit - force auditing of all requests, whether allowed or denied. It is this flag is extremely noisy and so forced auditing is usually done via auditing controls on individual rules within a profile.
-   debug (currently unsupported) - turns on extra debug information for tasks confined by the profile.
-   mode flag (deprecated) - the mode flags specify the mode the profile is in and are mutually exclusive. They have been deprecated in favor of [external controls](Controlling_Profile_State) in order to better separate policy and state.
    -   enforce - enforce policy
    -   complain - learning mode, unknown accesses are allowed and logged
    -   debug - output additional debug information when using the profile
    -   kill (first supported in AA2.6?) - log illegal accesses and kill the task doing the access
-   relative flags - The relative flags are mutually exclusive and control how name resolution is handled for the profile. If chroot\_relative is used pathnames are looked up relative to the base of the chroot and names outside of the chroot are determined by the attach flags. The namespace\_relative flag is similar except that names within a chroot are resolved absolute to the namespace with path names out side of the namespace being controlled by the attach flags.
-   attach flags - The attach flags control how disconnected paths are handled.
    -   attach\_disconnect and no\_attach\_disconnected are mutually exclusive and determine if pathnames resolved to be outside of the namespace are attached to the root. ie. have the **/** character prepended. This is generally not considered a good idea as it allows disconnected paths to alias to other files that exist in the file name. It is only provided to work around problems that can arise if delegation is not being used.
    -   chroot\_attach, and chroot\_no\_attach are mutually exclusive and control pathname generation when in a chroot and a file is accessed that is exernal to the chroot but within the namespace. With chroot\_attach disconnected path names are attached to the root of the filesystem (ie. **/** prepended), other wise they are left disconnect.

??? reference to discussion about disconnected paths ???

Examples:

```
 flags=(enforce)
 flags=(complain)
 flags=(enforce debug)
 (complain chroot_relative)
```

#### Profile body

The body of the profile is enclosed inside a pair of curly brackets

```
  { } 
```

contains all the rules governing what is allowed by the profile. The
rules within a profile are declarative (ie order independent)
and cumulative.

The rules within a profile body are separated by either an comma or
a newline.

-   include
-   rlimit rules

**TODO** when are newlines optional, the comma rule separator

#### Rules allowed within a profile body

-   comments
-   include
-   children profile and hats
-   capability rules
-   rlimit rules
-   file rules
-   network rules
-   ipc rules
-   conditional rules enforcement rules (not conditional variable definitions)

#### Rules not allowed with in a profile body

Currently there are a couple rules that are not allowed in the profile body

-   variable definitions
-   alias rules

### Local Profiles and Hats

??? allow local profiles to have a name separate from the attachment
??? allow user conditional on change\_hat names ????

` spec - does not allow namespace`

AppArmor allows for a profile to contain sub-profiles (aka local or
children profiles), that can be used to provide tighter or alternate
confinement for a subtask of an application.

A good use for local profiles is providing specialized confinement
for utility programs launched by a confined application. In previous
versions of AppArmor, if a global profile for the utility didn't
exist or wasn't appropriate then the ix execute mode was the only
choice for providing confinement to the utility application.

This means that utility application has the full privileges of the
parent task which is not always desirable. Local profiles provide an
alternative where the utility applications profile can be customized
for the application that launches it.

Local profiles are specified just like standard profiles except they
are embedded in a profile and the begin with the “profile” keyword.

Example
-------

```
/parent/profile {
  ..
  profile local/profile {
    ..
  }

}
```

Local profiles can specify an attachment, but it will only ever get
used with exec rules that use cx, or named profile transition rules.

Example
-------

```
/parent/profile {
  ..
  profile /bin/grep {
    ..
  }

}
```

#### Hat and Local profile names

AppArmor “hats” are a local profile with some additional
restrictions and an implicit rule allowing for change\_hat to be used
to transition to them. AppArmor “hats” may not contain their own
“hats” but local profiles can contain their own local profiles
and “hats”. Local profiles that are not “hats” and can not
be used with change\_hat without an explicit hat rule.

“Hats” and local profiles are actually just standard profiles
with special names. When a hat or Local profile is loaded, its name
in the logs and as reported by ps -Z is the name of the parent profile
and the name of the local profile separated by '//'.

Example
-------

```
/parent/profile {
  ..
  ^foo {
    ..
  }
  profile local.profile {
    ..
  }
  profile /bin/grep {
  ..
  }

}
```

Will show up as 4 profiles in the loaded profile listing.

```
 /parent/profile
 /parent/profile//foo
 /parent/profile//local.profile
 /parent/profile///bin/grep
```

#### External Local Profiles and Hats

With the knowledge that “hats” and local profiles are just standard
profiles with using a standard naming convention it is possible to
specify local profiles and “hats” external to a profile.

Example
-------

```
/parent/profile {
  ..
  ^foo, # rule allowing change_hat
}

/parent/profile//foo {
      ..
}

/parent/profile//local.profile {
      ..
}

/parent/profile///bin/grep {
      ..
}
```

Notice that for the external profile to function, as a “hat”,
a hat rule must be specified in the profile.

Structural (Meta) Profile Rules
-------------------------------

Structural or Meta rules are rules that in and of themselves do not
grant any permissions. They are not required to write a profile but
they add a layer of abstraction and convenience that makes profiles
easier to write, update, maintain and understand.

### Comments

```
 <comment> ::= '#' .* '\n'
```

Comments can be added at any point within the profile file they
being with the **\#** and the remaining text to the end of the line
is considered a comment. There is one exception \#include (not \#
include) is consider as an include statement as described below.

Valid comment examples:

```
# A comment
    # A comment started a few columns in from the left.
    /foo r, # A comment on the same line as a rule
```

Invalid comments:

```
 #include do something.
```

### Include statements

```
<include> ::= ('#include' | 'include') ('<' <path> '>' | '“' <path with whitespace> '”')
```

Include statements allow a profile file to include another file or
set of files into the profile. The text inclusion is done early as
a preprocessing step, so it is done before all other processing.

The include statement allows specifying the path of the file(s) to
include in either relative to an include path, relative to the current
file being processed or at an absolute position within the file system.

To specify paths relative to the set of include paths, file path
is bracketed within **&lt;** and **&gt;**. The specified path must
not begin with a **/** and it is used to search through all include
paths inorder until the first match is made. For more information
on configuring and specifying include paths see [apparmor\_parser
documentation](Apparmor_parser).

For example:

```
 include <abstractions/base>
```

To specify paths relative to the current file, path is bracketed with
**"** and **"**, and the path does **not** start with **/**, but
it can begin with **../**. When processing includes, if an include
specifies a relative path it will be relative to the include file
being processed not the original profile file. File relative paths
my fail when used in profiles that are passed to the apparmor\_parser
(policy compiler) via stdin (piped in) instead of specified via a file.

For example:

```
 include “somefile”
 include “../file_from_parent_directory”
```

To specify files that are at an absolute position within the
filesystem, the path is bracketed with **"** and **"**, and the path
begins with a **/**.

For example:

```
 include “/etc/apparmor.d/include/foo”
```

#### Directory Include

The include statement can be used to include all the files in a
directory tree if the path specified is a directory. This can be
used to expand a profile by simply adding new profile chunks within
the directory.

The directory include mechanism, skips

-   directories (currently limited to a single level of directory include)
-   dot files, ie. any file starting with the '.' character
-   files ending with any of the following suffixes
    -   .dpkg-new
    -   .dpkg-old
    -   .dpkg-dist
    -   .dpkg-bak
    -   .rpmnew
    -   .rpmsave
    -   ~

Example:

```
 include <abstractions/local/>
```

Notes:

-   the include rule is terminated by the end of the line not by a trailing **,** character
-   directory includes where first supported in AppArmor 2.1
-   The include keyword without the leading **\#** was first supported in AppArmor 2.3

Deprecated:

-   the **\#include** keyword is deprecated in favor of **include** as the former conflicts with the comment syntax.

### Variable definitions

```
 <variable define> ::= '@{'<variable_name>'}' ('='|'+=') <value> (' ' <value>)*
```

**TODO**

-   order doesn't matter
-   list of values
-   ??? recursive definitions
-   currently all statically expanded at compile time
-   plans for dynamic runtime variables
-   where they are allowed and how they are handled in rules is specified in the appropriate rule section

Example:

```
@{CHROOT\_BASE}=/tmp/foo

 /sbin/syslog-ng {
      ...
      # chrooted files
      @{CHROOT_BASE}/var/lib/*/dev/log w,
      @{CHROOT_BASE}/var/log/** w,
      ...
 }
```

AppArmor 2.3 tools support for variables is still limited to not
removing rules containing them, and rules that do contain them will
not be matched by the tools to eliminate log entry questions.

Support for dynamic variables is planned, but as of AppArmor 2.6 all
variables are static. Thus, the @{HOME} variable is just lists all
the possible home locations.

Toolset loads the variable definitions from files located under
/etc/apparmor.d/tunnables/. For example, the @{HOME} variable is
defined in /etc/apparmor.d/tunables/home as follows:

```
 @{HOME}=@{HOMEDIRS}/*/ /root/
 @{HOMEDIRS}=/home/
```

Notes:

-   Variables where introduced in AppArmor 2.1 but they could only exist in include files
-   AppArmor 2.3 extended support of variables for that they could appear in any part of the preamble section or files included by the preamble.
-   Tool support for variables is currently limited

### Conditional statements

TODO hrmmm, do we want to document these at this time?

### Alias and rewrite rules

```
 <alias> ::= 'alias' <path> ('to'|'->') <path>
 <rewrite> ::= 'rewrite' <path> ('to'|'->') <path>
```

Alias rules provide an admin a way to manipulate profile path mappings
to site specific layouts. They are an alternative form of path
rewriting to using variables, and are done post variable resolution.

Example 1
---------

```
alias /home/ -> /mnt/users/
```

intersects the rule

```
  /home/foo rw,
```

resulting in the additional rule

```
  /mnt/users/foo rw,
```

The same will happen for all other rules/parts of rules that intersect
the alias rule. It is important to note that this applies to broad
rules as well.

Example 2
---------

```
alias /home/ -> /mnt/users/
```

intersects the rule

```
  /h** l,
```

resulting in the additional rule

```
/mnt/users/** l,
```

That is only the portion of the rule that intersects what would be
/home/\*\* gains an alias under /mnt/users/

It is important to note that alias does not remove the original rules,
so both path are treated the same in the final policy. The rewrite
differs from the alias rule in that rules that intersect the origin
(/home/ in this case) are removed so that only the target path is
valid in final policy.

Permission Based Profile Rules
------------------------------

### Rule qualifiers

There are several rule qualifiers that can be applied to permission
rules. Some rules do not support all qualifiers, and some qualifiers
are not supported in earlier versions of AppArmor. Qualifiers when
specified modify the rule and possibly permissions with in the rule,
the exact affect of each qualifier is documented in each of the rule
types in the appropriate section.

When qualifiers are supported they must appear in the following order
and certain qualifiers can not be specified with other qualifiers.

```
 <rule qualifier> ::= [('audit'|'quiet')] [('deny'|'kill'|'nokill')] ['owner']
```

When qualifiers are specified they are applied, to the rule per
permission. ??? expand ???

#### only audit

???? qualifier that make the rule not grant permissions but just set
audit flags on rules with permissions

#### quiet

???? clears audit qualifier off of rules. Does it take precedence
over audit like deny over allow???

#### audit

The **audit** keyword is used to specify that permissions requests
that match the rule should be audited (ie a message about the access
recorded to the audit log). Per rule auditing does not override global
or profile auditing modes, but will apply when profiles are in the
normal audit mode.

```
 audit /etc/shadow w,
 /etc/shadow r,
```

this will result in audit messages when **/etc/shadow** is opened
for writing, but not when it is opened for just reading.

It is important to note with audit messages that they are not generated
for every read or write of a file but only when a file is opened for
read or write.

Audit control can be combined with owner conditional file rules to
provide auditing when a user access files they own, but at this time
it can not be used to audit only files they don't own, e.g.:

```
 audit owner /home/*/.ssh/** rw,
```

#### deny

The **deny** keyword is used to add rules that document permissions
that are not allowed by the profile. Deny rules are not strictly
necessary as profiles are a white list, and any permission requests
that do not match a rule within the profile are denied.

The deny rule is used by the profile learning tools to document
permission requests made by a task that were then specifically denied
by the user when creating a profile. This allows the tools to remember
these permission requests in the profile and not prompt the user to
make the decision again if the request is encountered again later.

Deny rules also specifies **noaudit** for the rule so that known
rejects are not logged by default. If auditing of these known rejects
is desired then the **deny** keyword can be combined with the **audit**
keyword.

#### subtracting permissions

Deny rules serve one other purpose, they can be used to remove a set
of permissions from a profile because deny rules take precedence over
allow based rules. This works because deny rules are accumulated like
allow rules but in a separate set, the deny set is the subtracted
from the allow set, to find the final permission set.

This use of deny rules should be avoided when possible and when done
the deny rules should be placed up front at the top of the profile
and not hidden in an include. This is because deny rules can make
profiles harder to read and understand when they overlap allow rules.

#### kill (not currently supported)

The **kill** keyword is used to specify a deny rule that results in
the task being killed when matched.

Note: the kill and nokill qualifiers conflict and will cause policy
compilation if rules that are qualified by them overlap.

#### nokill (not currently supported)

The **nokill** keyword is used to specify a deny rule that will not
kill the task when the rule is matched. It is used to override the
global or per profile kill mode, which if enabled will kill confined
tasks on any AppArmor denial unless the rule causing the denial is
annotated with nokill.

Note: the kill and nokill qualifiers conflict and will cause policy compilation if rules that are qualified by them overlap.

#### qualifier blocks (not currently supported)

Instead of specifying the same rule qualifiers on multiple rules
they can be specified at the head of a block that will then apply
them to each rule embedded in the block. All the rules specified in
the block must be compatible with the qualifiers at the head of the
block. Qualifier blocks can be nested resulting in an accumulation
of qualifiers on the rules with in.

```
 <qualifier> '{' <rules> '}'
```

Example 1
---------

```
 audit {
   /file1 r,
   /file2 w,
 }
```

Example 2
---------

```
 audit {
   /file1 r,
   owner {
     /file2 w,
     /file3 rw,
   }
 }
```

#### conditionals

The permissions granted by a rule can be conditional upon other
factors than the access path.

The positioning of a conditional is important, as it determines which
part of a rule it is applied to

The following are equivalent for a single element rule

```
 owner /foo r,
 owner file /foo r,
 file owner /foo r,
```

when the conditional appears before the rule type it applies to all
elements of a rule, e.g.:

```
 owner link /foo -> /bar,
 link owner /foo -> owner /bar,
```

```
 owner mount option=bind /foo -> /bar,
 mount option=bind owner /foo -> owner /bar,
```

##### owner

```
 'owner' ['='((<user_id>)|('(' <user_id> (' '(<user_id>)* ')')]
 <user_id> : <uid> | <username>
```

The **owner** keyword is used to make the rule conditional on object
ownership. Specifically the task must have the same euid/fsuid as
the object being referenced by the permission check, e.g.:

```
 owner /foo rw,
```

Owner conditional rules accumulate just as regular file rules and
are considered a subset of regular file rules so that if a regular
file rule overlaps with an owner conditional file rule, the resultant
permissions will be that of the regular file rule, since it specifies
permissions regardless of ownership.

For example, given the following rules:

```
 owner /home/*/** rw,
 /home/*/foo rw,
```

The files matched by /home/\*/foo do not have be owned by the user.

It is important to remember with owner rules that, like standard
rules they are just a further restriction of DAC permissions, they
do not grant additional permissions and the file must be accessible
via the DAC permission test before it will be checked against the
profiles permissions.

When using file ownership conditions with link rules the ownership
test is against the target file. This enables forcing openwall style
link restrictions, where to link to a file the user must own the file.

Example
-------

```
owner /** l, # restrict hardlinks to user owned files
```

###### extended ownership tests (not currently supported)

If the optional equal operator is used then, the test is not against
the euid/fsuid but that the object has the same uid as the uid(s)
following the equal sign. For example:

```
 owner=fred
 owner=1001
 owner=(fred)
 owner=(fred george)
 owner=(fred 1001)
```

Notes:

-   If a username is used it is resolved to a uid value at compile time, the username is not loaded into the kernel.

#### fstype

```
 fstype=procfs
```

#### extended conditionals (not currently supported)

```
 'if' <condition> '{' <rules> '}'
```

The owner qualifier is a special short cut for the more generic
conditional operator. - some of its conditions are rule specific

For example `owner /foo r,` is equivalent to
```
 if owner { /foo r, }
```

**TODO**: explain \<condition\> syntax

### Capability rules

The capability rule grants tasks permissions to for any capabilities
currently supported by the Linux kernel (the capabilities are based on
POSIX draft 1003.1e). Capability rules do not grant extra capability
privileges to a task, but serve to mask the tasks, effective
and permitted capability sets. For information on raising tasks
capabilities see the following [guide](Raising_Task_Capabilities).

Capability rules will affect the effective and permitted permissions
seen returned via capget, however they do not change the tasks
capabilities, they are only masked while the task is confined by
the profile. This has two main effects: if the task transitions
to a different profile the set of masked capabilities can change,
and tasks children inherit the tasks permission set, which will be
masked by the profile confining the child task.

```
 [('audit'|'quiet')' '] [('deny'|'kill'|'nokill')' '] 'capability' <cap> [<extended cap>|(' '<cap>)+] ','
```

AppArmor capability rules start with the **capability** keyword
followed by either a single capability with extend information or
multiple capability names separated by a white space and finally
terminated by a comma **,** character. The rule can be prefixed with
any of the rule qualifiers, or may appear in a qualifier block.

The capabilities that are currently supported are:

```
 chown
 dac_override
 dac_read_search
 fowner
 fsetid
 kill
 setgid
 setuid
 setpcap
 linux_immutable
 net_bind_service
 net_broadcast
 net_admin
 net_raw
 ipc_lock
 ipc_owner
 sys_module
 sys_rawio
 sys_chroot
 sys_ptrace
 sys_pacct
 sys_admin
 sys_boot
 sys_nice
 sys_resource
 sys_time
 sys_tty_config
 mknod
 lease
 audit_write
 audit_control
 setfcap
 mac_override
 mac_admin
```

For example:

```
 capability sys_admin,
```

(NOT IMPLEMENTED) Hrmm this needs to be worked out

```
 capability dac_overide (jj smb),
```

Some capabilities can have extended capability specific information
associated with them that further qualifies when the capability
is granted.

-   NOTE currently there are no extended capability qualifiers supported.

**TODO**: doc how do chown rules interact with chown capability etc.

#### Interaction of capability rules with other rules

Having a capability rule does not necessarily grant enough permissions
for an application to perform a given operation. Often the profile
will require both a capability and another access rule. For example
to be able to access file that is not owned by someone else the task
must have the dac\_overide capability and the profile must contain
both a file access rule and capability dac\_override. The capability is
required to over come the standard unix DAC check with its accompanying
capability check, and the file access rule is required by apparmor
to access the file.

NOTES:

-   capability rules do not directly support the owner conditional qualifier (chown and other file rules do).
-   currently only a single capability can be specified per rule.
-   audit, and deny rule qualifiers first appeared in AppArmor 2.3
-   AppArmor qualifiers currently not supported
    -   qualifier blocks
    -   quiet
    -   kill
    -   nokill

### File access rules

```
 <file rule> ::= [<qualifiers>] <path> <permissions> [<x transition>] ','
 <file rule> ::= [<qualifiers>] <permissions> path [<x transition>] ','
 <file rule> ::= <link rule>
 <file rule> ::= <chmod rule> - capability interaction
 <file rule> ::= <chown rule> - capability interaction
 <file rule> ::= <exec rule>
 <file rule> ::= <xattr rule>
```

??? <change_profile rule> ::= 'change\_profile' \['on' <exec name>\] ( 'to' | '-&gt;' ) <profile name> ','

???? trigger rules

```
 <link rule> ::= [<qualifiers>] 'link' ['subset'] <path> ('to'|'->') <path> ','
 <chmod rule> ::= [<qualifiers>] 'chmod' <path> ','  ??? mode
 <chown rule> ::= [<qualifiers>] 'chown' <path> 'to' (<owner spec> | <group spec>) [<owner spec> | <group spec>]
 <owner spec> ::= 'owner=' ( <uid>|<username>|'(' (<uid>|<username>)+ ')' )
 <group spec> ::= 'group=' ( <gid>|groupname>|'(' (<gid>|<groupname>)+ ')' )
```

File access rules control which files and the operations that are
allowed on them. There are several forms of file rules, some are
generic and some provide specific forms that allow specifying more
information.

audit, quiet, deny, kill, nokill? owner and conditional

pattern matching - delegation - lazy evaluation (labeling) - replacement

#### File permissions

```
 <permission> ::= <short form> | <long form perm> | '(' <long form perm>+ ')'
 <short form> ::= [rwalkmx]+
```

AppArmor file permissions have two forms, the short abbreviated course
grained form, and a longer fine grained form. The abbreviated form is
what is usually used and the permissions map to a set of longer fine
grained permissions. The short form permissions can be represented
by a single letter or by a name, while the fine grained form can
only be represented by a name. Short and long form permissions can
be mixed on a single rule by separating them by spaces, just as long
form permissions are separated.

Short form permissions

-   r - read - permission to read data
-   w - write - permission to create, delete, write to a file and extend it
-   a - append - permission to create, and extend a file. The append permission is limited that it only gives permission for applications to open a file with O\_APPEND, it can not be used to enforce a generic file write is append only. If an application only has the append permission in the profile and it tries to write to the file even if it is an appending write, the write will be failed.
-   l - link - permission to link to a file (combined with /\*\* to determine if permissions apply to subtree)
-   k - lock - permission to lock a file, is combined with write perm to determine if it has permission to take exclusive lock
-   m - memory map executable - permission to memory map a file executable
-   x - executable - determines if a file is executable, allow forms of the rule must be accompanied by x qualifiers. When specified as part of an allow rule it must be accompanied by qualifiers.

Long form permissions (not currently exposed/supported)

-   create - permission to create a file
-   open - permission to open a file
-   delete - permission to delete a file
-   rename - a special rename permission that allows moving a file without being able to read/write the file data.
-   read - permission to read a files contents
-   getattr - permissions to read a files meta data (attributes)
-   getxattr - permissions to read extend attributes
-   write - permission to write data to a file, including extending the file (implies append)
-   append - permission to append new data to the file (extending the file size), no data overwrite. Must be used in conjunction with application opening the file with O\_APPEND, otherwise the file open will fail
-   trunc - permission to truncate (shorten the file)
-   setattr - permission to write a subset of the files meta-data not controlled by specialized flags
-   setxattr - permission to write extended attributes
-   chmod - permission to change DAC file permissions on the file
-   chown - permission to change file owner
-   chgrp - permission to change file group
-   link - permission to link to the file, when used with \*\* determines if permissions apply to an entire subtree
-   snapshot - permission to snapshot a file or directory
-   lock - permission to lock a file, combines with ???append || ???write to take exclusive lock
-   mmap\_r - mmap a file readable
-   mmap\_w - mmap a file writable
-   mmap\_x - mmap a file executable
-   mprot\_wx - allow transitioning an mmap from w to x, (this sticks for the lifetime of the mmap even if w is removed before trying to apply x
-   mprot\_xw - allow transitioning an mmap that was granted x permissions to having w permissions.
-   exec - permission to execute a file

<!-- -->

-   change\_profile -
-   onexec - permission to take change\_profile at exec time, overriding exec transitions, this is specified as part of a change\_profile rule and can not be specified as part of a standard file rule

Short form permissions map to

`r - read, meta-read, mmap_r`
`w - create, delete, trunc, write, meta-write, chmod, chown, mmap_w, mprot_wx, partial rename (where it implies partial source rename permissions and full destination renamed permission)`
`a - append, create`
`l - link (may be combined with other permissions to determine if allowed)`
`k - lock (combines with ???write to determine if exclusive lock is allowed)`
`m - mmap_x, mprot_wx`
`x - exec, (if ix then also mmap_x)`

##### Directory Traversal

AppArmor does not control permission to traverse directories (In DAC
x permission on a directory). This ability is implicitly granted but
can still be control by DAC.

directory traversal is implicit

##### Sub-tree Permission (not supported yet)

When a permission is specified with a rule that ends with the pattern /\*\*, it grants the specified permission to all files and directories within the sub-tree and it also grants those permissions for operations on the sub-tree. This is used to determine whether a directory can be moved, or a snapshot can be made.

For example:

```
   /home/** rw,
```

grants permission to access all files and directories below /home/ but
also marks /home/ as having these permissions for its sub-tree. This
allows for permission decisions to made for entire trees.

Notes:

-   First supported in AppArmor 2.6 ???

##### Trigger profile change (not supported yet)

Basic file rules can have a change\_profile on access rule, which
will cause a tasks profile to be transitioned when the tasks accesses
the resource. This allows writing a policy that changes based on
which resources are accessed. The profile change is subject to all
the limitations ???insert link to change\_profile discussion??? of
a change\_profile call.

An x transition trigger is written similar to an exec named transition

```
 rw /path -> profile

 rw /path : label -> <profile> ','
```

syntax needs to be nailed down should we allow specifying a trigger
on combined with an x rule

subject to same collisions that x rules are subject to.

transition is stored for each permission

##### logging permissions, and how they are different

?????

#### Rename Rules (not currently supported)

```
 <rename> ::=  'rename' <path> ('to'|'->' <path> ','
```

The rename rule provides permissions to rename a specific set of paths
without requiring read or write permissions on a file. The rename
rule and permission is not required to do file renames, as renames
are allowed as long as the profile has sufficient permissions on the
source and destination files (ie the source must be able to be read and
deleted and the destination must be able to be created and written to).

For example:

```
 rename /tmp/* to /home/* ,
```

#### Link Rules

```
 <link> ::= 'link' <path> [('to'|'->') <path> ','
            'l' <path> [('to'|'->') <path> ','
            <path> 'l' ','
```

The permission to link to a file (create a name alias) is controlled
by the link permission and it can be specified in two different ways.

The **l** permission can be combined with other file permissions in a
single rule. This form of the link rule states that the specified path
can be a link, and that it can be linked to any other file as long
as access to the file is allowed by the profile and the permissions
for the target file are a subset of the permission specified by the
profile for the link file.

Examples:

```
 /link/file l,
 l /link/file,
```

The alternate form of the link rule is used to specify a link and
target pair. It starts with the **link** keyword followed by an
optional subset qualifier then the link path, the **to** keyword and
then the target path, which is then terminated with a **,** character.

```
 'link' ['subset'] <link file path> ' ' ('to'|'->') ' ' <target file path> ','
  link /link/file to /target/file,
 link subset /link/file to /target/*,
```

The subset qualifier when used specifies that the target/file must have
a subset of permissions of the link file as specified by the profile.

The link permission when written using the **l** permission character
is equivalent to the following link pair rule

```
 link subset /path -> /**,
```

thus, the rule

```
 /link/name rwl,
```

is equivalent to

```
 link subset /link/name -> /**,
 /path/name  rw,
```

Note:

-   The use of the **-&gt;** symbol is deprecated in favor of the **to** keyword, but **to** is not recognized by the AppArmor 2.3 - 2.5 compiler.
-   The link pair rule is available in AppArmor 2.3 and later
-   currently link pair rules are not supported by the tools but they will not be stripped so it is safe to update profiles containing them.

##### Directory links and snapshoting (not supported yet)

For filesystems that support them link permission is also used to
control whether a snapshot of a file or directory can be made. This
is done by specifying the link and target names are directories

```
 /dir/ l,
 link /dir/ to /target/
 link /dir/ to /**/
```

Because links to directories and snapshots provide alternate paths to
a tree of files it is important to control permissions properly. It
is recommended that the subset qualifier is always used on rules
allowing links and snapshots to directories, and that link location
have ???recursive permissions defined.

This will ensure that from the profile pov the user has the same
permissions on the new tree as on the target tree, which avoids
potential attacks that widen permissions.

#### Chmod and Chown Rules

The rules governing chmod and chown both have forms that can specify
a path. For further information on them see ?????.

#### Execute rules

```
 ('safe' | 'unsafe') <path> <qualifier>'x' [[' ->' <profile name>] ['+' <profile name>]] ','
 ('safe' | 'unsafe') <perm>: <x qualifier>'x' [[' ->' <profile name>] ['+' <profile name]] ','
```

??? how do qualifiers work with long form permissions

```
 <path> 'x' '->' <profile list> ',' (not yet supported)
```

Exec rules control profile (domain) transitions when an application
execs into another tasks. The basics of profile transitions are quite
simple but ???complicated semantics???

Unconfined tasks determine their domain transitions using

```
 /** Px
```

Qualifiers

-   p - exec to profile that matches executable name, no environment variable scrubbing
-   P - exec to profile that matches executable name, with environment variable scrubbing
-   c - exec to child profile that matches executable name, no environment variable scrubbing
-   C - exec to child profile that matches executable name, with environment variable scrubbing
-   u - exec to unconfined, no environment variable scrubbing (VERY DANGEROUS)
-   U - exec to unconfined, with environment variable scrubbing
-   i - inherit current confinement

Combining qualifiers inheritance and unconfined fallbacks

-   pix
-   Pix
-   cix
-   Cix
-   pux
-   PUx
-   cux
-   CUx

NOTE:

-   pux, PUx, cux, CUx first available in AppArmor 2.5
-   cx, Cx, pix, Pix, cix, CUx first available in AppArmor 2.3
-   For historical reasons, apparmor\_parser also accepts “mixed case” Pux, Cux, pUx and cUx. This is deprecated syntax, confusing (you won't get the behaviour you'd expect with mixed case - for example Pux is equivalent to PUx) and not supported by aa-logprof.

##### Environment variable scrubbing

**TODO**: safe/unsafe ix vs m named transitions namespaces recommended
that x be specified as its own rule and not combined with others
stacking profiles

```
 /program ix + <profile>
 /program px + <profile>
 /program pix -> <profile> + <profile>
```

domain hierarchies - virt profiles, hat struct to represent transitions(tomoyo style)????

???? change\_profile trigger rules ???? /foo w -&gt; <profile>

AppArmor 2.3 has some new options for execute permissions. In addition
to the ix, ux, and px permissions present in AppArmor 2.1, there is
a new cx permission, as well as the ability to specify a profile
to transition to. Additionally each of these can be offered in an
inherit fall back mode.

##### New transition mode cx

The new cx permission is like px except it specifies a transition to
a child (also known as local) profile. Just as with px, cx specifies
transitioning to a profile who's name matches the executable, except
instead of searching the global profile set, only the local profiles
of the current profile are search.

The cx profile transition combines with local profiles providing
a way for an application to have alternate profiles for helper
applications. For example a text based mail viewer could have a
profile for /bin/grep, which the system doesn't confine by default.

The cx transition provides an alternative to using ix for utilities,
providing the possibility of achieving tighter confinement.

Example:

```
/usr/bin/mutt {
  ..
  /bin/grep cx,
  profile /bin/grep {
    ..
  }

}
```

As with the ux and px profile transition modes, cx comes in both
safe and unsafe variants. Cx is “safe” and has glibc sanitize
the environment variables, while cx does not sanitize the environment
variables.

##### Named (specified) profile transitions

In addition to the cx transition mode AppArmor 2.3 adds the ability
to specify exactly which profile will be transitioned to. This can
be useful if multiple binaries should share a single profile, or if
they should use a different profile than there name would specify.

Named profile transitions use -&gt; to indicate the name of the profile that should be transitioned to.

Example:

```
/usr/bin/mutt {
  ..
  /bin/** px -> shared_profile,
}
```

The px in the rule indicates the transition will look for the profile
in the global scope. If a cx is used the transition searches for a
local profile.

Example:

```
/usr/bin/mutt {
  ..
  /bin/** px -> shared_profile,

  /usr/*bash cx -> /bin/bash,
  profile /bin/bash {
    ..
  }
}
```

Using cx in a named profile transition is a convenience and is
equivalent to specifying px with the parent profile name properly
prepended. ie. the cx line from the above example is equivalent to

```
 /usr/*bash px -> /usr/bin/mutt///bin/bash,
```

There is an implementation specific limit on how many named profile
transitions can be specified in a profile. The limit in AppArmor 2.3
is 12.

##### Globbing with px/cx and named profile transitions

The px/cx execute permissions use the executable name to specify
which profile to transition to, so when they are used with globbing
they can specify many different profile transitions.

i.e. `/bin/** px,` will transition to /bin/ping, /bin/cat, ... depending on the program being run.

Named profile transitions when combined with globbing provide a many
to one transition. ie. All programs that match the rule regardless
of their name will transition to the specified profile.

When globbing is not used, a px transition is equivalent to a named
profile transition to the file rule pathname.

In other words

```
 /bin/ping px,
```

is equivalent to

```
 /bin/ping px -> /bin/ping,
```

##### Profile transitions and inheritance fall back

The px, cx, and named profile transitions specify a hard dependency, in
that if the specified profile does not exist, the exec will be failed.

AppArmor 2.3 introduces the ability to have an inheritance fall back
so that instead of the program execution failing, it will succeed but
inherit the current profile. This allows for a soft profile dependency,
which allows for gradual or partial profile deployment.

To specify inheritance fall back ix is combined with px, cx into
the pix and cix modes. The pix and cix modes can be used with named
profile transition to provide inheritance fallback as well. The pix
and cix modes like px, and cx have safe and unsafe versions.

### Mount rules (AppArmor 2.8 and later)

AppArmor supports mediation of filesystem mounts. AppArmor mount rule
syntax uses elements of the Linux mount syntax but differs somewhat
due to the complexities of the mount syntax. AppArmor mount rules is
capable of expressing all mount options.

The general mount syntax is

```
 <mnt_rule> ::= ['audit'] ['deny'] ['owner'] 'mount' <conds>* [<source>] [ -> <conds>* <mntpnt>],
 <mnt_rule> ::= ['audit'] ['deny'] remount <conds>* [<mntpnt>],
 <mnt_rule> ::= ['audit'] ['deny'] umount <conds>* [<mntpnt>],
 <mnt_rule> ::= ['audit'] ['deny'] pivot_root [<oldpath>] [<mntpnt>] [ -> <profile>],

 <conds> ::= ('fstype'|'vfstype') <cond_op> <expr>
 <conds> ::= 'options' <cond_op> <expr>
 <conds> ::= 'owner' [<cond_op> <expr>]  (NOTE: not supported in AppArmor 2.8)

 <cond_op> ::= ('=' | 'in')

 <expr> ::= (<re> | '(' (<re>[,])+ ')')
```

Note: conditions on the '''<mntpnt>''' (dest) are not supported in AppArmor 2.8.

Note: leading (before the mount keyword) '''owner''' option applies
the owner condition to both \<source\> (device) and destination path
(mntpnt). It is not supported in AppArmor 2.8

Note: AppArmor 2.8 contains a bug
(https://bugs.launchpad.net/apparmor/+bug/965690), which
prevents fs specific options from being matched in regular
expressions. Specifically, `options=**` will not match any fs specific
options.

Mount rules must contain one of the mount, remount, umount
or pivot\_root keywords, but all mount conditions are
optional. Unspecified optional conditionals are assumed to
match all entries (eg, not specifying fstype means all fstypes are
matched). However if a condition is specified then the rule only grants
permission for mounts matching the specified pattern. The more parts
of a rule specified the more specific the match becomes.

The simplest rule is also the most generic:

```
  mount,                                # allow any mount
```

which is equivalent to:

```
  mount fstype==** options=** **-> /**,
```

The fstype, options, source and mntpnt components all support the
apparmor globbing syntax (see note about options and pattern matching
in AppArmor 2.8).

Examples:

```
  mount /dev/foo,                       # allow mounting of /dev/foo anywhere
  mount options=ro /dev/foo,                    # allow mounting /dev/foo as read only
  mount options=(ro,foo) /dev/foo,
  mount options=ro options=foo /dev/foo,
  mount -> /mnt/**, # allow any mount on dirs under /mnt/
  mount options=ro -> /mnt/**, # allow any read only mount under /mnt/
  mount fstype=overlayfs options=(rw,upperdir=/tmp/upper/,lowerdir=/) overlay -> /mnt/
```

#### Permission accumulation

Like apparmor file rules mount rules accumulate permissions on a given
path, however it is important to note what permission is accumulating
and what the path is.  Mount rules provide 3 broad permissions:
mount, unmount, and pivot\_root, the rest of the information in a mount
rule is access path and conditional information determining when the
permission can be applied.

This means that for the following two rules, while the mount permission
is accumulated the options are not:

The following two rules

```
  mount options=ro,
  mount options=nodev,
```

are **not** equivalent to

```
  mount options=(ro, nodev),
```

but are equivalent too

```
  mount options=ro options=nodev,
```

#### Multi-valued (set) vs. Single valued conditionals

The mount rules options condition is special in that it specifies an
ordered set of values that can have multiple values selected at once;
not a list of values like is done for most rule conditionals. In
apparmor 2.8 there is unfortunately no syntactic difference between
the two types (list vs. set).

For example:

```
  options=(ro, nouser)   # set of values. Multiple values can be valid simultaneously
  fstype=(ext3, btrfs)   # list of value. Only a single value can be valid at a time
```

#### Multiple vs. Single rule

Like all AppArmor rules, mount rules are declarative which means that
rule order does not matter. The exception is that deny rules always
take precedence over allow rules, removing granted permissions when
necessary.

Due to the complexity and flexibility of the Linux mount syntax itself,
it is often possible to specify a particular mount restriction in
multiple ways: in a single rule using pattern matching, with list
elements, or across multiple rules. Generally the form chosen should
be the one that is easiest to understand, policy compilation reduces
the author's policy to be as compact and efficient as possible so using
one rule vs. two or a regular expression should not change the results.

For example:

```
  mount fstype=(ext3,ext4),
```

is equivalent to

```
  mount fstype=ext3,
  mount fstype=ext4,
```


When splitting the parameters of the \<option\> conditionals, care
must be taken since it is multi-valued and treats the '''=''' and
'''in''' conditional operators differently; e.g.:

```
  options=(ro, acl)
```

is **not** equivalent to (see the options section for more details):

```
  options=ro
  options=acl
```

#### \<source\> (device path)

The \<source\> element can be a path or any other value. It matches against the device spec of a mount command.

In the command:

```
  mount /dev/sda1 /mnt
```

\<source\> matches against **/dev/sda1**.

In the command:

```
  mount -t overlayfs -o rw,upperdir=/tmp/upper,lowerdir=/ none /mnt
```

\<source\> matches against **none**.

In the command:

```
  mount --bind /home /mnt
```

\<source\> matches against **/home**
 

#### \<fstype\>

The fstype is an optional element that can be used to match against
a device's file type. It is a single valued option such that:

  `fstype=ext4` == `fstype=(ext4)` == `fstype in (ext4)`

and:

  `fstype=(ext3, ext4)` == `fstype in (ext3, ext4)`

In other words, fstype will match against any one value in the supplied
list and each element in the supplied list can be a pattern match; e.g.:

```
 fstype=(ext?, aufs, devfs)
```

Note: In AppArmor 2.8 the fstype may not be matched against when
certain mount command flags are used. Specifically fstype matching
currently only works when creating a new mount and not remount,
bind, etc.

#### destination (\<mntpnt\>)

The \<mntpnt\> is the location of the mounted device or filesystem will
be after it is mounted. It must always be a valid path and should
usually end with a **/** character in policy. The **-&gt;** must always
be specified before the destination \<mntpnt\> is specified. If **-&gt;**
is not specified any path will be interpreted as a \<source\> path
or the parser will throw an error during compilation. Eg:

```
  mount -> /,                  # mount on root
  mount -> /**,                # mount any where below root
  mount -> /{**,},             # mount on or below root

  mount -> /**/,               # mount on only directories below root
  mount -> /**[^/],            # mount on only files below root
```

If the destination \<mntpnt\> location supports both files and
directories then use either a trailing \*\* pattern match, alternation
{/,}, or separate mount rules.

Note: AppArmor 2.8 does not support conditionals on the destination \<mntpnt\>.

#### \<options\> and flags

The \<options\> element is a multi-valued (set) option that
covers two distinct types of options: mount flags and fs specific
options. Being a multi-valued option it treats the **=** and **in**
operators differently and also treats the two types differently when
performing matching.

The mount flags are a preset list of values that are generic to all
mount commands, while the fs specific options are anything else that
can be specified. Because the generic mount flags and fs specific
options are handled slightly differently, it is important to know
the differences.

The **=** operator specifies that the rule only grants permission
for mounts matching the exactly specified options. For example,
an AppArmor policy with the following rule:

```
  mount options=ro,
```

allows mount operations that only specify the ro flag (e.g, `mount -o ro /dev/foo /mnt`).

While:

```
 mount options=(ro, nodev),
```

only matches if the mount uses both the ro and nodev flags and no others (e.g. `mount -o ro,nodev /dev/foo /mnt`).

The **in** conditional operator allows options to be any or all of
the listed values (a subset of the values). In other words, if a
conditional is specified using 'in', then the rule grants permission
for mounts matching any combination of the specified options. For
example:

```
 mount options in (ro, nodev),
```

is equivalent to

```
  mount options=ro,
  mount options=nodev,
  mount options=(ro, nodev),
``` 

NOTE: While the order that the flags are specified in a rule does not
matter, in AppArmor 2.8 the order of fs specific options does matter.

NOTE: Due to limitations in the Linux kernel, there is currently no way
to have 'options in (ro,nodev)' to mean only 'ro' is set, or 'nodev'
is set or 'ro and nodev are set'. Instead 'options in (ro,nodev)'
means 'any combination of the specified option and its inverse can be
set' such that 'options in (ro,nodev)' == 'options in (rw,nodev)' ==
'options in (ro,dev)' == 'options in (rw,dev)'.

##### specifying options multiple times

The options conditional may be specified multiple times within a
section of the mount rule which can aid in logically breaking up a
conditional and provides flexibility to switch between **=** and **in**
conditional operators. As long as the conditional operators are the
same, the specified options can be split and combined interchangeably.

The following are all equivalent

```
mount options=(ro, nodev)
mount options=(ro) options=(nodev)
```

```
mount options=(ro, nodev, upperdir=/tmp/upper, lowerdir=/)
mount options=(ro) options=(nodev) options=(upperdir=/tmp/upper) options=(lowerdir=/)
```

```
mount options in (ro, nodev, user)
mount options in (ro) options in (nodev, user)
mount options in (ro nodev) options in (user)
mount options in (ro) options in (nodev) options in (user)
```

When both **=** and **in** conditional operators are used the options
within each condition type can be combined and split interchangeably.

```
mount options=(ro, acl) options in (nodev, user)
mount options=(ro) options=(acl) options in (nodev) options in (user)
```

It is important to note that allow rule **in** options can also be
encoded using **=** and both the positive and negative forms of a flag:

```
mount options=(ro, acl) options in (nodev, user)
mount options=(ro, acl, dev, nodev, user, nouser)
```

but this is discouraged because it is harder to understand, the
negative form must be known to exist (not all flags have a negative
form), this form does not directly apply to deny rules because of
the inversion that the deny operator applies.

##### mount flags

Mount flags are a predetermined set of values that are common to
all mount commands, and they are separated out from the fs specific
options. The apparmor option names are based on those used by the
mount command. If the mount command supplies both a flag and option
value then both are available to be used in apparmor mount rules.

As an example, the mount command allows the read only flag to
specified as

```
 mount o=ro
 mount -r
 mount --read-only
```

All variants are available to the apparmor mount rule (without the
leading '-' or '--').

The generic mount flags are split into two type generic flags and
the mount command flags have no negative form.

| Positive form    | Negative form | notes |
|------------------|---------------|-------|
| ro, r, read-only | rw, w         |
| suid             | nosuid        |
| dev              | nodev         |
| exec             | noexec        |
| sync             | async         |
| mand             | nomand        |
| dirsync          |
| atime            | noatime       |
| diratime         | nodiratime    |
| acl              | noacl         |
| relatime         | norelatime    |
| iversion         | noiversion    |
| strictatime      |
| user             | nouser        |

| command          | equivalent to                    |
|------------------|----------------------------------|
| remount          |
| bind, B          |
| move, M          |
| rbind, R         |
| make-unbindable  |
| make-private     |
| make-slave       |
| make-shared      |
| make-runbindable | options=(make-unbindable, rbind) |
| make-rprivate    | options=(make-private, rbind)    |
| make-rslave      | options=(make-slave, rbind)      |
| make-rshared     | options=(make-shared, rbind)     |

Any other options that are specified are treated as fs specific
options. For example, the rule:

```
 mount fstype=overlayfs options=(ro,uppderdir=/tmp/upper,lowerdir=/),
```

could be rewritten in an equivalent form with the generic options
and fs specific options separated like so:

```
 mount fstype=overlayfs options=ro options=(upperdir=/tmp/upper,lowerdir=/),
```

Note: the flags portion of a pattern match is not properly handled
in AppArmor 2.8.

##### fs specific options

As noted above, fs specific options are any options that remain after
the generic mount flags have been removed, and they are special in
a few ways.

-   AppArmor does not know the set of options supported by any given filesystem so anything that does not match a mount flag is passed through as an option. This means typos in mount flags are treated as an fs specific option
-   In AppArmor 2.8 the order of the fs specific options matters. They must be specified in the same order that the user enters them
-   Pattern matching can be used and is currently completely separated from the fs flags (ie this known bug means they don't match against patterns).
-   Options must be entered the exact same as the user enters them in the mount command. Mediation is done before the filesystem parses the options and converts them into filesystem objects. This means that if a file system specific option specifies a directory but the user does not specify a trailing '/', then the fs specific option should not either.

For example. if the user uses the following command

```
 mount -t overlayfs -o rw,uppderdir=/tmp/upper,lowerdir=/ none /mnt
```

then the apparmor mount command must specify the fs specific options
the same way:

```
 options=(upperdir=/tmp/upper,lowerdir=/),
```

notice that **/tmp/upper** does not have a trailing **/**, this is
contrary to how apparmor matches against directories for other rules.

In general it is recommended that when specifying fs specific options
that should match a directory to use pattern matching so the rule
will work regardless of whether the user includes a trailing / in
their mount command:

```
 options=(“upperdir=/tmp/upper{/,}”,lowerdir=/),
```

##### deny

TODO

#### directories and files (trailing /)

Because AppArmor differentiates between directories and files, it is
important in apparmor rules to makes sure that specified path elements
have a trailing **/** if they are to match directory objects. However,
the mount command does not always specify elements that match up to an
actual object in the filesystem. An example is when the \<source\>
element specifies **none**, there is no device or path associated
with the mount.

Of particular note is fs options specified in the options field
must match exactly as specified otherwise they may not resolve to a
filesystem object.

Note: currently flags can not be extracted from or matched to
regular expressions, and must be manually specified. See [Bug
\#965690](https://bugs.launchpad.net/bugs/965690).

#### remount

The remount rule is just a convenience rule that maps to the mount rule

```
 mount options=remount -> <conds>* [<mntpnt>],
```

#### umount

The umount rule gives permission to unmount a specified mount point. In
AppArmor 2.8, the umount rule does not support any conditionals.

#### pivot\_root

```
pivot_root [oldroot=<value>] [<path>] [-> <profile>]
```

The pivot\_root rule gives permission to pivot the root of the
filesystem (see man pivot\_root). It should not be granted unless it
is required because it allows changing the visibility of all paths
for tasks within the filesystem namespace. This changes the meaning
of all profile path rules, which can lead to aliasing and confusion.

The pivot\_root rule provides a means to change\_profile \[-&gt;
\<profile>\] and even the namespace when a pivot\_root is done,
but this has several caveats:

-   It can only be done against the task doing the pivot\_root; other tasks in the namespace will NOT be updated
-   The changed profile must be written with the changed filesystem view in mind which can result in disconnected paths for files that where opened under the old view.
-   It results in revalidation of some files under the new path names.

### Chmod rules

```
 <chmod> ::= <path> <perms + chmod> ','
             'chmod' <perm_mask> [<path>] ','
 <perm_mask> ::= (####| rwxrwxrwx)
```

The chmod permission allows controlling which DAC permissions can be
changed by specifying a mask. If a path is specified the permission
mask only applies to files but it can be applied to all objects
(eg. sockets) if no path is specified.

When chmod is specified without a mask it is assumed the mask is 7777?

Example:

```
 chmod 777,  # allow chmoding all files and sockets.
 chmod 777 /home/**,  # allow chmoding files in home
 deny chmod 0222,
```

```
 /path (rw chmod),  # mask /path with 
```

how to specify none file objects and not include files? Should not
specifying the path only apply to non path based objects? Maybe

so chmod 777, would not apply to files then

### Chown rules

setuid and sticky bits

### Setuid rules

requires capability setuid

```
 setuid -> fred,
 setuid -> (fred, george)
```

2 options:

-   setuid rule embedded within the cap making it a limited cap
-   `capability setuid (fred, george),`  remains backwards compat

setuid binaries fscap binaries

### Network rules

AppArmor 2.3 - AppArmor 2.6`

```
 <rule qualifier> ::= [('audit'|'quiet')] [('deny'')]
 <rule> ::= [ <rule qualifier> ] 'network' [ <domain> ] (<type> | <protocol)
```

AppArmor 3.0

```
 <rule qualifier> ::= [('audit'|'quiet')] [('deny'|'kill'|'nokill')]
 <rule> ::= [ <rule qualifier> ] 'network' [ <permissions> ] [ <domain> ] [ <type> ] [ <protocol> [ <address_expr> ] ] [ delegate ]','
```
  
???? Finish out permissions, network labeling, connection tracking ????

AppArmor network rules provide a flexible profile centric approach
to creating a firewall. The network rules are flexible in that they
provide both control over creation of sockets, flow of data (packets),
and can stand alone or be integrated with the system firewall.

The majority of the rule components are optional, with the fewer
components specified making the rule more generic. The most generic
networking rules are:

```
 network,        # allow all networking
 deny network,   # disallow all networking
```

The rule qualifiers modify network rules in the same manner that
they are applied to file rules, ie. denied rules take precedence over
allow rules and will both subtract permissions and quiet auditing.

#### network permissions

```
 <permissions> = 'create' 'accept' 'bind' 'connect' 'listen' 'read' 'write'
                 'send' 'receive' 'getsockname' 'getpeername' 'getsockopt'
                 'setsockopt' 'fcntl' 'ioctl' 'shutdown' 'getpeersec'
```

The permissions specify what operations are allowed on the network
socket, and also are used to determine semantically what other parts
of the network rule are allowed, and how they apply. If the permission
set is not specified the full set is implicitly granted. For example:

```
 network inet,
```

will grant all permissions for sockets in the inet domain. If the
full wide permission set is not desired then the desired permissions
can be specified, or a deny rule can be used to subtract a certain
permissions from another rule.

```
 network (read, write) inet,
 deny network bind inet,
```

-   create - permission to create a socket of the domain, type, protocol specified.
-   shutdown - permission to shutdown the socket.
-   listen\[=X\] - permission to listen on a socket of the domain, type, protocol specified. If the optional backlog parameter is specified it limits the maximum size that can be pasted to listen.
-   bind - permission to bind to an address that matches the source address expression. If no source address is specified it will bind to any address.
-   connect - permission to connect the socket to an address that matches the dest address expression. If the destination address is not specified it can connect to any address.
-   accept - permission to accept connections from an address that matches the dest address expression. If the desitionation address is not specified connections from any address may be accepted.
-   read/receive - permission to read/receive packets and data from the dest address on the source address
-   write/send - permission to write/send packets and data from the source the source address to the dest address
-   getname - permission to get the lock name (address) of the socket
-   getpeer - permission to get the remote address (name) of the socket
-   setopt - permission to set socket options

#### domain

```
 <domain> ::= 'inet' | 'ax25' | 'ipx' | 'appletalk' | 'netrom' | 'bridge' | 'atmpvc" |
              'x25' | 'inet6' | 'rose' | 'netbeui' | 'security' | 'key' | 'packet' | 'ash' |
              'econet' | 'atmsvc' | 'sna' | 'irda' | 'pppox' | 'wanpipe' | 'bluetooth'
```

The actual set of domain names is growing and ??? should be consulted
for a complete updated list

In some cases the domain does not need to be specified and it is
implied by the type, protocol, or addressing.

Examples:

```
 network tcp,
```

implies

```
 network inet stream,
 network inet6 stream,
```

#### type

```
 <type> ::= 'stream' | 'dgram' | 'seqpacket' | 'raw' | 'rdm' | 'packet' | 'dccp'
```

The allowed types for a network are the same as used in the **socket**
system call. And what is supported can vary depending by the domain
(a domain does not have to implement them all, eg. inet does not
implement seqpacket).

Some types may require permission other than the network rule. For
example the 'raw' type will also require the cap\_raw capability.

In some cases the type does not need to be specified as it is implied
by the protocol and or addressing. When this happens the rule matches
all types implied by the protocol and or addressing.

For example:

```
 network inet tcp,
```

implies

```
 network inet stream,
```

The exact mappings will depend on what is supported by the apparmor
tools. Please see ??? for more details.

#### protocol

```
<protocol> := 'tcp' | 'udp' | 'icmp' | ..
```

The protocols that can appear in a rule will be dependent on the
domain and types of the rules as well as the current set of protocolos
understood by AppArmor. The known protocols can be used to imply
domain and type.

#### address expr

```
<address_expr> ::= [('source'|'src') <domain_addr> ['on' <iface>]] [('destination'|'dst' <domain_addr>]
<domain_addr> ::= (<ipv4_addr> | <ipv6_addr> | ..)
```

The address expression is dependent on the domain of the
socket. Generic rules that cover more than a single domain may not even
be able to contain an address expression, in these cases if an address
expression is needed the rule should be broken up into multiple rules.

```
 network tcp src 192.168.1.1:80 dst 170.1.1.0:80,
```

##### ipv4 address expressions

```
 <ipv4_addr> ::= [<ipv4_??>['/'(<ipv_??>|<num>)]][':'<ports>]
 <ipv4_??> ::= <??_expr>'.'<??_expr>'.'<??_expr>'.'<??_expr>
 <??_expr> ::= (<num>|<range>|'*')
 <ports> ::= (<num>|<range>)(','<num>|<range>])*
 <range> ::= <num> '-' <num>
```

?? Examples

```
 192.168.1.1
 192.168.1.1-254
 192.168.1.1:80
 192.168.1.1:80,81
 192.168.1.1:80,81,100-200
```

The following ipv4 address expressions are equivalent

```
 192.168.1.*
 192.168.1.0-255
 192.168.1.0/24
 192.168.1.0/255.255.255.0
```
 
the masking and ranging can also be specified for internal ???

```
 192.0-255.1.1
 192.*.1.1
 192.0.1.1/255.0.255.255
```

##### address masks

```
 192.168.1.1/24
 192.168.1.1/255.255.0.0
```

ranges?

```
 192.168.1.0-192.168.12.255
```

regexes?

```
 192.168.*.*
 192.168.**
```

port ranges

```
 192.168.1.1:80-85
```

hrmm how to specify addresses? Masking, allow full regexs, address
ranges

#### Integrating with system fire falls

The implementation of AppArmor network rules is broken into three
parts, the mediation of sockets, the labeling of packets, and the
mediation of packets. When AppArmor compiles policy it splits network
rules into these three separate parts.

The mediation of sockets, and packets is handled entirely within the
AppArmor mediation engine, the labeling of packets is however handled
by linux's iptables using secmark and connsecmark.

By default AppArmor will create an iptable with the appropriate
labeling for AppArmor policy from the set of system network rules, so
that policy does not need to be split between iptables and AppArmor
profiles. However there is nothing stopping a user from handling
labeling in iptables.

??? need to let apparmor know that the reserved labels exist ??? need
to write rules that use the labels, most likely ipc rules

#### Note: about AppArmor 2.3 - 2.6 network rules

The network rules for the earlier versions of AppArmor are semantically
and syntactically compatible, they just have fewer options available.

The permission set is always implied to be the full permission
set as is the case with AppArmor 3.0 rules when permissions are not
specified. Also the protocol can only be expressed if the type isn't;
eg. it is not possible to specify **network inet raw tcp,**. The
protocol is only used in its convenience form to imply the type,
ie. **network inet tcp,** implies **network inet stream,**.

There is one semantic change, in AppArmor 2.3 - AppArmor 2.6 sockets
opened by an unconfined process could not be delegated to a confined
process, they had to be revalidated. This was inconsistent with the
behavior for files. In AppArmor 3.0 ?????

---

??? Talk about rule combining eg. deny subtracting in more detail
??? Talk about aliases and mapping (tcp short cut)

```
 network tcp connect from 192.168.1.1 on iface1 to 1.1.1.1,
```

connection tracking and label

audit, quiet, deny, kill, nokill? owner and conditional

```
 rule = “network” [ [ <domain> ] [ <type> ] [ <protocol> ] [ <proto_expr> ] ] “,”

 domain = “inet” | “ax25” | “ipx” | “appletalk” | “netrom” |

             “bridge” | “atmpvc” | “x25” | “inet6” | “rose” |
             “netbeui” | “security” | “key” | “packet” | “ash” |
             “econet” | “atmsvc” | “sna” | “irda” | “pppox” |
             “wanpipe” | “bluetooth”
```

**note**: “local” is not allowed

```
 type = “stream” | “dgram” | “seqpacket” | “rdm” | “raw” | “packet” | “dccp”

  protocol = “tcp” | “udp” | “icmp” | “ftp” | ... proto_expr = <ip_expr> | ... ip_expr = [ <ip_action> ] [ <ip_host_expr> ] [ <ip_expr_tail> ] ip_action = <tcp_action> | <udp_action> tcp_action = “connect” | “accept” | “connected” udp_action = ( “send” | “recv” ) [ “&” <udp_action> ] ip host_expr = <direction> <ip_expr> direction = “to” | “from” | “local” | “remote” | “endpoint” ip_expr = <ipv4_expr> | <ipv6_expr> ip_expr_tail= ( <ip_iface | <limit> | “conntrack”)* ipv4_expr = <ipv4_addr> [ “:” <port_expr> ] ipv4_addr = <ipv4_quad> | (<ipv4_quad> “/” <ipv4_quad>) | (ipv4_quad “/” DIGIT{1,2}

 ipv4_quad = DIGIT{1,3} (“.” DIGIT{1,3}){3,3} ipv6_expr = “[” <ipv6_addr> “]” [ “:” <port_expr> ] ipv6_addr = <ipv6_part> [ “/” 1*2DIGIT ] ipv6_part = <hexseq> / <hexseq> “::” [ <hexseq> ] | “::” [ <hexseq> ] hexseq = hex4 ( “:” hex4)* hex4 = HEXDIG{1,4} port_expr = DIGIT{1,5} [ “-” DIGIT{1,5} ] iface = “via” REGEXP limit = “limit” DIGIT+ [“b” / “B” / “k” / “K” / “m” / “M”]
```

Currently we only support

```
 rule = “network” [ [ <domain> ] [ <type> ] [ <protocol> ] “,”
```

where protocol is limited to “tcp”, “udp”, “icmp” and
can only be specified if one of \<domain\> or \<type\> is not.

**NOTE**: when protocols are specified without type or domain the
matching code makes certain assumption and does mapping. See tcp and
udp examples below.

Example:

```
 network inet stream,  # allow inet stream == tcp

 network inet raw,

 network inet tcp, # allow inet stream == tcp, NOT inet raw tcp

 network inet udp, # allow inet dgram == udp, NOT inet raw udp

 network inet,  # allow all inet type and protocols

 network tcp,   # allow all family's that support tcp, so
                # currently this matches both inet, and inet6
                # ie.
                # network inet stream,
                # network inet6 stream,
                # BUT NOT
                # network inet raw tcp,
                # network inet6 raw tcp,

 network, # allow any and all networking
```

should be connected be supported or should it be handled by fd delegation

### DBUS rules

The policy rules are designed similar to the networking rules. To
allow all dbus messages, acquiring of service names etc. you just
need the rule

```
 dbus,
```

While the rule

```
 dbus bus=system dest=com.foo acquire,
```

Is very specific in stating that the profile is allow to acquire the
com.foo service name on the system bus. The policy format currently
supported is as follows

```
 ['audit'] ['deny'] dbus [bus='system'|'session'] ['dest='<address> ] ['path='<path>] ['interface='<interface>] ['method='<method>] [<perms>] ','

 <perms> := <perm> | '(' (<perm> ','|[\w]) <perm> ')'
 <perm> := r, w, rw, send, receive, acquire, bind, read, write
```

For the permissions r maps to read which maps to receive, w maps to
write which maps to send, bind maps to acquire

The ordering is currently important but in the future it could be more
flexible as most components are named if they are specified. If any
component is left off a rule then it will match everything of that
type. ie.

```
 dbus dest=com.foo,
```

will allow sending messages to com.foo, receiving messages from
com.foo, and acquiring the service name com.foo on both the session
and system buses.

```
 dbus bus=system dest=com.foo w,
```

allows sending messages too com.foo on the system bus. Which can also
be expressed as

```
 dbus bus=system dest=com.foo send,
```

Any single permission is allow to be specified by it self, but if more
than one permission is specified it must appear in a list similar to
the flags format.

```
 dbus bus=system dest=com.foo (send, receive),
```

The commas within the parenthesis are optional, plain whitespace
delimitation works just as well. The only exception the paren rule
for multiple permissions is rw, which can be used outside of or inside
of parens.

Note it is legal to specify

```
 dbus bus=system dest=com.foo (rw, send receive),
```

A few more examples of valid rules:

```
 deny dbus bus=system dest=com.foo path=“/foo /bar” interface=com.bar method=fred rw,

 dbus interface=com.foo path=/foo/bar (send receive),

 dbus dest=com.foo acquire,
```

Now that the basis of the current policy is out of the way we can
not a couple of things. 1. Current policy doesn't allow specifying a
local and a remote, and I am not sure I can see a case where it makes
sense to do so. The address is mapped to both local and remote. ie.

```
 dbus dest=com.foo rw,
```

means allow receiving messages from com.foo, and sending messages
to com.foo

Generally it would be good practice to split up dbus rules when
addresses and or permissions are specified. And we may consider
enforcing such a rule.

```
 dbus,
```

mapping to everything makes sense. But the dbus dest=com.foo case is
a little confusing if you think about it and throwing bind/acquire
into the mix just makes it worse.

2. acquire/bind only apply the dest= expression, which makes
   including it in rules with path, interface, and method information
   illegal. Acquire must be used in a separate rule or the parser
   will throw an error.

3. addresses, paths, interfaces and methods support apparmor regexs,
   so don't forget to escape special characters.

4. addresses, paths, interfaces, and methods can all be quoted.

5. The profile= flag is not currently supported, which means you
   can't specify the target profile of the communication.

```
 dbus profile=/foo/bar,   # only allow communicating of task confined by /foo/bar
```

This is planned for just not implemented yet.

### IPC rules

audit, quiet, deny, kill owner and conditional

AppArmor ipc rules cover a broad range of ipc behaviors, and like
networking rules can be very generic or tailored to a specific form
of ipc. At its base IPC rules are concerned with which profiles can
shared data.

```
 ipc with profile1,
```

#### Signals

#### Pipes

-   inherited and allowed via implicit delegation

#### Fifos

-   mediated by file control, could do with better create control

#### System V ipc

-   message queues

-   Semaphores

-   Shared memory segments

#### Delegation

Delegation is a special form of ipc that allows a profile to delegates
it authority to access an object to another profile. This enables
a parent profile to extend the permission a child profile has to
include specific objects that the parent has access to.

Delegation allows for tighter profiles (stricter profiles), children
profiles don't need to have access rights object they may receive from
their parent, while at the same time allows for greater flexibility
and reuse of profiles as it is possible to use one tight profile in
multiple situations.

Delegation is cumulative like other rule permissions and can be
specified by either using a rule suffix, or a rule block.

Examples:

```
 rw /example/file delegate to profile1,
 network tcp delegates to profile2,
```

```
 delegate to profile3 {
   rw /example/file,
   network tcp,
   network udp delegate to profile4,   # delegate to profile3 and profile4
 }
```

It is important to note that delegation only works on objects opened
and passed by the parent profile. It does not extend the target
profiles ruleset.

#### Revalidation - Interaction of IPC with other rules

IPC rules interact with file and network rules so it is important to
understand how they interact. When a file or network object is being
created, or opened the file or network rules are applied, creating
a labeling on the opened resource (object). When data, an open file
or network object is passed between tasks ipc rules are applied, to
determine if the data or object can be passed. However if there is not
an ipc rule governing the interaction (either positive or negative)
then AppArmor will fall back to revalidation.

Revalidation is the process by which AppArmor looks at the resource and
recomputes its access permissions, answering whether the task receiving
the object can access it, because its base permission set allows it.

Revalidation is used because AppArmor's set of labels is dynamic and
changes as profiles are loaded or removed.

#### Interaction of IPC with file rules

The interaction of files and ipc

what of labeled files???

#### Interaction of IPC and network rules

Network and IPC rule interaction is similar to that of file rules.

##### IPC and labeled network packets

When network rules are marked as belonging to a secure connection,
packet labeling is used and IPC rules will determine the access
permissions for packet data. This is done by leveraging CIPSO, it is
assumed the network is secured in someway (LAN, vLAN, ..) and that
applications are correctly confined, using a common confinement for
all machines in the network.

When a packet is set it is labeled with the specified label and that
label is then used to determine access permission on the receiving end.

### Resource controls

AppArmor provides to forms of resource control, the rlimit rules to
control per process resources, and profile level resource controls
to control groups of processes contained by a profile.

#### Rlimit rules

```
 <rlimit rule> ::= 'rlimit' <rlimit> '<=' <value> ','  (AppArmor 2.3 - AppArmor 2.6)
 <rlimit rule> ::= 'rlimit' [<rlimit> '<=' <value> ] ','  (AppArmor 2.7)
 <rlimit rule> ::= 'rlimit' [<rlimit> '<=' <value> ] ['profile' <profile>] ','  (AppArmor ???)
```

AppArmor provides the ability for a profile to set and control
an applications rlimits (man 2 setrlimit) also known as ulimits
(man 3 ulimit, man 1 ulimit). By default AppArmor does not control
applications rlimits, and it will only control those limits that
there is a specific rule for in the confining profile.

AppArmor leverages Linux's rlimits and as such does not provide
an additional auditing than would normally occur. Also AppArmor's
rlimits only every reduce an applications current rlimits, they can
not be used to raise the value of any limit that has been set.

AppArmor rlimit rules are currently limited in that the limit's
value will be inherited by a processes children and will remain
even if a new profile is transitioned to, or the application becomes
unconfined. If an application transitions to a new profile, the new
profile can control and further reduce the applications rlimits.

AppArmor's rlimit rules also mediate setting an applications hard
limits, should it try to raise them. The application will not be able
to raise its hard limits any farther than specified in the profile.

The mediation of raising hard limits is not inherited as the limit
value is, so that once the application transitions to a new profile
it is free to raise its limits value as if allowed by the new profile.

AppArmor's rlimit control does not affect an applications soft limits
beyond ensuring that they are less than or equal to the applications
hard limits.

Audit of rlimits only happened when a task tries to set its rlimits,
as the enforcement of the rlimit is not done by AppArmor.

AppArmor 2.7 adds the ability to control the setting of rlimits with
out specifying a value. This prevents the task from changing the
rlimits it has inherited.

AppArmor ??? adds the ability to control the rlimits of a task confined
by another profile.

The allowable values for \<rlimit\> and the its associated \<value\>
field is described below. \<rlimit\>

-   fsize, data, stack, core, rss, as, memlock, msgqueue:

    These rlimits take either a number in bytes, or a number with a suffix where the suffix can be

```
 K - kilobytes
 M - megabytes
 G - gigabytes
```

    Example

```
  rlimit data <= 100M,
```

-   nofile, locks, sigpending, nproc, rtprio, cpu (cpu is only supported in AppArmor 2.7+)

    These rlimits take a number greater or equal to 0 indicating their limit.

-   nice

    The nice rlimit takes a value between -20 and 19.

**NOTES**:

-   Rlimit rules first appeared in AppArmor 2.3
-   In AppArmor 2.3 - 2.7 The set limit's value will be inherited by a processes children and will remain even if a new profile is transitioned to, or the application becomes unconfined.
-   Qualifiers (audit, quiet, ..) are currently not supported
-   AppArmor handles nproc in version 2.3 and 2.4 and later on differently
-   currently the tools can not be used to add rlimit rules to profiles. The only way to add rlimit controls to a profile is manually edit the profile with a text editor. The tools will still work with profiles containing rlimit rules and will not remove them, so it is safe to use the tools to update profiles containing them.}}

##### Special nproc rlimit for AppArmor 2.3

In AppArmor 2.3 the nproc rlimit is special in that it is handled
different than all the other rlimits. Instead of indicating the
standard process rlimit it controls the maximum number of processes
that can be running under the profile at any given time. Once the
limit is exceeded the creation of new processes under the profile
will fail until the number of currently running processes is reduced.

The AppArmor 2.3 interpretation is no longer used in later versions of
AppArmor due to technical changes. The AppArmor per profile nproc of
AppArmor 2.3 has been replaced by profile resources based on cgroups
in AppArmor 2.7+.

#### Profile based resource controls

The AppArmor profile resource controls provide a way to control the
resources of all process contained by a profile. To do this apparmor
creates a linux container for each profile that specifies a resource
control and then domain transitions also can transition a process
into another container.

...

### Change profile

audit, quiet, deny, kill, nokill? owner - implicit

### Append

File creation semantics have been changed slightly so that the append
permission provides sufficient privilege to create a new file.

### change\_profile

The change\_profile interface has been extended so that it can be used
by an unconfined process to enter confinement. An unconfined process
using change\_profile can enter any loaded profile. For unconfined
processes the change\_profile interface differs from the set\_profile
interface in that it only applies to the current task while the
set\_profile interface can be used to change confinement on any task.

------------------------------------------------------------------------

### Trusted Helpers

Beyond the core enforcement done by the AppArmor kernel module,
some system daemons/helpers can be built with AppArmor extensions
that provide additional mediation. The details of how a helper is
configured and how it affects policy

#### D-Bus

```
 ['audit'] ['deny'] dbus ['system'|'session'] [['address='] <address>] ['path='<path>] ['interface='<interface>] ['method='<method>] [<perms>] ','

 <perms> := <perm> | '(' (<perm> ','|[w]) <perm> ')'
 <perm> := r, w, rw, send, receive, acquire, bind, read, write
```

#### X Windows

#### Postgres Sql

#### Pam apparmor

#### Apache modapparmor

Extententions to Profile Specification
--------------------------------------

------------------------------------------------------------------------

New execute permissions
-----------------------

### Named Profile Transitions and Log Messages

Named profile transitions show up in the log as having the mode Nx
and the name of the profile to be changed to is in the name2 field.

------------------------------------------------------------------------

------------------------------------------------------------------------

File rules conditional on file ownership
----------------------------------------

AppArmor 2.3 extends file rules so that they can be conditional upon
the the user being the owner of the file.

------------------------------------------------------------------------

------------------------------------------------------------------------

Application directed transitions - Change Hat & Change Profile
==============================================================

AppArmor provides a for application directed profile transition
via change\_hat and change\_profile. Change\_profile provides for
a generic one way transition between any of the loaded profiles,
while change\_hat provides for a returnable parent, child transition.

change\_hat
-----------

-   Application must be confined
-   special local profiles called hats are the only profiles available for transition
-   change of domain takes place immediately

change\_profile
---------------

-   can be used by unconfined or confined applications
-   confined applications need rules to control which profiles may be transitioned to

### change\_profile on exec

-   convenience form of change\_profile
-   profile transition is delayed until exec time
    -   equivalent to change\_profile + stub profile with px rule to destination
-   overrides x rules
-   eliminates the need for stub profiles

confined vs. unconfined

##### change\_hat

```
 /bin/su {
    ...

    ^tom {
       ...

       /bin/bash px -> confined_user,
    }

    ^jane {
       ...

       /bin/bash px -> confined_user,
    }
  }
```

##### change\_profile

```
 /bin/su {
     ...
     change_profile stub,

 stub {
     ...

     /bin/bash px -> confined_user,
 }
```

##### change\_profile on exec

```
 /bin/su {
     ...

    change_profile /bin/bash -> confined_user,
 }
```

### Change\_hat and Change\_profile rules

The change\_profile interface has been extended so that it can be used
by an unconfined process to enter confinement. An unconfined process
using change\_profile can enter any loaded profile. For unconfined
processes the change\_profile interface differs from the set\_profile
interface in that it only applies to the current task while the
set\_profile interface can be used to change confinement on any task.

An embedded hat, implicitly adds the change\_hat rule to the profile
as well as all the sibling hats.

Change\_profile rules are similar except that they start with the
keyword change\_profile.

Example:

```
 change_profile a_profile,
```

### Differences between change\_hat and change\_profile

Both change\_hat and change\_profile provide for an application
directed profile transition, without having to launch a separate
application.

Change\_profile provides a generic one way transition between any of
the loaded profiles. Change\_hat provides for a returnable parent
child transition where an application can switch from the parent
profile to the hat profile and if it provides the correct secret key
return to the parent profile at a later time.

### Safety of Domain transitions and when to use them

The change\_hat and change\_profile domain transitions are less secure
than a domain transition done through an exec. This is because they
do not affect a processes memory mappings, nor do they close resources
that have already been opened.

Change\_hat is a specialized version of change\_profile that has
additional security implications, so we will look at change\_profile
first.

Change\_profile provides a one way transition, that allows an
application to go through a setup phase and then when setup is done,
transition to a profile with less privilege. Any resources mapped
or opened during the startup phase may still be accessible after the
profile change but the new profile will restrict the opening of new
resources, and will even limit some of the resources opened before
the switch.

Specifically memory resources will still be available while capability
and file resources (as long as they are not memory mapped) can
be limited.

Change\_profile is best used in situations where an application goes
through a trusted setup phase and then can lower its privlege level.

Change\_hat is designed to be used in situations where privilege
is temporarily dropped and then re-acquired after a time. As such
change\_hat is restricted to where it can be safely used. Since
change\_hat stores the return secret key in the applications memory
the phase of reduced privilege should not have direct access to
memory. Also it is important that file access is properly separated,
the hat can restrict accesses to a file handle but it does not close
it. If an application does buffering and provides access to the open
files with buffering, the accesses to these files may not be seen by
the kernel and hence not restricted by the new profile.

Change\_hat is best used in situations where an applications runs a VM
or interpreter that does not provide direct access to the applications
resources. An example of where it could add security value is apache's
mod\_perl and mod\_php.

