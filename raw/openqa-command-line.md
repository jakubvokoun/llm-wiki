---
source_url: https://liv.pink/post/2021-04-27-working-with-openqa-via-the-command-line/
fetched: 2026-06-23
---

# Working with openQA via the command line

April 27, 2021 · 6 min · Liv Dywan

openQA allows for a few different workflows. The main entry point is the web UI if you're wanting to look at builds, relevant jobs, test results and of course to investigate down to the level of the bare logs if all else fails. Eventually there's a point where you run into limitations of what's exposed through the browser. Let's take a look at what openQA has to offer on the command line!

## Inspecting the jobs

Starting with the basics, say we want to get an idea of what's going on in our openQA instance. And I'll be using `openqa.opensuse.org` here - all of what I'm going to explain later on applies to other instances as well. The **jobs** API route perhaps unsurprisingly is what we want here:

```
openqa-cli api --host http://openqa.opensuse.org jobs/overview
```

You may find that the output isn't particularly nice to look at - luckily there's a built-in way to make the JSON tons more readable without extra tooling:

```
openqa-cli api --host http://openqa.opensuse.org --pretty jobs/overview
```

## Get the details of a specific job

So say we know what job we're interested in, the next step would be to inspect it further. And where within the web UI we'd be looking at the results view, here we'll pass the job ID to the **jobs** API route:

```
openqa-cli api jobs/1222737
```

You may have noticed that I didn't specify the host here. If you tried it you might've gotten an error message and wondered what's wrong. Or perhaps you typed it in with the `--host` parameter already. The client talks to **localhost** by default which comes in handy if you're working on the same machine e.g. when using a development instance.

If that isn't what you wanted, simply add the host like before:

```
openqa-cli api --host openqa.opensuse.org jobs/1222737
```

## Trigger builds

```
openqa-cli schedule \
DISTRI=sle VERSION=15 FLAVOR=Desktop-DVD-Updates \
ARCH=x86_64 TEST=qam-all \
FOO=1 BAR=baz
```

## Authentication

Some API calls require credentials. `client.conf` is understood by most OpenQA tools:

```
[openqa.example.com]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
```

Or specify the login with the command:

```
openqa-cli schedule --host http://openqa.example.com \
--apikey 1234567890ABCDEF \
--apisecret 1234567890ABCDEF
...
```

Note: `schedule` is analogous to `api -X POST isos`. To make your life easier you can add `-m` to wait for results.

## Post jobs

Now that we have authentication working, let's look at more common use cases!

```
openqa-cli api --host http://openqa.example.com \
-X POST jobs \
DISTRI=sle VERSION=15-SP2 \
FLAVOR=Online ARCH=x86_64 \
TEST=create_hdd_textmode \
MACHINE=64bit BUILD=189.1
```

Use `api -X POST` to post, with `jobs` as the API route.

## Post comments

```
openqa-cli api --host http://openqa.example.com \
-X POST jobs/2/comments text=hello
```

Let's delete the comment again:

```
openqa-cli api --host http://openqa.example.com \
-X DELETE jobs/2/comments/1
```

## Delete a job

```
openqa-cli api --host http://openqa.exmaple.com \
-X DELETE jobs/67
```

Use `api -X DELETE` to delete.

## Getting the YAML for a job template

Job templates are generally defined in YAML, which can be updated via the web UI or using API routes - fun fact, the web UI actually uses those same routes!

```
openqa-cli api --host openqa.opensuse.org \
-a 'Accept: application/yaml' \
job_templates_scheduling/73 > MicroOS.yaml
cp MicroOS.yaml{,.bak}
```

Save the YAML for the MicroOS job group to a file, using > in the shell. Use `-a` to say that we want YAML output from the API. Make a *backup* of the YAML. We can now **edit** the YAML document.

## Updating the YAML

```
openqa-validate-yaml MicroOS.yaml
```

Validate the YAML locally. This will fail on syntax errors. Note: Test suites and settings are not validated this way!

```
openqa-cli api -X POST job_templates_scheduling/73 \
schema=JobTemplates-01.yaml \
template="$(cat MicroOS.yaml)" \
reference="$(cat MicroOS.yaml.bak)"
```

Update the job group. Specify the YAML file. Use the *reference* to avoid editing conflicts - this optional feature allows the update to fail if there was another update to the template. The web UI uses this to detect multiple persons trying to make changes at the same time.

## Updating properties of a job group via PUT request

First let's see which properties are present in a job group. To do that simply issue a GET request on a job group. For example let's assume that our job group ID is 432:

```
openqa-cli api --pretty /job_groups/432
```

This will produce a json output something similar to:

```
[
   {
      "build_version_sort" : 1,
      "carry_over_bugrefs" : 1,
      "default_priority" : 50,
      "description" : "",
      "exclusively_kept_asset_size" : null,
      "id" : 432,
      "keep_important_jobs_in_days" : 0,
      "keep_important_logs_in_days" : 90,
      "keep_important_results_in_days" : 0,
      "keep_jobs_in_days" : 730,
      "keep_logs_in_days" : 10,
      "keep_results_in_days" : 20,
      "name" : "openqa-testing",
      "parent_id" : 51,
      "size_limit_gb" : "5",
      "sort_order" : null,
      "template" : null
   }
]
```

Note down the name of the job group which is `openqa-testing`.

Now, let's say to update the value of `keep_important_jobs_in_days` we have to issue a PUT request via `openqa-cli api` as shown:

```
openqa-cli api -X PUT /job_groups/432 --form --data '{"name":"openqa-testing", "keep_important_jobs_in_days":21}'
```

Note that the `"name":"openqa-testing"` is important, otherwise it will throw an error.

## Archive mode

Get all the assets in one fell swoop:

```
openqa-cli archive 408 /tmp/openqa_job_408
```

Tip: Optionally add `--with-thumbnails`

## Extensible

Commands are implemented as simple plug-ins. What this means is that you actually implement a new command simply by creating a new file e.g. `foo.pm` in `lib/OpenQA/CLI` within the openQA source distribution. Be sure to use the according `package OpenQA::CLI::clone` at the top of your Perl module and `openqa-cli foo` will just work, as will `openqa-cli --help` including whatever options you add there.

For a simple example:

```perl
package OpenQA::CLI::foo;
use Mojo::Base 'OpenQA::Command';

use Mojo::Util qw(getopt);

has description => 'Download assets and test results from a job';
has usage       => sub { shift->extract_usage };

sub command {
    my ($self, @args) = @_;

    getopt \@args,
      'l|asset-size-limit=i' => \(my $limit),
      't|with-thumbnails'    => \my $thumbnails;

    @args = $self->decode_args(@args);
    die $self->usage unless my $job  = shift @args;
    die $self->usage unless my $path = shift @args;

    my $url = $self->url_for("jobs/$job/details");
    my $client = $self->client($url);
    $client->archive->run(
        {url => $url, archive => $path,
         'with-thumbnails' => $thumbnails,
         'asset-size-limit' => $limit});

    return 0;
}

1;
```

## Shortcuts

Say we have a test on O3 i.e. the common abbreviation for `openqa.opensuse.org` but we're getting a bit bored with typing this out every single time. So it would be rather handy if there was a way around that… fortunately somebody thought of this and added this handy shortcut:

```
openqa-cli api --o3 --pretty jobs/4078851
```

Incidentally this also works for `openqa.suse.de`, which is an *internal* openQA instance:

```
openqa-cli api --osd --pretty jobs/1222737
```

If you're reading this and thinking "But hold on, can I have this for my instance", please do reach out and I'm sure we can add another shortcut!

## More features to play with

I can't possibly show off every single feature here so what I'm going to do instead is I'm going to tease you some more:

* `--data '{"group_id: 2"}'`
* `--data-file ./test.json`
* `--form --data '{"text":"example"}'`
* Pipes work, too!
* And full UTF-8 support!

See `openqa-cli --help`!

## I'm all excited, I want to find out even more!

* You definitely want to check out [the openQA docs](http://open.qa/docs/#client) and play some more with the commands shown here.
* Also, try and open an invalid URL in the openQA web UI - something magical might happen that'll be useful for working with the RESTful API.
* Be sure to check out [openqa-mon](https://openqa-bites.github.io/posts/2021-02-25-openqa-mon/) which is a tool based on the API that allows you to monitor your jobs
