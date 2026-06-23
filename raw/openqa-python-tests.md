---
source_url: https://liv.pink/post/2021-07-15-writing-openqa-tests-in-python/
fetched: 2026-06-23
---

# Writing openQA tests in Python

July 15, 2021 · 4 min · Liv Dywan

openQA is a test framework that works with many operating systems. openSUSE, Fedora, Debian and others are using it to ensure the quality of releases. Writing tests with it is easier than you might think. And you can use Python to do it!

## So what is an openQA test

I wrote about [getting started with openQA development](../2021-02-16-get-started-with-openqa-development) before which introduces you to working on the framework itself. If you came here to dive deeper, consider reading that article. Here I'll talk about writing a test from the perspective of someone who uses a running openQA instance. Naturally you can also use one you setup for development.

When I refer to a "test" here it's short for a test module and that's mainly what we'll look at. The code that is executed and which communicates with the backend to run commands, interact using mouse and keyboard or verify what needle is shown. See [the official glossary](https://open.qa/docs/#concepts) for more on terminology around openQA.

## Do you like snakes better than camels?

Typically tests are written in Perl and that's what most existing test code will be when you start looking for examples. The Python support is a more recent addition. For that reason I'll introduce you to what such a test looks like. Bear with me here 🐻️

```
use strict;
use testapi;

sub run {
    assert_screen 'openqa-logged-in';
    assert_and_click 'openqa-search';
    type_string 'shutdown.pm';
    send_key 'ret';
    assert_screen 'openqa-search-results';
}

sub switch_to_root_console {
    send_key 'ctrl-alt-f3';
}

sub post_fail_hook {
    switch_to_root_console;
    assert_script_run 'openqa-cli api experimental/search q=shutdown.pm';
}

sub test_flags {
    return {fatal => 1};
}

1;
```

The blocks with `sub` at the start are functions. *run* is where your test module starts to do things. I'm using some of the most common API functions here:

* *assert_screen*: Confirm that a given needle is shown
* *assert_and_click*: Same as above, but perform a mouse click
* *type_string*: Type on the keyboard
* *send_key*: Press a single key
* *assert_script_run*: Run a command line and check that it succeeded

You may want to check out [the testapi documentation](http://open.qa/api/testapi/) for more details. For the purposes of this blog and getting started you won't need to know all of that yet, though.

## How do I translate camel to parseltongue

Turns out it's surprisingly straightforward. The API maps transparently between the two languages and you can use the same functions. If you're more at home with Python you'll probably find it easier on the eyes. Still, the code is basically the same!

```
from testapi import *

def run(self):
    assert_screen('openqa-logged-in')
    assert_and_click('openqa-search')
    type_string('shutdown.pm')
    send_key('ret')
    assert_screen('openqa-search-results')

def switch_to_root_console():
    send_key('ctrl-alt-f3')

def post_fail_hook(self):
    switch_to_root_console()
    assert_script_run('openqa-cli api experimental/search q=shutdown.pm')

def test_flags(self):
    return {'fatal': 1}
```

One of the easiest ways to work on a test is to find an existing scenario and extend it. The above is actually the contents of [search.py in the openQA test distribution](https://github.com/os-autoinst/os-autoinst-distri-openQA/blob/master/tests/openQA/search.py) at the time of this writing, or [search.py in o3](https://openqa.opensuse.org/search?q=search.py).

Be sure you have forked the repository of the test distribution and push your branch. That way you can use the following to execute your modified test:

```
toolbox -u
openqa-clone-custom-git-refspec https://github.com/os-autoinst/os-autoinst-distri-openQA/pull/XXX https://openqa.opensuse.org/tests/YYYYYY FOO=1
```

To find the relevant test ID to insert for `YYYYYY` check [the openQA job group on o3](https://openqa.opensuse.org/tests/overview?groupid=24) and use `XXX` from your branch/ pull request respectively.

**Note:** I use [toolbox](../2021-02-22-developing-in-toolbox-containers) above. That's not required, just what I do to keep development stuffs separate from the host.

## Hack, hack, hack, hack, hack

There we are. If all went well you now have a test with some of your own changes scheduled or perhaps already finished. Now's the time to read [the reference guide on how to write tests](https://open.qa/docs/#_how_to_write_tests) and check out the [the full testapi documentation](http://open.qa/api/testapi/) that you were taking a peek at when I said it wasn't important yet. And of course have fun!
