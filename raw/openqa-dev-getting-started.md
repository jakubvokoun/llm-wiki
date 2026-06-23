---
source_url: https://liv.pink/post/2021-02-16-get-started-with-openqa-development/
fetched: 2026-06-23
---

# Get started with openQA development

February 16, 2021 · 6 min · Liv Dywan

## I want to develop openQA

[openQA](https://open.qa/) is a framework to run system-level tests that is used for openSUSE, Fedora and others in a way that uses a serial console or mouse and keyboard input to interact with tests. No support from the software toolkit used is required to make this work. For the purposes of this article I'm going to assume you have a basic idea about *openQA*.

## So what do I need to get going?

For the development system I'll assume [openSUSE Tumbleweed](https://get.opensuse.org/tumbleweed/). You can use bare metal, a VM or work out of a container. Personally I like to use [toolbox](../2021-02-22-developing-in-toolbox-containers) for this purpose since it allows me to keep the base system clean.
I'm using convenience packages provided to make bootstrapping easier. This includes perl dependencies, git and compilers if not already installed and should be all you need if you're setting up a new system or a new container.

```
sudo zypper in openQA-devel os-autoinst-devel os-autoinst-distri-opensuse-deps
```

**Note:** I'm going to show how to manually configure and run the different pieces here. If you are less interested in the inner workings and just want to get going with running tests via openQA, you'll want to checkout `openqa-bootstrap` or `openqa-bootstrain-container` which are scripts also provided instead of following the setup in this article.

Getting a local copy of the [openQA](https://github.com/os-autoinst/openQA) and [os-autoinst](https://github.com/os-autoinst/os-autoinst) git repos is fairly straightforward. Be sure to **have cloned both repos first**! I'll assume that openQA sources are going to live in the folder `~/openQA-dev`. Feel free to adjust as needed if you prefer a different location. The base folder is just going to help consolidate config files, repositories and test data in the long run.

```
mkdir -p ~/openQA-dev/{config,repos}
cd ~/openQA-dev/repos
git clone git://github.com/os-autoinst/openQA.git
git clone git://github.com/os-autoinst/os-autoinst.git
```

Next, prepare your shell environment to use your local checkout. This can be done in your `~/.bashrc` if you're using the default shell.

```
export OPENQA_BASEDIR=$HOME/openQA-dev
export OPENQA_CONFIG=$OPENQA_BASEDIR/config
export OPENQA_LIBPATH=$OPENQA_BASEDIR/repos/openQA/lib
export PERL5LIB=$OPENQA_LIBPATH:$OPENQA_BASEDIR/repos/openQA/t/lib
CDPATH=.:$OPENQA_BASEDIR/repos
```

Usually you would have your client configuration at `~/.config/openqa/client.conf` or `/etc/openqa`. Since we want to change things easily and avoid running services system-wide that require superuser permissions, we drop our files into `~/openQA-dev/config` instead. This works because we set it in the environment.

```
mkdir -p ~/openQA-dev/openqa/{db,share/factory/hdd}
printf "[production]\\ndsn = DBI:Pg:dbname=openqa_test;host=$OPENQA_BASEDIR/db" > ~/openQA-dev/config/database.ini
printf "[127.0.0.1]\\nkey=1234567890ABCDEF\\nsecret=1234567890ABCDEF" > ~/openQA-dev/config/client.conf
printf "[global]\\nHOST=http://127.0.0.1:9526" > ~/openQA-dev/config/workers.ini
```

## How do I run unit and integration tests for openQA or os-autoinst?

As we have our repositories in the `CDPATH` this just works, assuming you want to run the `09-job_clone.t` test:

```
cd openQA
make test-with-database TESTS=t/09-job_clone.t
```

Also this - the first `make` call will actually prepare and build native binaries of `isotovideo`:

```
cd os-autoinst
make
make check
```

You will want to take a closer look at the project-specific `README.md` files and browse the `t` directories to inspect the available test cases. Since they change from time to time to meet development requirements I won't cover this in a lot of detail here.

## Unit tests are great and all, but I want to fiddle with a live openQA web UI

```
cd openQA
rm -Rf $OPENQA_BASEDIR/db # to clear an existing db
t/test_postgresql $OPENQA_BASEDIR/db 1>/dev/null
morbo -l http://*:9526 ./script/openqa
```

This will expose a web UI on port 9526 using a **temporary database**. This is probably the fastest way to get something you can start and stop easily. And there is little to worry about breaking changes since you can always go back to a fresh state: Simply delete the `db` folder and re-create the database. No systemd services are involved here - if you're tempted to inspect via *systemctl* you'll find there is no *postgres* running system-wide here.

You will want to *Login* via the top-right menu. This automatically gives you administrative rights and also enables the default API key which can be used to run jobs or use the API to make changes to openQA.

## How do I make changes to the openQA web UI?

Whip out your favorite editor, be that *code-server* or *neovim*, and start hacking. Usually `openQA/lib/openQA` is a good starting point if you want to mess with the internals of openQA. Most importantly you'll want to become aware of the `Schema`, `WebAPI.pm` for a general entry point to all web API routes and `Setup.pm` for configuration of the application. The `Worker` folder unsurprisingly deals with the excution of jobs. Again, I'm providing a general overview here to help get you started. Eventually you'll want to browse the sources more extensively.

For an easy exercise you could modify the branding template in `templates/webapi/branding/plain/docbox.html.ep` and modify the text shown on the frontpage. After making changes, a refresh is enough to see the difference! Note that for some fundamental changes you still need to re-run *morbo* but it works well for straightforward module code.

## Fair enough. What about cloning a test?

```
$OPENQA_BASEDIR/repos/openQA/script/openqa-clone-job --dir=$OPENQA_BASEDIR/openqa/share/factory --host=http://127.0.0.1:9526 https://openqa.opensuse.org/tests/1600326
```

The first time you clone a job for a particular product it will download the image to the specified path and depending on your internet connection speed this can take a while. You may want to grab a cup of tea, coffee or perhaps a glass of water whilst the download is on-going - it's important to stay hydrated.

Now you can check **All Tests** at the top in the navigation bar of the web UI. And your cloned test should show up there.

## I can see my test but it's not running yet

Keeping in mind that openQA works as a scheduler, we still need to run a worker to do the actual work. So far we've only collected the data needed with nobody to pick that up. But not to worry, let's start a worker:

```
cd openQA
script/openqa-websockets daemon &
script/worker
```

But hold on, what's that websocket daemon here? Why thank you for asking, this is how our worker talks to the web UI. And to be sure, this is just one worker for now. After a brief delay you should be seeing the test at the top of the *All tests* view as *running*.

As a little exercise, try and run another worker in parallel using `--instance 2` and explore the *Workers* menu to see what it looks like. The instance parameter is optional, and if given identifies multiple workers on the same host.

## All done, yes?

There you go! There's a lot more to learn to be sure. And you may want to read the [openQA developer guide](https://github.com/os-autoinst/openQA/blob/master/docs/Contributing.asciidoc) to get more familiar with all of the details. But you should have all of the basics now to contribute your first patch!
